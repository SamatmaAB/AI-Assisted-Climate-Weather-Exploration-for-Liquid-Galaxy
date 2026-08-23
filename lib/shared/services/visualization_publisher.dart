import 'package:flutter/foundation.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';

class VisualizationPublisher {
  final LGSSHClient _sshClient;

  VisualizationPublisher([LGSSHClient? sshClient])
      : _sshClient = sshClient ?? LGSSHClient();

  static const String masterKmlPath = '/var/www/html/kml/master.kml';
  static const String tourKmlPath = '/var/www/html/kml/tour.kml';
  static const String kmlsTxtPath = '/var/www/html/kmls.txt';

  Future<bool> publishVisualizationKML({
    required String kmlContent,
    String? tourKmlContent,
    String? tourFileName,
    int maxRetries = 2,
  }) async {
    if (!_sshClient.isConnected.value) {
      debugPrint('VisualizationPublisher: SSH disconnected. Attempting to connect…');
      final connected = await _sshClient.connect();
      if (!connected) {
        debugPrint('VisualizationPublisher: Connection attempt failed — aborting.');
        return false;
      }
    }

    final masterUploaded = await _uploadWithRetry(
      content: kmlContent,
      targetPath: masterKmlPath,
      label: 'master.kml',
      maxRetries: maxRetries,
    );
    if (!masterUploaded) {
      debugPrint('VisualizationPublisher: Failed to upload master.kml — aborting.');
      return false;
    }

    if (tourKmlContent != null && tourKmlContent.isNotEmpty) {
      final tourUploaded = await _uploadWithRetry(
        content: tourKmlContent,
        targetPath: tourKmlPath,
        label: 'tour.kml',
        maxRetries: maxRetries,
      );
      if (!tourUploaded) {
        debugPrint('VisualizationPublisher: Failed to upload tour.kml — continuing.');
      }
    }

    await _sshClient.ensureMasterPersistentRefresh();

    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    final String kmlsTxtContent = 'http://lg1:81/kml/master.kml?t=$timestamp\nhttp://lg1:81/kml/tour.kml?t=$timestamp\n';

    await _uploadWithRetry(
      content: kmlsTxtContent,
      targetPath: kmlsTxtPath,
      label: 'kmls.txt',
      maxRetries: maxRetries,
    );

    await _sshClient.runCommand(SSHCommands.refreshKML());
    debugPrint('VisualizationPublisher: Successfully published visualization KML & tour KML ($timestamp).');

    return true;
  }



  Future<bool> _uploadWithRetry({
    required String content,
    required String targetPath,
    required String label,
    required int maxRetries,
  }) async {
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      if (!_sshClient.isConnected.value) {
        debugPrint('VisualizationPublisher: Connection dropped before uploading $label. Reconnecting…');
        await _sshClient.connect();
      }

      final success = await _sshClient.uploadFile(
        content: content,
        targetPath: targetPath,
      );

      if (success) {
        return true;
      }

      if (attempt < maxRetries) {
        debugPrint(
          'VisualizationPublisher: SFTP upload failed for $label (attempt ${attempt + 1}/$maxRetries). Retrying…',
        );
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
    return false;
  }
}
