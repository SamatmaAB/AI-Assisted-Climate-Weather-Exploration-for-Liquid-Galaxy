import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';

class TourService {
  final LGSSHClient _sshClient;

  TourService({LGSSHClient? sshClient})
      : _sshClient = sshClient ?? LGSSHClient();

  Future<void> stopTour() async {
    try {
      await _sshClient.runCommand(SSHCommands.stopTour());
    } catch (e) {
      debugPrint('Error stopping tour: $e');
    }
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
          'TourService: Command failed (attempt ${attempt + 1}/$maxRetries), retrying…',
        );
        await Future.delayed(retryDelay);
      }
    }
    return false;
  }

  Future<void> startTour({
    required String tourKmlPath,
    required String tourName,
  }) async {
    try {

      await stopTour();
      await Future.delayed(const Duration(milliseconds: 200));

      final tourFileName = tourKmlPath.split('/').last;
      final tourContent = await rootBundle.loadString(tourKmlPath);

      final uploaded = await _sshClient.uploadFile(
        content: tourContent,
        targetPath: '/var/www/html/$tourFileName',
      );
      if (!uploaded) {
        debugPrint('TourService: Upload failed for $tourFileName — aborting.');
        return;
      }

      await _retryCommand(SSHCommands.setKML(tourFileName));
      await _retryCommand(SSHCommands.refreshKML());
      await _sshClient.forceRefresh(1);

      await Future.delayed(const Duration(milliseconds: 800));
      final tourStarted = await _retryCommand(SSHCommands.playTour(tourName));

      if (!tourStarted) {
        debugPrint(
          'TourService: playTour failed — re-sending refresh + playTour.',
        );
        await _retryCommand(SSHCommands.refreshKML());
        await Future.delayed(const Duration(milliseconds: 500));
        await _retryCommand(SSHCommands.playTour(tourName));
      }
    } catch (e) {
      debugPrint('Error starting tour ($tourName): $e');
    }
  }
}
