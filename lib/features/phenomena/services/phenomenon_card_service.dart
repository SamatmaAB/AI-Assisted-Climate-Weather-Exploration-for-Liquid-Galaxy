import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';
import 'package:lg_connection/models/climate_phenomenon_model.dart';
import 'package:lg_connection/models/phenomenon_card_data.dart';
import 'package:lg_connection/features/phenomena/utils/phenomenon_card_kml_generator.dart';
import 'package:lg_connection/services/ai/api_key_storage.dart';
import 'package:lg_connection/services/ai/prompts/ai_prompts.dart';
import 'package:lg_connection/shared/services/cache_service.dart';

/// Orchestrates the climate-phenomenon details-card pipeline on the LG rig.
///
/// Mirrors [CityExplorerBalloonService] exactly:
///   1. Resolve Gemini-sourced card data (Hive cache → Gemini).
///   2. Generate the card KML via [PhenomenonCardKmlGenerator].
///   3. Write the KML to `slave_<rightMostScreen>.kml` on the LG rig.
///   4. Refresh only the rightmost screen.
///
/// No weather icon is uploaded — the card is CSS-only (no binary asset).
class PhenomenonCardService {
  PhenomenonCardService._();

  static final PhenomenonCardService _instance = PhenomenonCardService._();
  factory PhenomenonCardService() => _instance;

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Deploys the details card for [phenomenon] to the rightmost LG screen.
  /// Returns `true` when successfully deployed. Failures are logged, not thrown.
  Future<bool> deployCard({
    required ClimatePhenomenon phenomenon,
    required LGSSHClient lgClient,
  }) async {
    try {
      final data = await _resolveCardData(phenomenon);
      if (data == null) {
        debugPrint(
          'PhenomenonCard: No data resolved for ${phenomenon.name}.',
        );
        return false;
      }

      final screens = lgClient.numberOfRigs;
      final rightMostScreen = SSHCommands.calculateRightMostScreen(screens);

      // Offset coordinates toward the center of the rightmost screen so the
      // balloon appears centered there (same geometry as City Explorer).
      double? targetLat;
      double? targetLng;
      if (screens > 1) {
        final coords = PhenomenonCardKmlGenerator.parseLookAt(
          phenomenon.lookAtXml,
        );
        final offset = _calculateRightScreenCoordinates(
          lat: coords['latitude']!,
          lng: coords['longitude']!,
        );
        targetLat = offset['latitude'];
        targetLng = offset['longitude'];
      }

      final kml = PhenomenonCardKmlGenerator.generate(
        phenomenon: phenomenon,
        data: data,
        targetLatitude: targetLat,
        targetLongitude: targetLng,
      );

      final kmlPath = '/var/www/html/kml/slave_$rightMostScreen.kml';
      bool kmlUploaded = await lgClient.uploadFile(
        content: kml,
        targetPath: kmlPath,
      );

      // Fallback: SSH echo (same mechanism as City Explorer).
      if (!kmlUploaded) {
        debugPrint(
          'PhenomenonCard: SFTP upload failed for $kmlPath, trying SSH echo fallback...',
        );
        kmlUploaded = await lgClient.runCommand(
          "echo '${kml.replaceAll("'", "'\\''")}' > $kmlPath",
        );
      }

      if (!kmlUploaded) {
        debugPrint('PhenomenonCard: KML upload failed for $kmlPath');
        return false;
      }

      debugPrint(
        'PhenomenonCard: KML uploaded to $kmlPath (screen $rightMostScreen of $screens)',
      );

      await lgClient.runCommand(SSHCommands.refreshKML());
      await lgClient.forceRefresh(rightMostScreen);

      debugPrint(
        'PhenomenonCard: Card deployed on screen $rightMostScreen.',
      );
      return true;
    } catch (e) {
      debugPrint('PhenomenonCard: Unexpected error during deploy: $e');
      return false;
    }
  }

  /// Clears the card from the rightmost LG screen.
  Future<void> clearCard(LGSSHClient lgClient) async {
    try {
      final screens = lgClient.numberOfRigs;
      final rightMostScreen = SSHCommands.calculateRightMostScreen(screens);

      final cleared = await lgClient.runCommand(
        SSHCommands.clearScreen(rightMostScreen),
      );

      if (cleared) {
        debugPrint('PhenomenonCard: Cleared slave_$rightMostScreen.kml.');
        await lgClient.forceRefresh(rightMostScreen);
      } else {
        debugPrint(
          'PhenomenonCard: clearScreen failed for screen $rightMostScreen.',
        );
      }
    } catch (e) {
      debugPrint('PhenomenonCard: clearCard error: $e');
    }
  }

  // ─── Data resolution ────────────────────────────────────────────────────────

  Future<PhenomenonCardData?> _resolveCardData(
    ClimatePhenomenon phenomenon,
  ) async {
    final cacheKey = phenomenon.name;

    final cached = CacheService.getPhenomenonCard(cacheKey);
    if (cached != null && cached.trim().isNotEmpty) {
      try {
        final map = jsonDecode(cached) as Map<String, dynamic>;
        return PhenomenonCardData.fromJson(map, phenomenon.name);
      } catch (_) {
        // Corrupted cache — fall through to Gemini.
      }
    }

    final apiKey = await const ApiKeyStorage().getGeminiApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('PhenomenonCard: Gemini API key not configured.');
      return null;
    }

    try {
      final modelName = await const ApiKeyStorage().getSelectedModel();
      final model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        systemInstruction: Content.system(AIPrompts.phenomenonCard),
      );
      final response = await model.generateContent(
        [Content.text('Phenomenon: ${phenomenon.name}')],
      );
      final text = (response.text ?? '').trim();

      final cleaned = _stripCodeFences(text);
      final jsonMap = jsonDecode(cleaned) as Map<String, dynamic>;

      final data = PhenomenonCardData.fromJson(jsonMap, phenomenon.name);

      await CacheService.savePhenomenonCard(
        cacheKey,
        jsonEncode(jsonMap),
      );

      return data;
    } on FormatException catch (e) {
      debugPrint('PhenomenonCard: Malformed Gemini JSON: $e');
      return null;
    } catch (e) {
      debugPrint('PhenomenonCard: Gemini error: $e');
      return null;
    }
  }

  String _stripCodeFences(String text) {
    var s = text.trim();
    if (s.startsWith('```')) {
      s = s.replaceFirst(RegExp(r'^```[a-z]*\n?'), '');
      s = s.replaceFirst(RegExp(r'```$'), '');
    }
    return s.trim();
  }

  /// Coordinates shifted toward the center of the rightmost LG screen.
  /// Mirrors [CityExplorerBalloonService._calculateRightScreenCoordinates].
  static Map<String, double> _calculateRightScreenCoordinates({
    required double lat,
    required double lng,
    double heading = 30.0,
    double distanceMeters = 350.0,
  }) {
    final rightBearingRad = (heading + 90.0) * (math.pi / 180.0);
    final latRad = lat * (math.pi / 180.0);

    final deltaLat = (distanceMeters * math.cos(rightBearingRad)) / 111000.0;
    final deltaLng = (distanceMeters * math.sin(rightBearingRad)) /
        (111000.0 * math.cos(latRad));

    return {
      'latitude': lat + deltaLat,
      'longitude': lng + deltaLng,
    };
  }
}
