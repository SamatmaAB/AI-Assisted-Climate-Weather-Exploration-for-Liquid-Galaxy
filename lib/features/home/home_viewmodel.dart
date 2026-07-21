import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';
import 'package:lg_connection/shared/services/ai_service.dart';
import 'package:lg_connection/shared/services/cache_service.dart';
import 'package:lg_connection/shared/services/map_sync_service.dart';

/// ViewModel for the Home Screen, managing state and business logic.
class HomeViewModel extends ChangeNotifier {
  final LGSSHClient _sshClient = LGSSHClient();
  final AIService _aiService = AIService();
  final MapSyncService _mapSyncService = MapSyncService();

  // Map State - Delegated to MapSyncService
  LatLng get lastTarget => _mapSyncService.lastTarget;
  double get lastZoom => _mapSyncService.lastZoom;
  double get lastTilt => _mapSyncService.lastTilt;
  double get lastBearing => _mapSyncService.lastBearing;

  ValueListenable<bool> get isConnected => _sshClient.isConnected;

  HomeViewModel() {
    _mapSyncService.addListener(notifyListeners);
  }

  /// Commands the Liquid Galaxy to orbit the current view.
  Future<void> orbit() async {
    await _sshClient.runCommand(SSHCommands.buildOrbit());
  }

  /// Clears all KML layers from the Liquid Galaxy.
  Future<void> clearKML() async {
    await _sshClient.runCommand(SSHCommands.clearKML());
    await _sshClient.runCommand(SSHCommands.refreshKML());
  }

  /// Retrieves a climate explanation, using cache if available.
  Future<String> getClimateExplanation(String phenomenon) async {
    final cached = CacheService.getClimateInfo(phenomenon);
    // If we have a valid cached description (not a cached error message), return it
    if (cached != null && !cached.startsWith('Error')) return cached;

    final explanation = await _aiService.getExplanation(phenomenon);
    if (!explanation.startsWith('Error')) {
      await CacheService.saveClimateInfo(phenomenon, explanation);
    }
    return explanation;
  }

  // --- Visualization Actions ---

  Future<void> visualizeIndianMonsoon() async {
    isVisualisingMonsoon = true;
    notifyListeners();
    try {
      await _runVisualizationSequence(
        assetPath: 'assets/kml/indian_monsoon.kml',
        fileName: 'indian_monsoon.kml',
        lookAt: '<LookAt><longitude>78.9629</longitude><latitude>20.5937</latitude><altitude>0</altitude><heading>0</heading><tilt>45</tilt><range>5000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>',
      );
    } finally {
      isVisualisingMonsoon = false;
      notifyListeners();
    }
  }

  Future<void> visualizeKuroshioCurrent() async {
    isVisualisingKuroshio = true;
    notifyListeners();
    try {
      await _runVisualizationSequence(
        assetPath: 'assets/kml/kuroshio_current.kml',
        fileName: 'kuroshio_current.kml',
        lookAt: '<LookAt><longitude>135.0</longitude><latitude>35.0</latitude><altitude>0</altitude><heading>0</heading><tilt>30</tilt><range>4000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>',
      );
    } finally {
      isVisualisingKuroshio = false;
      notifyListeners();
    }
  }

  Future<void> visualizeGulfStream() async {
    isVisualisingGulfStream = true;
    notifyListeners();
    try {
      await _runVisualizationSequence(
        assetPath: 'assets/kml/gulf_stream.kml',
        fileName: 'gulf_stream.kml',
        lookAt: '<LookAt><longitude>-50.0</longitude><latitude>40.0</latitude><altitude>0</altitude><heading>0</heading><tilt>35</tilt><range>7000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>',
      );
    } finally {
      isVisualisingGulfStream = false;
      notifyListeners();
    }
  }

  Future<void> visualizeElNino() async {
    isVisualisingElNino = true;
    notifyListeners();
    try {
      await _runVisualizationSequence(
        assetPath: 'assets/kml/el_nino.kml',
        fileName: 'el_nino.kml',
        lookAt: '<LookAt><longitude>-160.0</longitude><latitude>0.0</latitude><altitude>0</altitude><heading>0</heading><tilt>30</tilt><range>10000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>',
      );
    } finally {
      isVisualisingElNino = false;
      notifyListeners();
    }
  }

  Future<void> visualizeLaNina() async {
    isVisualisingLaNina = true;
    notifyListeners();
    try {
      await _runVisualizationSequence(
        assetPath: 'assets/kml/la_nina.kml',
        fileName: 'la_nina.kml',
        lookAt: '<LookAt><longitude>-160.0</longitude><latitude>0.0</latitude><altitude>0</altitude><heading>0</heading><tilt>30</tilt><range>10000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>',
      );
    } finally {
      isVisualisingLaNina = false;
      notifyListeners();
    }
  }

  Future<void> visualizeMumbaiMonsoon() async {
    isVisualisingMumbaiMonsoon = true;
    notifyListeners();
    try {
      await _runVisualizationSequence(
        assetPath: 'assets/kml/mumbai_monsoon.kml',
        fileName: 'mumbai_monsoon.kml',
        lookAt: '<LookAt><longitude>72.834654</longitude><latitude>18.921984</latitude><altitude>0</altitude><heading>0</heading><tilt>65</tilt><range>4000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>',
      );
    } finally {
      isVisualisingMumbaiMonsoon = false;
      notifyListeners();
    }
  }

  // Loading States for Visualizations
  bool isVisualisingMonsoon = false;
  bool isVisualisingKuroshio = false;
  bool isVisualisingGulfStream = false;
  bool isVisualisingElNino = false;
  bool isVisualisingLaNina = false;
  bool isVisualisingMumbaiMonsoon = false;

  /// Orchestrates the process of stopping tours, clearing old KMLs, uploading new ones, and flying to the location.
  Future<void> _runVisualizationSequence({
    required String assetPath,
    required String fileName,
    required String lookAt,
  }) async {
    await _sshClient.runCommand(SSHCommands.stopTour());
    await Future.delayed(const Duration(milliseconds: 200));
    await _sshClient.runCommand(SSHCommands.clearKML());
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Upload KML
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

  @override
  void dispose() {
    _mapSyncService.removeListener(notifyListeners);
    super.dispose();
  }
}
