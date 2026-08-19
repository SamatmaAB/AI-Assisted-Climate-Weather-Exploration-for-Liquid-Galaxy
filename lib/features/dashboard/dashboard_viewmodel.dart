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

  /// Retries an SSH command up to [maxRetries] times with a delay between
  /// attempts. Returns true if the command eventually succeeds.
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

    // ── Phase 1: Unload previous visualization + pre-load assets in parallel ──
    await _tourService.stopTour();
    await Future.delayed(const Duration(milliseconds: 300));

    // Clear old card from slave screen.
    await _phenomenonCardService.clearCard(_sshClient);

    // [C] Batch: clear kmls.txt + refreshkml in one SSH round-trip.
    await _retryCommand(SSHCommands.clearAndRefreshKML());
    await _sshClient.forceRefresh(1);

    // [A] Pre-load both asset strings from the bundle DURING the GE unload wait.
    final assetFutures = Future.wait([
      rootBundle.loadString(assetPath),
      rootBundle.loadString(tourKmlPath),
    ]);
    await Future.delayed(const Duration(milliseconds: 800));
    final assets = await assetFutures;
    final kmlContent = assets[0];
    final tourContent = assets[1];

    // ── Phase 2: Upload both KMLs in parallel, then load ──
    final tourFileName = tourKmlPath.split('/').last;


    // Upload KMLs sequentially (SSH only supports one SFTP channel at a time).
    final uploaded = await _sshClient.uploadFile(
      content: kmlContent,
      targetPath: '/var/www/html/$fileName',
    );
    if (!uploaded) {
      debugPrint(
        'DashboardViewModel: KML upload failed for $fileName — aborting.',
      );
      return;
    }

    final tourUploaded = await _sshClient.uploadFile(
      content: tourContent,
      targetPath: '/var/www/html/$tourFileName',
    );
    if (!tourUploaded) {
      debugPrint(
        'DashboardViewModel: Tour KML upload failed for $tourFileName — aborting.',
      );
      return;
    }

    // [C] Batch: setKMLs + refreshkml in one SSH round-trip.
    final setOk = await _retryCommand(
      SSHCommands.setKMLsAndRefresh([fileName, tourFileName]),
    );
    if (!setOk) {
      debugPrint(
        'DashboardViewModel: setKMLs failed after retries — aborting.',
      );
      return;
    }
    await _sshClient.forceRefresh(1);

    // ── Phase 3: Wait for GE to load, deploy card in parallel, then play tour ──
    await Future.delayed(const Duration(milliseconds: 1000));
    _mapSyncService.updateMapPositionFromLookAt(lookAt);

    // [B] Fire-and-forget with skipGlobalRefresh — no query.txt race with playTour.
    _phenomenonCardService.deployCard(
      phenomenon: phenomenon,
      lgClient: _sshClient,
      skipGlobalRefresh: true,
    );

    if (phenomenonName != null) {
      getClimateExplanation(phenomenonName);
    }

    // Play the tour.
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
