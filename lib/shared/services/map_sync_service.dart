import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';
import 'package:lg_connection/models/lookat_model.dart';

class MapSyncService extends ChangeNotifier {
  static final MapSyncService _instance = MapSyncService._internal();
  factory MapSyncService() => _instance;
  MapSyncService._internal();

  final LGSSHClient _sshClient = LGSSHClient();
  GoogleMapController? _mapController;

  LatLng lastTarget = const LatLng(20.5937, 78.9629);
  double lastZoom = 4.0;
  double lastTilt = 0.0;
  double lastBearing = 0.0;

  /// When true the next [onPhoneCameraMoved] call is ignored.
  /// Set before [_animateMobileMap] to break the rig→phone→rig feedback loop.
  bool _suppressNextCameraIdle = false;

  /// Debounce timer that throttles outgoing SSH flytoview commands so rapid
  /// drag gestures on the phone do not flood the LG rig with SSH calls.
  Timer? _debounceTimer;

  // ── Controller registration ──────────────────────────────────────────────

  void setMapController(GoogleMapController? controller) {
    _mapController = controller;
    if (controller != null) {
      _animateMobileMap();
    }
  }

  // ── LG rig → Phone (existing, unchanged) ────────────────────────────────

  Future<void> flyTo(LookAt lookAt) async {
    lastTarget = LatLng(lookAt.latitude, lookAt.longitude);
    lastZoom = lookAt.zoom;
    lastTilt = lookAt.tilt;
    lastBearing = lookAt.bearing;
    notifyListeners();

    await _sshClient.runCommand(SSHCommands.flyTo(lookAt.toXml()));

    await _animateMobileMap();
  }

  Future<void> flyToLookAt(String lookAtXml) async {
    final lookAt = LookAt.fromXml(lookAtXml);
    await flyTo(lookAt);
  }

  void updateMapPosition(LookAt lookAt) {
    lastTarget = LatLng(lookAt.latitude, lookAt.longitude);
    lastZoom = lookAt.zoom;
    lastTilt = lookAt.tilt;
    lastBearing = lookAt.bearing;
    notifyListeners();
    _animateMobileMap();
  }

  void updateMapPositionFromLookAt(String lookAtXml) {
    final lookAt = LookAt.fromXml(lookAtXml);
    updateMapPosition(lookAt);
  }

  // ── Phone → LG rig (new bidirectional) ──────────────────────────────────

  /// Called by [MapSyncPanel] via [GoogleMap.onCameraIdle] whenever the user
  /// finishes a gesture on the phone map.
  ///
  /// The method:
  ///   1. Skips one call after [_animateMobileMap] to break the feedback loop.
  ///   2. Debounces rapid drags at 300 ms.
  ///   3. Converts the [CameraPosition] to a KML LookAt and sends a
  ///      `flytoview` SSH command to the LG rig.
  void onPhoneCameraMoved(CameraPosition position) {
    // Break feedback loop: suppress the idle that fires right after we
    // programmatically animate the phone map in response to the LG rig.
    if (_suppressNextCameraIdle) {
      _suppressNextCameraIdle = false;
      return;
    }

    // Update cached state immediately so other consumers (orbit, etc.) see it.
    lastTarget = position.target;
    lastZoom = position.zoom;
    lastTilt = position.tilt;
    lastBearing = position.bearing;
    notifyListeners();

    // Debounce: cancel any pending SSH call and re-schedule.
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _sendFlyToLG();
    });
  }

  /// Converts the current cached position to a KML LookAt XML and sends it to
  /// the LG rig via SSH, exactly as [SSHCommands.flyToCoordinates] would but
  /// using the fields already stored in this service.
  Future<void> _sendFlyToLG() async {
    if (!_sshClient.isConnected.value) return;

    final lookAt = LookAt(
      latitude: lastTarget.latitude,
      longitude: lastTarget.longitude,
      zoom: lastZoom,
      tilt: lastTilt,
      bearing: lastBearing,
    );

    try {
      await _sshClient.runCommand(SSHCommands.flyTo(lookAt.toXml()));
    } catch (e) {
      debugPrint('MapSyncService: Error sending flyTo to LG rig: $e');
    }
  }

  // ── Internal helpers ─────────────────────────────────────────────────────

  Future<void> _animateMobileMap() async {
    if (_mapController == null) return;

    // Suppress the onCameraIdle that Google Maps fires after animateCamera
    // so we don't echo the position back to the rig.
    _suppressNextCameraIdle = true;

    try {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: lastTarget,
            zoom: lastZoom,
            tilt: lastTilt,
            bearing: lastBearing,
          ),
        ),
      );
    } catch (e) {
      _suppressNextCameraIdle = false; // reset if animation fails
      debugPrint('Error animating mobile Google Map: $e');
    }
  }
}

