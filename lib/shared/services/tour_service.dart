import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';

/// Dedicated service responsible for loading, uploading, and controlling
/// guided KML tour playback on Liquid Galaxy rigs.
class TourService {
  final LGSSHClient _sshClient;

  TourService({LGSSHClient? sshClient})
      : _sshClient = sshClient ?? LGSSHClient();

  /// Stops any actively running tour on Liquid Galaxy.
  Future<void> stopTour() async {
    try {
      await _sshClient.runCommand(SSHCommands.stopTour());
    } catch (e) {
      debugPrint('Error stopping tour: $e');
    }
  }

  /// Loads tour KML asset, uploads it via SFTP, registers it with Liquid Galaxy,
  /// and triggers tour playback.
  Future<void> startTour({
    required String tourKmlPath,
    required String tourName,
  }) async {
    try {
      // 1. Stop any currently active tour
      await stopTour();
      await Future.delayed(const Duration(milliseconds: 150));

      // 2. Load tour KML asset content
      final tourFileName = tourKmlPath.split('/').last;
      final tourContent = await rootBundle.loadString(tourKmlPath);

      // 3. Upload tour KML to Liquid Galaxy web server
      await _sshClient.uploadFile(
        content: tourContent,
        targetPath: '/var/www/html/$tourFileName',
      );

      // 4. Set tour KML in kmls.txt and trigger refresh
      await _sshClient.runCommand(SSHCommands.setKML(tourFileName));
      await _sshClient.runCommand(SSHCommands.refreshKML());

      // 5. Trigger tour playback execution
      await Future.delayed(const Duration(milliseconds: 600));
      await _sshClient.runCommand(SSHCommands.playTour(tourName));
    } catch (e) {
      debugPrint('Error starting tour ($tourName): $e');
    }
  }
}
