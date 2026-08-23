import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';
import 'package:lg_connection/models/climate_phenomenon_model.dart';
import 'package:lg_connection/services/ai/ai_repository.dart';
import 'package:lg_connection/shared/services/cache_service.dart';
import 'package:lg_connection/shared/services/map_sync_service.dart';
import 'package:lg_connection/shared/services/orbit_service.dart';
import 'package:lg_connection/shared/services/tour_service.dart';
import 'package:lg_connection/features/phenomena/services/phenomenon_card_service.dart';
import 'package:lg_connection/services/ai/providers/gemini_provider.dart';

class HomeViewModel extends ChangeNotifier {
  final LGSSHClient _sshClient = LGSSHClient();
  final AIRepository _aiRepository;
  final MapSyncService _mapSyncService = MapSyncService();
  final TourService _tourService = TourService();
  final PhenomenonCardService _phenomenonCardService = PhenomenonCardService();

  LatLng get lastTarget => _mapSyncService.lastTarget;
  double get lastZoom => _mapSyncService.lastZoom;
  double get lastTilt => _mapSyncService.lastTilt;
  double get lastBearing => _mapSyncService.lastBearing;

  ValueListenable<bool> get isConnected => _sshClient.isConnected;

  HomeViewModel(this._aiRepository) {
    _mapSyncService.addListener(notifyListeners);
  }

  Future<void> orbit() async {
    await OrbitService().startOrbit();
  }


  /// Exits any playing guided tour on the rig (e.g. Indian Monsoon tour)
  /// by writing `exittour=true` to the query file, leaving the loaded KML.
  Future<bool> exitTour() async {
    try {
      return await _sshClient.runCommand(SSHCommands.stopTour());
    } catch (e) {
      debugPrint('HomeViewModel: exitTour failed: $e');
      return false;
    }
  }

  Future<void> clearKML() async {
    await _tourService.stopTour();
    await PhenomenonCardService().clearCard(_sshClient);
    await _sshClient.runCommand(SSHCommands.clearKML());
    await _sshClient.runCommand(SSHCommands.refreshKML());
    await _sshClient.forceRefresh(1);
  }

  bool _isValidExplanation(String? text) {
    if (text == null) return false;
    if (text.startsWith('Error')) return false;
    if (text == GeminiProvider.missingKeyMessage) return false;
    if (text.contains('built without a Gemini API key')) return false;
    if (text.contains('Gemini API key is not configured')) return false;
    return true;
  }

  Future<String> getClimateExplanation(String phenomenon) async {
    final cached = CacheService.getClimateInfo(phenomenon);
    if (_isValidExplanation(cached)) return cached!;

    final explanation = await _aiRepository
        .getExplanation(phenomenon)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => ClimatePhenomena.getFallbackSummary(phenomenon),
        );
    if (_isValidExplanation(explanation)) {
      await CacheService.saveClimateInfo(phenomenon, explanation);
      return explanation;
    }
    return ClimatePhenomena.getFallbackSummary(phenomenon);
  }

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

  bool isVisualisingMonsoon = false;
  bool isVisualisingKuroshio = false;
  bool isVisualisingGulfStream = false;
  bool isVisualisingElNino = false;
  bool isVisualisingLaNina = false;

  bool get isAnyVisualising =>
      isVisualisingMonsoon ||
      isVisualisingKuroshio ||
      isVisualisingGulfStream ||
      isVisualisingElNino ||
      isVisualisingLaNina;

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
          'HomeViewModel: Command failed (attempt ${attempt + 1}/$maxRetries), '
          'retrying in ${retryDelay.inMilliseconds}ms…',
        );
        await Future.delayed(retryDelay);
      }
    }
    return false;
  }

  Future<void> _runVisualizationSequence({
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

    // [A] Pre-load both asset strings from the bundle DURING the GE unload wait
    //     (overlaps I/O with the 800ms delay — effectively free).
    final assetFutures = Future.wait([
      rootBundle.loadString(assetPath),
      rootBundle.loadString(tourKmlPath),
    ]);
    await Future.delayed(const Duration(milliseconds: 800));
    final assets = await assetFutures;
    final kmlContent = assets[0];
    final tourContent = assets[1];

    // ── Phase 2: Upload KMLs sequentially (SSH only supports one SFTP channel), then load ──
    final tourFileName = tourKmlPath.split('/').last;

    final uploaded = await _sshClient.uploadFile(
      content: kmlContent,
      targetPath: '/var/www/html/$fileName',
    );
    if (!uploaded) {
      debugPrint('HomeViewModel: KML upload failed for $fileName — aborting.');
      return;
    }

    final tourUploaded = await _sshClient.uploadFile(
      content: tourContent,
      targetPath: '/var/www/html/$tourFileName',
    );
    if (!tourUploaded) {
      debugPrint(
        'HomeViewModel: Tour KML upload failed for $tourFileName — aborting.',
      );
      return;
    }

    // [C] Batch: setKMLs + refreshkml in one SSH round-trip.
    final setOk = await _retryCommand(
      SSHCommands.setKMLsAndRefresh([fileName, tourFileName]),
    );
    if (!setOk) {
      debugPrint('HomeViewModel: setKMLs failed after retries — aborting.');
      return;
    }
    await _sshClient.forceRefresh(1);

    // ── Phase 3: Wait for GE to load, deploy card in parallel, then play tour ──
    await Future.delayed(const Duration(milliseconds: 1000));
    _mapSyncService.updateMapPositionFromLookAt(lookAt);

    // [B] Fire-and-forget with skipGlobalRefresh — no query.txt race with playTour.
    //     deployCard only does forceRefresh on the slave screen (no refreshkml).
    _phenomenonCardService.deployCard(
      phenomenon: ClimatePhenomena.all.firstWhere(
        (p) => p.name == phenomenonName,
        orElse: () => ClimatePhenomena.indianMonsoon,
      ),
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
        'HomeViewModel: playTour failed — re-sending refresh + playTour.',
      );
      await _retryCommand(SSHCommands.refreshKML());
      await Future.delayed(const Duration(milliseconds: 800));
      await _retryCommand(SSHCommands.playTour(tourName));
    }
  }

  @override
  void dispose() {
    _mapSyncService.removeListener(notifyListeners);
    super.dispose();
  }
}
