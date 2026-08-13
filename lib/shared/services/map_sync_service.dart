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

  void setMapController(GoogleMapController? controller) {
    _mapController = controller;
    if (controller != null) {

      _animateMobileMap();
    }
  }

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
