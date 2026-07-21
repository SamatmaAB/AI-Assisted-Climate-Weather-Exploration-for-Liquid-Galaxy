import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';
import 'package:lg_connection/shared/services/map_sync_service.dart';

/// ViewModel for managing dashboard and category-specific actions.
class DashboardViewModel extends ChangeNotifier {
  final LGSSHClient _sshClient = LGSSHClient();
  final MapSyncService _mapSyncService = MapSyncService();

  /// Visualizes the Indian Monsoon on Liquid Galaxy.
  Future<void> visualizeIndianMonsoon() async {
    await _runVisualizationSequence(
      assetPath: 'assets/kml/indian_monsoon.kml',
      fileName: 'indian_monsoon.kml',
      lookAt: '<LookAt><longitude>78.9629</longitude><latitude>20.5937</latitude><altitude>0</altitude><heading>0</heading><tilt>45</tilt><range>5000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>',
    );
  }

  /// Visualizes the Kuroshio Current on Liquid Galaxy.
  Future<void> visualizeKuroshioCurrent() async {
    await _runVisualizationSequence(
      assetPath: 'assets/kml/kuroshio_current.kml',
      fileName: 'kuroshio_current.kml',
      lookAt: '<LookAt><longitude>135.0</longitude><latitude>35.0</latitude><altitude>0</altitude><heading>0</heading><tilt>30</tilt><range>4000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>',
    );
  }

  /// Visualizes El Niño on Liquid Galaxy.
  Future<void> visualizeElNino() async {
    await _runVisualizationSequence(
      assetPath: 'assets/kml/el_nino.kml',
      fileName: 'el_nino.kml',
      lookAt: '<LookAt><longitude>-160.0</longitude><latitude>0.0</latitude><altitude>0</altitude><heading>0</heading><tilt>30</tilt><range>10000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>',
    );
  }

  /// Visualizes La Niña on Liquid Galaxy.
  Future<void> visualizeLaNina() async {
    await _runVisualizationSequence(
      assetPath: 'assets/kml/la_nina.kml',
      fileName: 'la_nina.kml',
      lookAt: '<LookAt><longitude>-160.0</longitude><latitude>0.0</latitude><altitude>0</altitude><heading>0</heading><tilt>30</tilt><range>10000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>',
    );
  }

  /// Visualizes Mumbai Monsoon on Liquid Galaxy.
  Future<void> visualizeMumbaiMonsoon() async {
    await _runVisualizationSequence(
      assetPath: 'assets/kml/mumbai_monsoon.kml',
      fileName: 'mumbai_monsoon.kml',
      lookAt: '<LookAt><longitude>72.834654</longitude><latitude>18.921984</latitude><altitude>0</altitude><heading>0</heading><tilt>65</tilt><range>4000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>',
    );
  }

  /// Commands the rig to fly to a specific KML LookAt string.
  Future<void> flyTo(String lookAt) async {
    await _mapSyncService.flyToLookAt(lookAt);
  }

  /// Clears all KML layers from the rig.
  Future<void> clearKML() async {
    await _sshClient.runCommand(SSHCommands.clearKML());
    await _sshClient.runCommand(SSHCommands.refreshKML());
  }

  /// Shared sequence for preparing the rig and uploading KMLs.
  Future<void> _runVisualizationSequence({
    required String assetPath,
    required String fileName,
    required String lookAt,
  }) async {
    await _sshClient.runCommand(SSHCommands.stopTour());
    await Future.delayed(const Duration(milliseconds: 200));
    await _sshClient.runCommand(SSHCommands.clearKML());
    await Future.delayed(const Duration(milliseconds: 100));
    
    final kmlContent = await rootBundle.loadString(assetPath);
    await _sshClient.uploadFile(
      content: kmlContent,
      targetPath: '/var/www/html/$fileName',
    );
    
    await _sshClient.runCommand(SSHCommands.setKML(fileName));
    await _sshClient.runCommand(SSHCommands.refreshKML());
    
    await Future.delayed(const Duration(milliseconds: 500));
    await _mapSyncService.flyToLookAt(lookAt);
  }
}
