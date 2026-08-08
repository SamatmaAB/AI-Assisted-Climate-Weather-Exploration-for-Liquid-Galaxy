import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';
import 'package:lg_connection/shared/services/map_sync_service.dart';

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

  Future<void> _forceRefresh(int screen) async {
    await _sshClient.forceRefresh(screen);
  }

  bool _isOrbiting = false;
  bool get isOrbiting => _isOrbiting;
  Timer? _orbitTimer;
  String? _lastOrbitPosition;

  Future<void> startOrbit() async {
    if (_isOrbiting) {
      await stopOrbit();
      return;
    }

    final connected = _sshClient.isConnected.value;
    if (!connected) {
      debugPrint('Cannot start orbit: LG not connected');
      return;
    }

    await _sshClient.execute(SSHCommands.stopTour());
    await Future.delayed(const Duration(milliseconds: 100));

    _isOrbiting = true;
    notifyListeners();

    final mapSync = MapSyncService();
    final double latitude = mapSync.lastTarget.latitude;
    final double longitude = mapSync.lastTarget.longitude;
    final double adjustedZoom = mapSync.lastZoom + 3.8;
    final double range = 591657550.5 / math.pow(2, adjustedZoom - 1);
    final double tilt = mapSync.lastTilt;

    _lastOrbitPosition = '<LookAt>'
        '<longitude>$longitude</longitude>'
        '<latitude>$latitude</latitude>'
        '<altitude>0</altitude>'
        '<heading>${mapSync.lastBearing}</heading>'
        '<tilt>$tilt</tilt>'
        '<range>$range</range>'
        '<gx:altitudeMode>relativeToGround</gx:altitudeMode>'
        '</LookAt>';

    try {
      const int steps = 60;
      const int stepDuration = 300;
      int currentStep = 1;
      bool isMoving = false;

      _orbitTimer = Timer.periodic(const Duration(milliseconds: stepDuration), (timer) async {
        if (!_isOrbiting) {
          timer.cancel();
          return;
        }

        if (isMoving) return;

        try {
          isMoving = true;
          double bearing = (currentStep * (360 / steps)) % 360;

          final lookAt = '<gx:duration>0.3</gx:duration>'
              '<gx:flyToMode>smooth</gx:flyToMode>'
              '<LookAt>'
              '<longitude>$longitude</longitude>'
              '<latitude>$latitude</latitude>'
              '<range>$range</range>'
              '<tilt>$tilt</tilt>'
              '<heading>$bearing</heading>'
              '<altitudeMode>relativeToGround</altitudeMode>'
              '</LookAt>';

          await _sshClient.execute(SSHCommands.flyTo(lookAt));

          currentStep++;
          isMoving = false;
        } catch (e) {
          debugPrint('Error during orbit step $currentStep: $e');
          currentStep++;
          isMoving = false;
        }
      });
    } catch (e) {
      _isOrbiting = false;
      notifyListeners();
      debugPrint('Error starting orbit loop: $e');
    }
  }

  Future<void> stopOrbit() async {
    _orbitTimer?.cancel();
    _orbitTimer = null;
    _isOrbiting = false;
    notifyListeners();

    try {
      await _sshClient.execute(SSHCommands.stopTour());
      if (_lastOrbitPosition != null) {
        await _sshClient.execute(SSHCommands.flyTo(_lastOrbitPosition!));
      }
    } catch (e) {
      debugPrint('Error stopping orbit: $e');
    }
  }

  Future<void> refreshSystem() async {
    await _sshClient.runCommand(SSHCommands.restartLGService());
  }

  @override
  void dispose() {
    _orbitTimer?.cancel();
    super.dispose();
  }
}
