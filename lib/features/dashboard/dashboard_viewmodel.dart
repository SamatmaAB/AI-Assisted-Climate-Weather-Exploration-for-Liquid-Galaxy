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

import 'package:lg_connection/shared/services/visualization_publisher.dart';

class DashboardViewModel extends ChangeNotifier {
  final LGSSHClient _sshClient = LGSSHClient();
  final MapSyncService _mapSyncService = MapSyncService();
  final TourService _tourService = TourService();
  final PhenomenonCardService _phenomenonCardService = PhenomenonCardService();
  final VisualizationPublisher _visualizationPublisher = VisualizationPublisher();
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

    final explanation = await _aiRepository
        .getExplanation(phenomenonName)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => ClimatePhenomena.getFallbackSummary(phenomenonName),
        );
    if (_isValidExplanation(explanation)) {
      await CacheService.saveClimateInfo(phenomenonName, explanation);
      currentExplanation = explanation;
    } else {
      currentExplanation = ClimatePhenomena.getFallbackSummary(phenomenonName);
    }
    notifyListeners();
    return currentExplanation;
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

  Future<void> flyTo(String lookAt) async {
    await _mapSyncService.flyToLookAt(lookAt);
  }

  Future<void> clearKML() async {
    await _tourService.stopTour();
    await _phenomenonCardService.clearCard(_sshClient);
    await _sshClient.runCommand(SSHCommands.clearKML());
    await _sshClient.runCommand(SSHCommands.refreshKML());
    await _sshClient.forceRefresh(1);
  }

  Future<bool> _retryCommand(
    String command, {
    int maxRetries = 2,
    Duration retryDelay = const Duration(milliseconds: 300),
  }) async {
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      final ok = await _sshClient.runCommand(command);
      if (ok) return true;
      if (attempt < maxRetries) {
        debugPrint(
          'DashboardViewModel: Command failed (attempt ${attempt + 1}/$maxRetries), '
          'retrying in ${retryDelay.inMilliseconds}ms…',
        );
        await Future.delayed(retryDelay);
      }
    }
    return false;
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
    await Future.delayed(const Duration(milliseconds: 300));

    await _phenomenonCardService.clearCard(_sshClient);

    await _retryCommand(SSHCommands.clearAndRefreshKML());
    await _sshClient.forceRefresh(1);

    final assetFutures = Future.wait([
      rootBundle.loadString(assetPath),
      rootBundle.loadString(tourKmlPath),
    ]);
    await Future.delayed(const Duration(milliseconds: 800));
    final assets = await assetFutures;
    final kmlContent = assets[0];
    final tourContent = assets[1];

    final tourFileName = tourKmlPath.split('/').last;

    final published = await _visualizationPublisher.publishVisualizationKML(
      kmlContent: kmlContent,
      tourKmlContent: tourContent,
      tourFileName: tourFileName,
    );

    if (!published) {
      debugPrint(
        'DashboardViewModel: Visualization publication failed — aborting.',
      );
      return;
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    _mapSyncService.updateMapPositionFromLookAt(lookAt);

    _phenomenonCardService.deployCard(
      phenomenon: phenomenon,
      lgClient: _sshClient,
      skipGlobalRefresh: true,
    );

    if (phenomenonName != null) {
      getClimateExplanation(phenomenonName);
    }

    await Future.delayed(const Duration(milliseconds: 500));
    final tourStarted = await _retryCommand(SSHCommands.playTour(tourName));

    if (!tourStarted) {
      debugPrint(
        'DashboardViewModel: playTour failed — re-sending refresh + playTour.',
      );
      await _retryCommand(SSHCommands.refreshKML());
      await Future.delayed(const Duration(milliseconds: 800));
      await _retryCommand(SSHCommands.playTour(tourName));
    }
  }
}
