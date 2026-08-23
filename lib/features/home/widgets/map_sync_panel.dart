import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lg_connection/shared/services/map_sync_service.dart';

class MapSyncPanel extends StatefulWidget {
  final LatLng initialTarget;
  final double initialZoom;

  const MapSyncPanel({
    super.key,
    required this.initialTarget,
    required this.initialZoom,
  });

  @override
  State<MapSyncPanel> createState() => _MapSyncPanelState();
}

class _MapSyncPanelState extends State<MapSyncPanel> {
  final MapSyncService _mapSyncService = MapSyncService();

  CameraPosition? _currentPosition;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 260,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.initialTarget,
                zoom: widget.initialZoom,
              ),
              mapType: MapType.satellite,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: true,
              mapToolbarEnabled: false,
              
              rotateGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: true,
              zoomGesturesEnabled: true,
              onMapCreated: (controller) {
                _mapSyncService.setMapController(controller);
              },
              onCameraMove: (position) {
                _currentPosition = position;
              },
              
              onCameraIdle: () {
                if (_currentPosition != null) {
                  _mapSyncService.onPhoneCameraMoved(_currentPosition!);
                }
              },
            ),

            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sync_alt, size: 12, color: colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Bidirectional Sync',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app_outlined,
                          size: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.7)),
                      const SizedBox(width: 5),
                      Text(
                        'Drag to control LG rig',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapSyncService.setMapController(null);
    super.dispose();
  }
}
