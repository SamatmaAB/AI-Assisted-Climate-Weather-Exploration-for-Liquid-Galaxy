import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';
import 'package:lg_connection/shared/services/map_sync_service.dart';

/// Shared orbit controller used across the app (Controls, City Explorer, …).
///
/// The orbit logic is identical to the original implementation in
/// [ControlsViewModel]: it stops any running tour, then repeatedly sends
/// `flytoview` LookAt commands with a rotating heading around the last
/// synced camera target, producing a smooth cinematic orbit on the rig.
class OrbitService {
  OrbitService._();

  static final OrbitService _instance = OrbitService._();
  factory OrbitService() => _instance;

  bool _isOrbiting = false;
  bool get isOrbiting => _isOrbiting;

  Timer? _orbitTimer;
  String? _lastOrbitPosition;

  /// Starts the orbit using native Google Earth KML gx:Tour for smooth camera animation.
  Future<void> startOrbit() async {
    if (_isOrbiting) {
      await stopOrbit();
      return;
    }

    final sshClient = LGSSHClient();
    final connected = sshClient.isConnected.value;
    if (!connected) {
      debugPrint('OrbitService: Cannot start orbit: LG not connected');
      return;
    }

    await sshClient.execute(SSHCommands.stopTour());
    await Future.delayed(const Duration(milliseconds: 150));

    _isOrbiting = true;

    final mapSync = MapSyncService();
    final double latitude = mapSync.lastTarget.latitude;
    final double longitude = mapSync.lastTarget.longitude;
    final double adjustedZoom = mapSync.lastZoom + 3.8;
    final double range = 591657550.5 / math.pow(2, adjustedZoom - 1);
    final double tilt = mapSync.lastTilt;
    final double heading = mapSync.lastBearing;

    _lastOrbitPosition = '<LookAt>'
        '<longitude>$longitude</longitude>'
        '<latitude>$latitude</latitude>'
        '<altitude>0</altitude>'
        '<heading>$heading</heading>'
        '<tilt>$tilt</tilt>'
        '<range>$range</range>'
        '<gx:altitudeMode>relativeToGround</gx:altitudeMode>'
        '</LookAt>';

    try {
      // Build native KML tour with smooth 360-degree waypoints (5 full rotations)
      const int rotations = 5;
      const int stepDegrees = 5;
      const double stepDuration = 0.5;
      final tourKml = SSHCommands.buildOrbitTourKml(
        latitude: latitude,
        longitude: longitude,
        range: range,
        tilt: tilt,
        heading: heading,
        rotations: rotations,
        stepDegrees: stepDegrees,
        stepDuration: stepDuration,
      );

      // Upload KML to Liquid Galaxy web server
      await sshClient.uploadFile(
        content: tourKml,
        targetPath: '/var/www/html/Orbit.kml',
      );

      await sshClient.execute(SSHCommands.setKML('Orbit.kml'));
      await sshClient.execute(SSHCommands.refreshKML());
      await sshClient.forceRefresh(1);
      await Future.delayed(const Duration(milliseconds: 500));

      // Execute native Google Earth tour play command
      await sshClient.execute(SSHCommands.playTour('Orbit'));

      // Schedule periodic re-play if orbit continues beyond rotation duration (~180s)
      final totalTourDuration = Duration(seconds: ((360 ~/ stepDegrees) * rotations * stepDuration).round() - 2);
      _orbitTimer?.cancel();
      _orbitTimer = Timer.periodic(totalTourDuration, (timer) async {
        if (!_isOrbiting) {
          timer.cancel();
          return;
        }
        try {
          await sshClient.execute(SSHCommands.playTour('Orbit'));
        } catch (e) {
          debugPrint('OrbitService: Error repeating orbit tour: $e');
        }
      });
    } catch (e) {
      _isOrbiting = false;
      debugPrint('OrbitService: Error starting orbit tour: $e');
    }
  }

  /// Stops the orbit and returns the camera to the position it started from.
  Future<void> stopOrbit() async {
    _orbitTimer?.cancel();
    _orbitTimer = null;
    _isOrbiting = false;

    final sshClient = LGSSHClient();
    try {
      await sshClient.execute(SSHCommands.stopTour());
      if (_lastOrbitPosition != null) {
        await sshClient.execute(SSHCommands.flyTo(_lastOrbitPosition!));
      }
    } catch (e) {
      debugPrint('OrbitService: Error stopping orbit: $e');
    }
  }

  /// Cancels the timer without flying back (used on dispose).
  void dispose() {
    _orbitTimer?.cancel();
    _orbitTimer = null;
    _isOrbiting = false;
  }
}

