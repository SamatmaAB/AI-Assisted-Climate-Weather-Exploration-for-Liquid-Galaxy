import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';
import 'package:lg_connection/shared/services/orbit_service.dart';


class ControlsViewModel extends ChangeNotifier {
  final LGSSHClient _sshClient = LGSSHClient();

  ValueListenable<bool> get isConnected => _sshClient.isConnected;

  Future<bool> shutdown() async {
    final password = _sshClient.password;
    final screens = _sshClient.numberOfRigs;
    bool allSuccessful = true;

    try {

      for (var i = screens; i >= 1; i--) {
        final shutdownCommand =
            'sshpass -p $password ssh -t lg$i "echo $password | sudo -S shutdown now"';
        final session = await _sshClient.execute(shutdownCommand);
        allSuccessful = allSuccessful && (session != null);

        if (i > 1) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }

      final shutdownCommandLg1 =
          'sshpass -p $password ssh -t lg1 "echo $password | sudo -S shutdown now"';
      final lg1Session = await _sshClient.execute(shutdownCommandLg1);
      allSuccessful = allSuccessful && (lg1Session != null);

      await Future.delayed(const Duration(milliseconds: 100));
      _sshClient.disconnect();
      return allSuccessful;
    } catch (e) {
      debugPrint('Error during shutdown: $e');
      _sshClient.disconnect();
      return false;
    }
  }

  Future<bool> reboot() async {
    final password = _sshClient.password;
    final screens = _sshClient.numberOfRigs;
    bool allSuccessful = true;

    try {
      for (var i = screens; i >= 1; i--) {
        final rebootCommand =
            'sshpass -p $password ssh -t lg$i "echo $password | sudo -S reboot"';
        final session = await _sshClient.execute(rebootCommand);
        allSuccessful = allSuccessful && (session != null);

        if (i > 1) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }

      final rebootCommandLg1 =
          'sshpass -p $password ssh -t lg1 "echo $password | sudo -S reboot"';
      final lg1Session = await _sshClient.execute(rebootCommandLg1);
      allSuccessful = allSuccessful && (lg1Session != null);

      await Future.delayed(const Duration(milliseconds: 100));
      _sshClient.disconnect();

      unawaited(
        Future.delayed(const Duration(seconds: 46), () async {
          int retries = 0;
          const maxRetries = 10;
          const retryDelay = Duration(seconds: 5);

          while (retries < maxRetries && !_sshClient.isConnected.value) {
            try {
              debugPrint('Reconnection attempt ${retries + 1} of $maxRetries');
              final connected = await _sshClient.connect();
              if (connected) {
                debugPrint('Reconnection successful');
                await Future.delayed(const Duration(seconds: 1));
                await _sshClient.runCommand(
                  SSHCommands.flyTo(
                    '<LookAt>'
                    '<longitude>-3.7492199</longitude>'
                    '<latitude>40.4636688</latitude>'
                    '<altitude>0</altitude>'
                    '<heading>0</heading>'
                    '<tilt>60</tilt>'
                    '<range>1500000</range>'
                    '<gx:altitudeMode>relativeToGround</gx:altitudeMode>'
                    '</LookAt>',
                  ),
                );
                return;
              }
            } catch (e) {
              debugPrint('Reconnection attempt ${retries + 1} failed: $e');
            }

            if (!_sshClient.isConnected.value && retries < maxRetries - 1) {
              await Future.delayed(retryDelay);
            }
            retries++;
          }
        }),
      );

      return allSuccessful;
    } catch (e) {
      debugPrint('Error during reboot: $e');
      _sshClient.disconnect();
      return false;
    }
  }

  Future<bool> clearKML() async {
    bool ok = await _sshClient.runCommand(SSHCommands.clearKML());

    final screens = _sshClient.numberOfRigs;
    for (int i = 1; i <= screens; i++) {
      final cleared = await _sshClient.runCommand(SSHCommands.clearScreen(i));
      ok = cleared && ok;
      await _forceRefresh(i);
    }
    return ok;
  }

  Future<bool> sendLogo() async {
    return await _sshClient.sendLogo();
  }

  /// Exits any currently playing Liquid Galaxy tour by writing
  /// `exittour=true` to the query file. This stops the guided tour (e.g.
  /// Indian Monsoon / El Niño tour) while leaving the loaded KML in place.
  Future<bool> exitTour() async {
    try {
      final ok = await _sshClient.runCommand(SSHCommands.stopTour());
      return ok;
    } catch (e) {
      debugPrint('Error exiting tour: $e');
      return false;
    }
  }

  Future<void> _forceRefresh(int screen) async {
    await _sshClient.forceRefresh(screen);
  }

  bool get isOrbiting => OrbitService().isOrbiting;

  Future<void> startOrbit() async {
    await OrbitService().startOrbit();
    notifyListeners();
  }

  Future<void> stopOrbit() async {
    await OrbitService().stopOrbit();
    notifyListeners();
  }


  Future<void> refreshSystem() async {
    await _sshClient.runCommand(SSHCommands.restartLGService());
  }

  @override
  void dispose() {
    OrbitService().dispose();
    super.dispose();
  }
}

