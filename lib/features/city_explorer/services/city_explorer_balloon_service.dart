import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';
import 'package:lg_connection/features/city_explorer/models/city_landmark.dart';
import 'package:lg_connection/features/city_explorer/models/weather_data.dart';
import 'package:lg_connection/features/city_explorer/utils/city_explorer_balloon_kml_generator.dart';
import 'package:lg_connection/features/city_explorer/utils/weather_icon_mapper.dart';

/// Orchestrates the full City Explorer balloon pipeline on the Liquid Galaxy.
///
/// Responsibilities:
///   1. Map the WMO weather code to the correct local icon asset.
///   2. Load the icon binary from the Flutter asset bundle.
///   3. Upload the icon PNG to the LG web server (binary SFTP).
///   4. Generate the balloon KML via [CityExplorerBalloonKmlGenerator].
///   5. Write the KML to `slave_<rightMostScreen>.kml` on the LG rig.
///   6. Refresh only the rightmost screen.
///
/// Also provides [clearBalloon] to remove the balloon when a new city is
/// searched, preventing stale content from remaining visible.
///
/// This service only uses infrastructure that already exists in the project:
///   • [LGSSHClient.uploadBinaryFile]
///   • [LGSSHClient.uploadFile]
///   • [LGSSHClient.forceRefresh]
///   • [LGSSHClient.runCommand]
///   • [SSHCommands.calculateRightMostScreen]
///   • [SSHCommands.clearScreen]
class CityExplorerBalloonService {
  CityExplorerBalloonService._();

  static final CityExplorerBalloonService _instance =
      CityExplorerBalloonService._();
  factory CityExplorerBalloonService() => _instance;

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Deploys the details balloon for [landmark] + [weather] + [narration] to
  /// the rightmost LG screen.
  ///
  /// Returns `true` when the balloon was successfully deployed.
  /// Failures are caught and logged; they do not propagate to the caller.
  Future<bool> deployBalloon({
    required CityLandmark landmark,
    required WeatherData weather,
    required String narration,
    required LGSSHClient lgClient,
  }) async {
    try {
      final screens = lgClient.numberOfRigs;
      final rightMostScreen = SSHCommands.calculateRightMostScreen(screens);

      // ── 1. Determine asset path for this weather code ──────────────────
      final assetPath = WeatherIconMapper.assetPathFor(weather.weatherCode);
      debugPrint(
        'CityExplorerBalloon: weatherCode=${weather.weatherCode} → $assetPath',
      );

      // ── 2. Load icon bytes from Flutter asset bundle ───────────────────
      Uint8List iconBytes;
      try {
        final byteData = await rootBundle.load(assetPath);
        iconBytes = byteData.buffer.asUint8List();
      } catch (e) {
        debugPrint(
          'CityExplorerBalloon: Could not load icon asset "$assetPath": $e',
        );
        // Fall back to cloudy icon
        try {
          final byteData =
              await rootBundle.load('assets/weather_icons/cloudy.png');
          iconBytes = byteData.buffer.asUint8List();
        } catch (e2) {
          debugPrint(
            'CityExplorerBalloon: Fallback icon load also failed: $e2',
          );
          iconBytes = Uint8List(0);
        }
      }

      // ── 3. Upload icon binary to LG web server ─────────────────────────
      bool iconUploaded = false;
      if (iconBytes.isNotEmpty) {
        iconUploaded = await lgClient.uploadBinaryFile(
          bytes: iconBytes,
          targetPath: WeatherIconMapper.remotePath,
        );
        if (!iconUploaded) {
          debugPrint(
            'CityExplorerBalloon: Icon upload failed — balloon will display '
            'without weather icon.',
          );
        }
      }

      // ── 4. Build the icon URL ──────────────────────────────────────────
      // Even if the upload failed we still embed the URL in the KML so
      // Google Earth will attempt to load it (it may succeed later from cache).
      const iconUrl = WeatherIconMapper.remoteUrl;

      // ── 5. Calculate rightmost screen center coordinates & Generate KML ──
      double? targetLat;
      double? targetLng;
      if (screens > 1) {
        final offset = _calculateRightScreenCoordinates(
          lat: landmark.latitude,
          lng: landmark.longitude,
        );
        targetLat = offset['latitude'];
        targetLng = offset['longitude'];
      }

      final kml = CityExplorerBalloonKmlGenerator.generate(
        landmark: landmark,
        weather: weather,
        iconUrl: iconUrl,
        narration: narration,
        targetLatitude: targetLat,
        targetLongitude: targetLng,
      );

      // ── 6. Upload KML to slave_<rightMostScreen>.kml ───────────────────
      final kmlPath =
          '/var/www/html/kml/slave_$rightMostScreen.kml';
      bool kmlUploaded = await lgClient.uploadFile(
        content: kml,
        targetPath: kmlPath,
      );

      // Fallback: If SFTP upload failed, attempt upload via SSH echo command
      // (same mechanism as SSHCommands.sendLogoToScreen).
      if (!kmlUploaded) {
        debugPrint(
          'CityExplorerBalloon: SFTP upload failed for $kmlPath, trying SSH echo fallback...',
        );
        kmlUploaded = await lgClient.runCommand(
          "echo '${kml.replaceAll("'", "'\\''")}' > $kmlPath",
        );
      }

      if (!kmlUploaded) {
        debugPrint(
          'CityExplorerBalloon: KML upload failed for $kmlPath',
        );
        return false;
      }

      debugPrint(
        'CityExplorerBalloon: KML uploaded to $kmlPath '
        '(screen $rightMostScreen of $screens)',
      );

      // ── 7. Refresh the rightmost screen ────────────────────────────────
      await lgClient.runCommand(SSHCommands.refreshKML());
      await lgClient.forceRefresh(rightMostScreen);

      debugPrint(
        'CityExplorerBalloon: Balloon deployed on screen $rightMostScreen.',
      );
      return true;
    } catch (e) {
      debugPrint('CityExplorerBalloon: Unexpected error during deploy: $e');
      return false;
    }
  }

  /// Clears the balloon from the rightmost LG screen by writing an empty KML
  /// document to the slave file.
  ///
  /// Should be called at the beginning of each new city exploration so stale
  /// balloon content is removed before the new one is ready.
  Future<void> clearBalloon(LGSSHClient lgClient) async {
    try {
      final screens = lgClient.numberOfRigs;
      final rightMostScreen = SSHCommands.calculateRightMostScreen(screens);

      final cleared = await lgClient.runCommand(
        SSHCommands.clearScreen(rightMostScreen),
      );

      if (cleared) {
        debugPrint(
          'CityExplorerBalloon: Cleared slave_$rightMostScreen.kml.',
        );
        await lgClient.forceRefresh(rightMostScreen);
      } else {
        debugPrint(
          'CityExplorerBalloon: clearScreen command failed for screen '
          '$rightMostScreen.',
        );
      }
    } catch (e) {
      debugPrint('CityExplorerBalloon: clearBalloon error: $e');
    }
  }

  /// Calculates coordinates shifted towards the center of the rightmost LG screen.
  ///
  /// In Liquid Galaxy, screen 1/2 is centered at the landmark coordinates.
  /// The right screen (slave_N) is rotated clockwise to the right.
  /// Offset is calculated perpendicular to camera approach bearing (30° + 90° = 120°).
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
