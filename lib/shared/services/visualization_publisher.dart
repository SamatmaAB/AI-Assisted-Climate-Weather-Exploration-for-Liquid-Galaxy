import 'package:flutter/foundation.dart';
import 'package:lg_connection/core/network/ssh_client.dart';

class VisualizationPublisher {
  final LGSSHClient _sshClient;

  VisualizationPublisher([LGSSHClient? sshClient])
      : _sshClient = sshClient ?? LGSSHClient();

  static const String masterKmlPath = '/var/www/html/kml/master.kml';
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

    if (tourKmlContent != null && tourFileName != null && tourFileName.isNotEmpty) {
      final tourTargetPath = '/var/www/html/$tourFileName';
      final tourUploaded = await _uploadWithRetry(
        content: tourKmlContent,
        targetPath: tourTargetPath,
        label: tourFileName,
        maxRetries: maxRetries,
      );
      if (!tourUploaded) {
        debugPrint('VisualizationPublisher: Failed to upload tour KML ($tourFileName) — aborting.');
        return false;
      }
    }

    final List<String> urls = ['http://lg1:81/kml/master.kml'];
    if (tourFileName != null && tourFileName.isNotEmpty) {
      urls.add('http://lg1:81/$tourFileName');
    }
    final String kmlsTxtContent = '${urls.join('\n')}\n';

    final registryUploaded = await _uploadWithRetry(
      content: kmlsTxtContent,
      targetPath: kmlsTxtPath,
      label: 'kmls.txt',
      maxRetries: maxRetries,
    );
    if (!registryUploaded) {
      debugPrint('VisualizationPublisher: Failed to update kmls.txt — aborting.');
      return false;
    }

    final refreshOk = await _sshClient.forceRefresh(1);
    if (!refreshOk) {
      debugPrint('VisualizationPublisher: Warning: forceRefresh(1) returned false.');
    } else {
      debugPrint('VisualizationPublisher: Successfully published visualization KML to master.kml.');
    }

    return refreshOk;
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
