import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';
import 'package:lg_connection/shared/services/map_sync_service.dart';

/// ViewModel for managing Liquid Galaxy system controls and services.
class ControlsViewModel extends ChangeNotifier {
  final LGSSHClient _sshClient = LGSSHClient();

  ValueListenable<bool> get isConnected => _sshClient.isConnected;

  /// Sends a shutdown command to all configured rigs.
  /// Uses the password stored in SharedPreferences — not a hardcoded value.
  Future<void> shutdown() async {
    final password = _sshClient.password;
    final screens = _sshClient.numberOfRigs;
    // Shut down outer screens first, master (lg1) last.
    for (var i = screens; i >= 1; i--) {
      await _sshClient.runCommand(SSHCommands.shutdownRig(password, i));
    }
  }

  /// Sends a reboot command to all configured rigs.
  /// Uses the password stored in SharedPreferences — not a hardcoded value.
  Future<void> reboot() async {
    final password = _sshClient.password;
    final screens = _sshClient.numberOfRigs;
    for (var i = screens; i >= 1; i--) {
      await _sshClient.runCommand(SSHCommands.rebootRig(password, i));
    }
  }

  /// Clears all KML overlays — kmls.txt AND every slave screen file.
  ///
  /// Previously only kmls.txt was cleared, leaving the logo on the leftmost
  /// screen. Now slave_N.kml files are explicitly overwritten with blank KML.
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

  /// Sends the Liquid Galaxy logo to the correct leftmost slave screen.
  ///
  /// Fixes from original implementation:
  ///   - Path: /var/www/html/kml/slave_N.kml  (was /var/www/html/slave_1.kml)
  ///   - Screen: dynamically computed from rig count  (was hardcoded screen 1)
  ///   - Refresh: forceRefresh via myplaces.kml sed  (was refreshkml=true)
  ///   - Method: SSH echo  (was SFTP upload)
  ///   - Return: bool so the UI can show real success/failure feedback
  Future<bool> sendLogo() async {
    final screens = _sshClient.numberOfRigs;
    final leftScreen = SSHCommands.calculateLeftMostScreen(screens);

    final ok = await _sshClient.runCommand(
      SSHCommands.sendLogoToScreen(leftScreen),
    );
    if (ok) await _forceRefresh(leftScreen);
    return ok;
  }

  /// Forces Google Earth on a slave screen to reload its KML.
  ///
  /// Uses the two-step sed approach on myplaces.kml: temporarily adds an
  /// onInterval refreshMode then removes it, triggering exactly one reload.
  Future<void> _forceRefresh(int screen) async {
    final password = _sshClient.password;
    try {
      await _sshClient.runCommand(
        SSHCommands.addRefreshInterval(screen, 2, password),
      );
      await _sshClient.runCommand(
        SSHCommands.removeRefreshInterval(screen, password),
      );
    } catch (e) {
      debugPrint('_forceRefresh failed for screen $screen: $e');
    }
  }

  bool _isOrbiting = false;
  bool get isOrbiting => _isOrbiting;
  Timer? _orbitTimer;
  String? _lastOrbitPosition;

  /// Starts or stops the camera orbit loop around the current MapSyncService coordinates.
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

    // Stop any playing tour first
    await _sshClient.execute(SSHCommands.stopTour());
    await Future.delayed(const Duration(milliseconds: 100));

    _isOrbiting = true;
    notifyListeners();

    // Query active coordinates from the central map sync service.
    final mapSync = MapSyncService();
    final double latitude = mapSync.lastTarget.latitude;
    final double longitude = mapSync.lastTarget.longitude;
    final double adjustedZoom = mapSync.lastZoom + 3.8;
    final double range = 591657550.5 / math.pow(2, adjustedZoom - 1);
    final double tilt = mapSync.lastTilt;

    // Cache the starting view parameters to fly back to on stop.
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
      const int stepDuration = 300; // Match 300ms step frequency with 0.3s duration
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

          // Fire-and-forget command submission for seamless interpolation without roundtrip waiting.
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

  /// Cancels the orbit loop and returns the rig to the starting camera position.
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

  /// Restarts the Liquid Galaxy system service.
  Future<void> refreshSystem() async {
    await _sshClient.runCommand(SSHCommands.restartLGService());
  }

  @override
  void dispose() {
    _orbitTimer?.cancel();
    super.dispose();
  }
}
