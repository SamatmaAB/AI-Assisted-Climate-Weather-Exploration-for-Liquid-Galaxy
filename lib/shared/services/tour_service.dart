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

  Future<void> startTour({
    required String tourKmlPath,
    required String tourName,
  }) async {
    try {

      await stopTour();
      await Future.delayed(const Duration(milliseconds: 150));

      final tourFileName = tourKmlPath.split('/').last;
      final tourContent = await rootBundle.loadString(tourKmlPath);

      await _sshClient.uploadFile(
        content: tourContent,
        targetPath: '/var/www/html/$tourFileName',
      );

      await _sshClient.runCommand(SSHCommands.setKML(tourFileName));
      await _sshClient.runCommand(SSHCommands.refreshKML());

      await Future.delayed(const Duration(milliseconds: 600));
      await _sshClient.runCommand(SSHCommands.playTour(tourName));
    } catch (e) {
      debugPrint('Error starting tour ($tourName): $e');
    }
  }
}
