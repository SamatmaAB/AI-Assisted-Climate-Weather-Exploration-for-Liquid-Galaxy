import 'package:flutter/foundation.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';
import 'package:lg_connection/shared/services/ai_service.dart';
import 'package:lg_connection/shared/services/cache_service.dart';

/// ViewModel for managing the state and execution of planetary tours on Liquid Galaxy.
class TourViewModel extends ChangeNotifier {
  final LGSSHClient _sshClient = LGSSHClient();
  final AIService _aiService = AIService();

  bool isPlaying = false;
  bool isSynced = true;

  bool isLoadingExplanation = false;
  String explanation = '';

  /// Fetches an AI-generated explanation for the given phenomenon, using
  /// cache when available.
  Future<void> loadExplanation(String phenomenon) async {
    isLoadingExplanation = true;
    explanation = '';
    notifyListeners();

    try {
      final cached = CacheService.getClimateInfo(phenomenon);
      if (cached != null && !cached.startsWith('Error')) {
        explanation = cached;
      } else {
        final result = await _aiService.getExplanation(phenomenon);
        if (!result.startsWith('Error')) {
          await CacheService.saveClimateInfo(phenomenon, result);
        }
        explanation = result;
      }
    } catch (e) {
      explanation = 'Error generating explanation: $e';
    } finally {
      isLoadingExplanation = false;
      notifyListeners();
    }
  }

  /// Starts the tour simulation.
  void startTour() {
    isPlaying = true;
    notifyListeners();
    // In a full implementation, this might trigger a specific KML tour.
  }

  /// Stops the current tour on the Liquid Galaxy rig.
  Future<void> stopTour() async {
    isPlaying = false;
    notifyListeners();
    await _sshClient.runCommand(SSHCommands.stopTour());
  }

  /// Toggles the synchronization between the app and the rig displays.
  void toggleSync(bool value) {
    isSynced = value;
    notifyListeners();
  }
}
