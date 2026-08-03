import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';
import 'package:lg_connection/models/climate_phenomenon_model.dart';
import 'package:lg_connection/services/ai/ai_repository.dart';
import 'package:lg_connection/shared/services/cache_service.dart';
import 'package:lg_connection/shared/services/map_sync_service.dart';
import 'package:lg_connection/shared/services/tour_service.dart';

import 'package:lg_connection/services/ai/providers/gemini_provider.dart';

/// ViewModel for managing dashboard climate phenomenon selection, Liquid Galaxy visualization,
/// AI explanation generation, and automatic tour playback.
class DashboardViewModel extends ChangeNotifier {
  final LGSSHClient _sshClient = LGSSHClient();
  final MapSyncService _mapSyncService = MapSyncService();
  final TourService _tourService = TourService();
  final AIRepository _aiRepository;

  DashboardViewModel(this._aiRepository);

  bool isVisualizing = false;
  String activePhenomenonName = '';
  String currentExplanation = '';

  bool _isValidExplanation(String? text) {
    if (text == null) return false;
    if (text.startsWith('Error')) return false;
    if (text == GeminiProvider.missingKeyMessage) return false;
    if (text.contains('built without a Gemini API key')) return false;
    if (text.contains('Gemini API key is not configured')) return false;
    return true;
  }

  /// Retrieves a climate explanation using Gemini AI, with local Hive caching.
  Future<String> getClimateExplanation(String phenomenonName) async {
    final cached = CacheService.getClimateInfo(phenomenonName);
    if (_isValidExplanation(cached)) {
      currentExplanation = cached!;
      notifyListeners();
      return cached;
    }

    final explanation = await _aiRepository.getExplanation(phenomenonName);
    if (_isValidExplanation(explanation)) {
      await CacheService.saveClimateInfo(phenomenonName, explanation);
    }
    currentExplanation = explanation;
    notifyListeners();
    return explanation;
  }

  /// Triggers the full phenomenon selection workflow:
  /// 1. Load & upload visualization KML
  /// 2. Initiate Gemini summary generation
  /// 3. Upload & automatically launch tour KML
  Future<void> visualizePhenomenon(ClimatePhenomenon phenomenon) async {
    isVisualizing = true;
    activePhenomenonName = phenomenon.name;
    notifyListeners();

    try {
      await _runVisualizationSequence(
        assetPath: phenomenon.kmlAssetPath,
        fileName: phenomenon.fileName,
        lookAt: phenomenon.lookAtXml,
        tourKmlPath: phenomenon.tourKmlPath,
        tourName: phenomenon.tourName,
        phenomenonName: phenomenon.name,
      );
    } finally {
      isVisualizing = false;
      notifyListeners();
    }
  }

  /// Visualizes the Indian Monsoon on Liquid Galaxy.
  Future<void> visualizeIndianMonsoon() async {
    await visualizePhenomenon(ClimatePhenomena.indianMonsoon);
  }

  /// Visualizes the Kuroshio Current on Liquid Galaxy.
  Future<void> visualizeKuroshioCurrent() async {
    await visualizePhenomenon(ClimatePhenomena.kuroshioCurrent);
  }

  /// Visualizes El Niño on Liquid Galaxy.
  Future<void> visualizeElNino() async {
    await visualizePhenomenon(ClimatePhenomena.elNino);
  }

  /// Visualizes La Niña on Liquid Galaxy.
  Future<void> visualizeLaNina() async {
    await visualizePhenomenon(ClimatePhenomena.laNina);
  }

  /// Visualizes Gulf Stream on Liquid Galaxy.
  Future<void> visualizeGulfStream() async {
    await visualizePhenomenon(ClimatePhenomena.gulfStream);
  }

  /// Visualizes Mumbai Monsoon on Liquid Galaxy.
  Future<void> visualizeMumbaiMonsoon() async {
    await visualizePhenomenon(ClimatePhenomena.mumbaiMonsoon);
  }

  /// Commands the rig to fly to a specific KML LookAt string.
  Future<void> flyTo(String lookAt) async {
    await _mapSyncService.flyToLookAt(lookAt);
  }

  /// Clears all KML layers and stops any active tour on the rig.
  Future<void> clearKML() async {
    await _tourService.stopTour();
    await _sshClient.runCommand(SSHCommands.clearKML());
    await _sshClient.runCommand(SSHCommands.refreshKML());
  }

  /// Shared sequence for uploading KML, starting Gemini AI generation,
  /// flying to location, and automatically triggering tour execution.
  Future<void> _runVisualizationSequence({
    required String assetPath,
    required String fileName,
    required String lookAt,
    required String tourKmlPath,
    required String tourName,
    String? phenomenonName,
  }) async {
    // Step 1: Stop active tour & clear old KML
    await _tourService.stopTour();
    await Future.delayed(const Duration(milliseconds: 150));
    await _sshClient.runCommand(SSHCommands.clearKML());
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Step 2: Load & upload Visualization KML asset
    final kmlContent = await rootBundle.loadString(assetPath);
    await _sshClient.uploadFile(
      content: kmlContent,
      targetPath: '/var/www/html/$fileName',
    );

    // Step 3: Load & upload Tour KML asset
    final tourFileName = tourKmlPath.split('/').last;
    final tourContent = await rootBundle.loadString(tourKmlPath);
    await _sshClient.uploadFile(
      content: tourContent,
      targetPath: '/var/www/html/$tourFileName',
    );
    
    // Step 4: Register both visualization KML and tour KML in kmls.txt and refresh rig
    await _sshClient.runCommand(SSHCommands.setKMLs([fileName, tourFileName]));
    await _sshClient.runCommand(SSHCommands.refreshKML());
    
    // Step 5: Fly camera to target region
    await Future.delayed(const Duration(milliseconds: 500));
    await _mapSyncService.flyToLookAt(lookAt);

    // Step 6: Gemini summary generation starts
    if (phenomenonName != null) {
      getClimateExplanation(phenomenonName);
    }

    // Step 7: Tour KML automatically starts after camera stabilization
    await Future.delayed(const Duration(milliseconds: 1000));
    await _sshClient.runCommand(SSHCommands.playTour(tourName));
  }
}
