import 'package:flutter/foundation.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';

/// ViewModel for managing Liquid Galaxy system controls and services.
class ControlsViewModel extends ChangeNotifier {
  final LGSSHClient _sshClient = LGSSHClient();

  ValueListenable<bool> get isConnected => _sshClient.isConnected;

  /// Sends a shutdown command to all rigs.
  Future<void> shutdown() async {
    // Note: Password would typically come from a secure storage or settings
    await _sshClient.runCommand(SSHCommands.powerOff('lg'));
  }

  /// Sends a reboot command to all rigs.
  Future<void> reboot() async {
    // In original code, it looped through rigs. 
    // Replicating that logic using the client.
    for (var i = 1; i <= 3; i++) {
      await _sshClient.runCommand(SSHCommands.rebootRig('lg', i));
    }
  }

  /// Clears all KML layers from the rig.
  Future<void> clearKML() async {
    await _sshClient.runCommand(SSHCommands.clearKML());
    await _sshClient.runCommand(SSHCommands.refreshKML());
  }

  /// Sends the Liquid Galaxy logo to the slave rig.
  Future<void> sendLogo() async {
    final logoKML = SSHCommands.buildLogoKML();
    await _sshClient.uploadFile(
      content: logoKML,
      targetPath: '/var/www/html/slave_1.kml',
    );
    await _sshClient.runCommand(SSHCommands.refreshKML());
  }

  /// Starts the orbit animation on the rig.
  Future<void> startOrbit() async {
    await _sshClient.runCommand(SSHCommands.buildOrbit());
  }

  /// Restarts the Liquid Galaxy system service.
  Future<void> refreshSystem() async {
    await _sshClient.runCommand(SSHCommands.restartLGService());
  }
}
