import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';
import 'package:lg_connection/shared/services/ai_service.dart';
import 'package:lg_connection/shared/services/cache_service.dart';

/// ViewModel for the Home Screen, managing state and business logic.
class HomeViewModel extends ChangeNotifier {
  final LGSSHClient _sshClient = LGSSHClient();
  final AIService _aiService = AIService();

  // Map State
  LatLng lastTarget = const LatLng(20.5937, 78.9629);
  double lastZoom = 4;
  double lastTilt = 0;
  double lastBearing = 0;
  Timer? _debounce;

  // Loading States for Visualizations
  bool isVisualisingMonsoon = false;
  bool isVisualisingKuroshio = false;
  bool isVisualisingGulfStream = false;

  ValueListenable<bool> get isConnected => _sshClient.isConnected;

  /// Updates the camera position and triggers a debounced sync to Liquid Galaxy.
  void updateCameraPosition(CameraPosition position) {
    lastTarget = position.target;
    lastZoom = position.zoom;
    lastTilt = position.tilt;
    lastBearing = position.bearing;
    _syncToLG();
  }

  void _syncToLG() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _sshClient.runCommand(
        SSHCommands.flyToCoordinates(
          lastTarget.latitude,
          lastTarget.longitude,
          lastZoom,
          lastTilt,
          lastBearing,
        ),
      );
    });
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
    // In original code, it was uploaded to /var/www/html/ and also kmls.txt was updated.
    // Replicating that behavior via LGSSHClient.
    await _sshClient.uploadFile(
      content: kmlContent,
      targetPath: '/var/www/html/$fileName',
    );
    
    await _sshClient.runCommand(SSHCommands.setKML(fileName));
    await _sshClient.runCommand(SSHCommands.refreshKML());
    
    await Future.delayed(const Duration(milliseconds: 500));
    await _sshClient.runCommand(SSHCommands.flyTo(lookAt));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
