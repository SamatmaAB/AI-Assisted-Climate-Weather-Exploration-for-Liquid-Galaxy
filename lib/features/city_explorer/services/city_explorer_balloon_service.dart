import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';
import 'package:lg_connection/features/city_explorer/models/city_landmark.dart';
import 'package:lg_connection/features/city_explorer/models/weather_data.dart';
import 'package:lg_connection/features/city_explorer/utils/city_explorer_balloon_kml_generator.dart';
import 'package:lg_connection/features/city_explorer/utils/weather_icon_mapper.dart';

class CityExplorerBalloonService {
  CityExplorerBalloonService._();

  static final CityExplorerBalloonService _instance =
      CityExplorerBalloonService._();
  factory CityExplorerBalloonService() => _instance;

  Future<bool> deployBalloon({
    required CityLandmark landmark,
    required WeatherData weather,
    required String narration,
    required LGSSHClient lgClient,
  }) async {
    try {
      final screens = lgClient.numberOfRigs;
      final rightMostScreen = SSHCommands.calculateRightMostScreen(screens);

      final assetPath = WeatherIconMapper.assetPathFor(weather.weatherCode);
      debugPrint(
        'CityExplorerBalloon: weatherCode=${weather.weatherCode} → $assetPath',
      );

      Uint8List iconBytes;
      try {
        final byteData = await rootBundle.load(assetPath);
        iconBytes = byteData.buffer.asUint8List();
      } catch (e) {
        debugPrint(
          'CityExplorerBalloon: Could not load icon asset "$assetPath": $e',
        );
        
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

      const iconUrl = WeatherIconMapper.remoteUrl;

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

      final kmlPath =
          '/var/www/html/kml/slave_$rightMostScreen.kml';
      bool kmlUploaded = await lgClient.uploadFile(
        content: kml,
        targetPath: kmlPath,
      );

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
