import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';
import 'package:lg_connection/models/climate_phenomenon_model.dart';
import 'package:lg_connection/services/ai/ai_repository.dart';
import 'package:lg_connection/shared/services/cache_service.dart';
import 'package:lg_connection/shared/services/map_sync_service.dart';
import 'package:lg_connection/shared/services/tour_service.dart';
import 'package:lg_connection/services/ai/providers/gemini_provider.dart';

/// ViewModel for the Home Screen, managing state and business logic.
class HomeViewModel extends ChangeNotifier {
  final LGSSHClient _sshClient = LGSSHClient();
  final AIRepository _aiRepository;
  final MapSyncService _mapSyncService = MapSyncService();
  final TourService _tourService = TourService();

  // Map State - Delegated to MapSyncService
  LatLng get lastTarget => _mapSyncService.lastTarget;
  double get lastZoom => _mapSyncService.lastZoom;
  double get lastTilt => _mapSyncService.lastTilt;
  double get lastBearing => _mapSyncService.lastBearing;

  ValueListenable<bool> get isConnected => _sshClient.isConnected;

  HomeViewModel(this._aiRepository) {
    _mapSyncService.addListener(notifyListeners);
  }

  /// Commands the Liquid Galaxy to orbit the current view.
  Future<void> orbit() async {
    await _sshClient.runCommand(SSHCommands.buildOrbit());
  }

  /// Clears all KML layers and stops any active tour on Liquid Galaxy.
  Future<void> clearKML() async {
    await _tourService.stopTour();
    await _sshClient.runCommand(SSHCommands.clearKML());
    await _sshClient.runCommand(SSHCommands.refreshKML());
  }

  bool _isValidExplanation(String? text) {
    if (text == null) return false;
    if (text.startsWith('Error')) return false;
    if (text == GeminiProvider.missingKeyMessage) return false;
    if (text.contains('built without a Gemini API key')) return false;
    if (text.contains('Gemini API key is not configured')) return false;
    return true;
  }

  /// Retrieves a climate explanation, using cache if available.
  Future<String> getClimateExplanation(String phenomenon) async {
    final cached = CacheService.getClimateInfo(phenomenon);
    if (_isValidExplanation(cached)) return cached!;

    final explanation = await _aiRepository.getExplanation(phenomenon);
    if (_isValidExplanation(explanation)) {
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
        assetPath: ClimatePhenomena.indianMonsoon.kmlAssetPath,
        fileName: ClimatePhenomena.indianMonsoon.fileName,
        lookAt: ClimatePhenomena.indianMonsoon.lookAtXml,
        tourKmlPath: ClimatePhenomena.indianMonsoon.tourKmlPath,
        tourName: ClimatePhenomena.indianMonsoon.tourName,
        phenomenonName: ClimatePhenomena.indianMonsoon.name,
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
        assetPath: ClimatePhenomena.kuroshioCurrent.kmlAssetPath,
        fileName: ClimatePhenomena.kuroshioCurrent.fileName,
        lookAt: ClimatePhenomena.kuroshioCurrent.lookAtXml,
        tourKmlPath: ClimatePhenomena.kuroshioCurrent.tourKmlPath,
        tourName: ClimatePhenomena.kuroshioCurrent.tourName,
        phenomenonName: ClimatePhenomena.kuroshioCurrent.name,
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
        assetPath: ClimatePhenomena.gulfStream.kmlAssetPath,
        fileName: ClimatePhenomena.gulfStream.fileName,
        lookAt: ClimatePhenomena.gulfStream.lookAtXml,
        tourKmlPath: ClimatePhenomena.gulfStream.tourKmlPath,
        tourName: ClimatePhenomena.gulfStream.tourName,
        phenomenonName: ClimatePhenomena.gulfStream.name,
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
        assetPath: ClimatePhenomena.elNino.kmlAssetPath,
        fileName: ClimatePhenomena.elNino.fileName,
        lookAt: ClimatePhenomena.elNino.lookAtXml,
        tourKmlPath: ClimatePhenomena.elNino.tourKmlPath,
        tourName: ClimatePhenomena.elNino.tourName,
        phenomenonName: ClimatePhenomena.elNino.name,
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
        assetPath: ClimatePhenomena.laNina.kmlAssetPath,
        fileName: ClimatePhenomena.laNina.fileName,
        lookAt: ClimatePhenomena.laNina.lookAtXml,
        tourKmlPath: ClimatePhenomena.laNina.tourKmlPath,
        tourName: ClimatePhenomena.laNina.tourName,
        phenomenonName: ClimatePhenomena.laNina.name,
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
        assetPath: ClimatePhenomena.mumbaiMonsoon.kmlAssetPath,
        fileName: ClimatePhenomena.mumbaiMonsoon.fileName,
        lookAt: ClimatePhenomena.mumbaiMonsoon.lookAtXml,
        tourKmlPath: ClimatePhenomena.mumbaiMonsoon.tourKmlPath,
        tourName: ClimatePhenomena.mumbaiMonsoon.tourName,
        phenomenonName: ClimatePhenomena.mumbaiMonsoon.name,
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

  /// Orchestrates the sequence:
  /// 1. Stop active tour & clear old KML
  /// 2. Upload visualization KML
  /// 3. Upload tour KML
  /// 4. Register both KMLs in kmls.txt & refresh
  /// 5. Fly camera to region LookAt
  /// 6. Initiate Gemini summary generation
  /// 7. Automatically start tour playback
  Future<void> _runVisualizationSequence({
    required String assetPath,
    required String fileName,
    required String lookAt,
    required String tourKmlPath,
    required String tourName,
    String? phenomenonName,
  }) async {
    await _tourService.stopTour();
    await Future.delayed(const Duration(milliseconds: 150));
    await _sshClient.runCommand(SSHCommands.clearKML());
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Upload Visualization KML
    final kmlContent = await rootBundle.loadString(assetPath);
    await _sshClient.uploadFile(
      content: kmlContent,
      targetPath: '/var/www/html/$fileName',
    );

    // Upload Tour KML
    final tourFileName = tourKmlPath.split('/').last;
    final tourContent = await rootBundle.loadString(tourKmlPath);
    await _sshClient.uploadFile(
      content: tourContent,
      targetPath: '/var/www/html/$tourFileName',
    );
    
    // Register both visualization KML and tour KML in kmls.txt
    await _sshClient.runCommand(SSHCommands.setKMLs([fileName, tourFileName]));
    await _sshClient.runCommand(SSHCommands.refreshKML());
    
    // Fly to position
    await Future.delayed(const Duration(milliseconds: 500));
    await _mapSyncService.flyToLookAt(lookAt);

    // Start Gemini summary generation asynchronously
    if (phenomenonName != null) {
      getClimateExplanation(phenomenonName);
    }

    // Automatically trigger tour playback after camera stabilization
    await Future.delayed(const Duration(milliseconds: 1000));
    await _sshClient.runCommand(SSHCommands.playTour(tourName));
  }

  @override
  void dispose() {
    _mapSyncService.removeListener(notifyListeners);
    super.dispose();
  }
}
