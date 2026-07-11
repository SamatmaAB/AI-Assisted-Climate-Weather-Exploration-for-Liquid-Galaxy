import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';
import 'package:lg_connection/models/lookat_model.dart';

/// A centralized singleton service to synchronize the Liquid Galaxy camera position
/// with the mobile Google Map.
class MapSyncService extends ChangeNotifier {
  static final MapSyncService _instance = MapSyncService._internal();
  factory MapSyncService() => _instance;
  MapSyncService._internal();

  final LGSSHClient _sshClient = LGSSHClient();
  GoogleMapController? _mapController;

  // Active Camera State
  LatLng lastTarget = const LatLng(20.5937, 78.9629);
  double lastZoom = 4.0;
  double lastTilt = 0.0;
  double lastBearing = 0.0;

  /// Registers the GoogleMapController from the active MapSyncPanel widget.
  void setMapController(GoogleMapController? controller) {
    _mapController = controller;
    if (controller != null) {
      // Instantly animate the newly created map to the last target position
      _animateMobileMap();
    }
  }

  /// Sends a FlyTo command to the Liquid Galaxy rig and animates the mobile Google Map
  /// to the same parameters.
  Future<void> flyTo(LookAt lookAt) async {
    lastTarget = LatLng(lookAt.latitude, lookAt.longitude);
    lastZoom = lookAt.zoom;
    lastTilt = lookAt.tilt;
    lastBearing = lookAt.bearing;
    notifyListeners();

    // 1. Send SSH command to the Liquid Galaxy rig using the KML LookAt XML representation
    await _sshClient.runCommand(SSHCommands.flyTo(lookAt.toXml()));

    // 2. Animate the local mobile map to match the new perspective
    await _animateMobileMap();
  }

  /// Backward compatible wrapper to sync movement using a LookAt XML string.
  Future<void> flyToLookAt(String lookAtXml) async {
    final lookAt = LookAt.fromXml(lookAtXml);
    await flyTo(lookAt);
  }

  /// Helper to animate the mobile Google Map to the currently stored state.
  Future<void> _animateMobileMap() async {
    if (_mapController == null) return;
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
      debugPrint('Error animating mobile Google Map: $e');
    }
  }
}
