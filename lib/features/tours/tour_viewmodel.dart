import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';
import 'package:lg_connection/models/climate_phenomenon_model.dart';
import 'package:lg_connection/services/ai/ai_repository.dart';
import 'package:lg_connection/services/ai/providers/gemini_provider.dart';
import 'package:lg_connection/services/tts/tts_service.dart';
import 'package:lg_connection/shared/services/cache_service.dart';

class TourViewModel extends ChangeNotifier {
  final LGSSHClient _sshClient = LGSSHClient();
  final AIRepository _aiRepository;

  TourViewModel(this._aiRepository);

  bool isPlaying = false;
  bool isSynced = true;

  bool isLoadingExplanation = false;
  String explanation = '';

  bool _isValidExplanation(String? text) {
    if (text == null) return false;
    if (text.startsWith('Error')) return false;
    if (text == GeminiProvider.missingKeyMessage) return false;
    if (text.contains('built without a Gemini API key')) return false;
    if (text.contains('Gemini API key is not configured')) return false;
    return true;
  }

  Future<void> loadExplanation(String phenomenon) async {
    isLoadingExplanation = true;
    explanation = '';
    notifyListeners();

    try {
      final cached = CacheService.getClimateInfo(phenomenon);
      if (_isValidExplanation(cached)) {
        explanation = cached!;
      } else {
        final result = await _aiRepository
            .getExplanation(phenomenon)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => ClimatePhenomena.getFallbackSummary(phenomenon),
            );
        if (_isValidExplanation(result)) {
          await CacheService.saveClimateInfo(phenomenon, result);
          explanation = result;
        } else {
          explanation = ClimatePhenomena.getFallbackSummary(phenomenon);
        }
      }
      if (TtsService.instance.autoNarrate &&
          _isValidExplanation(explanation) &&
          explanation.trim().isNotEmpty) {
        TtsService.instance.speak(explanation);
      }
    } catch (e) {
      explanation = ClimatePhenomena.getFallbackSummary(phenomenon);
    } finally {
      isLoadingExplanation = false;
      notifyListeners();
    }
  }

  void startTour() {
    isPlaying = true;
    notifyListeners();

  }

  Future<void> stopTour() async {
    isPlaying = false;
    notifyListeners();
    await _sshClient.runCommand(SSHCommands.stopTour());
  }

  void toggleSync(bool value) {
    isSynced = value;
    notifyListeners();
  }
}
