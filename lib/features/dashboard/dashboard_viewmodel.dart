import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';
import 'package:lg_connection/models/climate_phenomenon_model.dart';
import 'package:lg_connection/services/ai/ai_repository.dart';
import 'package:lg_connection/shared/services/cache_service.dart';
import 'package:lg_connection/shared/services/map_sync_service.dart';
import 'package:lg_connection/shared/services/tour_service.dart';
import 'package:lg_connection/features/phenomena/services/phenomenon_card_service.dart';

import 'package:lg_connection/services/ai/providers/gemini_provider.dart';

class DashboardViewModel extends ChangeNotifier {
  final LGSSHClient _sshClient = LGSSHClient();
  final MapSyncService _mapSyncService = MapSyncService();
  final TourService _tourService = TourService();
  final PhenomenonCardService _phenomenonCardService = PhenomenonCardService();
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

  Future<void> visualizePhenomenon(ClimatePhenomenon phenomenon) async {
    isVisualizing = true;
    activePhenomenonName = phenomenon.name;
    notifyListeners();

    try {
      await _runVisualizationSequence(
        phenomenon: phenomenon,
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

  Future<void> visualizeIndianMonsoon() async {
    await visualizePhenomenon(ClimatePhenomena.indianMonsoon);
  }

  Future<void> visualizeKuroshioCurrent() async {
    await visualizePhenomenon(ClimatePhenomena.kuroshioCurrent);
  }

  Future<void> visualizeElNino() async {
    await visualizePhenomenon(ClimatePhenomena.elNino);
  }

  Future<void> visualizeLaNina() async {
    await visualizePhenomenon(ClimatePhenomena.laNina);
  }

  Future<void> visualizeGulfStream() async {
    await visualizePhenomenon(ClimatePhenomena.gulfStream);
  }

  Future<void> visualizeMumbaiMonsoon() async {
    await visualizePhenomenon(ClimatePhenomena.mumbaiMonsoon);
  }

  Future<void> flyTo(String lookAt) async {
    await _mapSyncService.flyToLookAt(lookAt);
  }

  Future<void> clearKML() async {
    await _tourService.stopTour();
    _phenomenonCardService.clearCard(_sshClient);
    await _sshClient.runCommand(SSHCommands.clearKML());
    await _sshClient.runCommand(SSHCommands.refreshKML());
  }

  Future<void> _runVisualizationSequence({
    required ClimatePhenomenon phenomenon,
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

    final kmlContent = await rootBundle.loadString(assetPath);
    await _sshClient.uploadFile(
      content: kmlContent,
      targetPath: '/var/www/html/$fileName',
    );

    final tourFileName = tourKmlPath.split('/').last;
    final tourContent = await rootBundle.loadString(tourKmlPath);
    await _sshClient.uploadFile(
      content: tourContent,
      targetPath: '/var/www/html/$tourFileName',
    );

    await _sshClient.runCommand(SSHCommands.setKMLs([fileName, tourFileName]));
    await _sshClient.runCommand(SSHCommands.refreshKML());

    await Future.delayed(const Duration(milliseconds: 500));
    await _mapSyncService.flyToLookAt(lookAt);

    // Deploy the details card to the rightmost LG screen (Gemini-sourced).
    _phenomenonCardService.deployCard(
      phenomenon: phenomenon,
      lgClient: _sshClient,
    );

    if (phenomenonName != null) {
      getClimateExplanation(phenomenonName);
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    await _sshClient.runCommand(SSHCommands.playTour(tourName));
  }
}
