import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';
import 'package:lg_connection/models/climate_phenomenon_model.dart';
import 'package:lg_connection/models/phenomenon_card_data.dart';
import 'package:lg_connection/features/phenomena/utils/phenomenon_card_kml_generator.dart';
import 'package:lg_connection/features/phenomena/utils/phenomenon_icon_mapper.dart';
import 'package:lg_connection/services/ai/api_key_storage.dart';
import 'package:lg_connection/services/ai/prompts/ai_prompts.dart';
import 'package:lg_connection/shared/services/cache_service.dart';

class PhenomenonCardService {
  PhenomenonCardService._();

  static final PhenomenonCardService _instance = PhenomenonCardService._();
  factory PhenomenonCardService() => _instance;

  Future<bool> deployCard({
    required ClimatePhenomenon phenomenon,
    required LGSSHClient lgClient,
    bool skipGlobalRefresh = false,
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

      final assetPath = PhenomenonIconMapper.assetPathFor(phenomenon.id);
      try {
        final byteData = await rootBundle.load(assetPath);
        final iconBytes = byteData.buffer.asUint8List();
        if (iconBytes.isNotEmpty) {
          final iconOk = await lgClient.uploadBinaryFile(
            bytes: iconBytes,
            targetPath: PhenomenonIconMapper.remotePath,
          );
          if (!iconOk) {
            debugPrint(
              'PhenomenonCard: Icon upload failed — card will render without icon.',
            );
          }
        }
      } catch (e) {
        debugPrint('PhenomenonCard: Could not load icon asset "$assetPath": $e');
      }
      const iconUrl = PhenomenonIconMapper.remoteUrl;

      final kml = PhenomenonCardKmlGenerator.generate(
        phenomenon: phenomenon,
        data: data,
        iconUrl: iconUrl,
        targetLatitude: targetLat,
        targetLongitude: targetLng,
      );

      final kmlPath = '/var/www/html/kml/slave_$rightMostScreen.kml';
      bool kmlUploaded = await lgClient.uploadFile(
        content: kml,
        targetPath: kmlPath,
      );

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

      if (!skipGlobalRefresh) {
        await lgClient.runCommand(SSHCommands.refreshKML());
      }
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
        
      }
    }

    final apiKey = await const ApiKeyStorage().getGeminiApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('PhenomenonCard: Gemini API key not configured. Using fallback summary.');
      return _buildFallbackData(phenomenon);
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
      ).timeout(const Duration(seconds: 10));
      final text = (response.text ?? '').trim();

      final cleaned = _stripCodeFences(text);
      final jsonMap = jsonDecode(cleaned) as Map<String, dynamic>;

      final data = PhenomenonCardData.fromJson(jsonMap, phenomenon.name);

      await CacheService.savePhenomenonCard(
        cacheKey,
        jsonEncode(jsonMap),
      );

      return data;
    } on TimeoutException catch (_) {
      debugPrint('PhenomenonCard: Gemini request timed out (>10s). Using fallback summary.');
      return _buildFallbackData(phenomenon);
    } on FormatException catch (e) {
      debugPrint('PhenomenonCard: Malformed Gemini JSON: $e. Using fallback summary.');
      return _buildFallbackData(phenomenon);
    } catch (e) {
      debugPrint('PhenomenonCard: Gemini error: $e. Using fallback summary.');
      return _buildFallbackData(phenomenon);
    }
  }

  PhenomenonCardData _buildFallbackData(ClimatePhenomenon phenomenon) {
    return PhenomenonCardData(
      name: phenomenon.name,
      category: 'Climate Phenomenon',
      region: 'Global Climate System',
      summary: phenomenon.fallbackSummary,
      insight: 'Telemetry active for ${phenomenon.name}.',
      keyFacts: const [
        'Immersive 3D Liquid Galaxy visualization enabled',
        'Sourced from oceanographic and atmospheric models',
        'Interactive camera orbit and tour control active',
      ],
    );
  }

  String _stripCodeFences(String text) {
    var s = text.trim();
    if (s.startsWith('```')) {
      s = s.replaceFirst(RegExp(r'^```[a-z]*\n?'), '');
      s = s.replaceFirst(RegExp(r'```$'), '');
    }
    return s.trim();
  }

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
