import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lg_connection/shared/services/map_sync_service.dart';

/// A panel displaying a read-only Google Map synchronized to the Liquid Galaxy
/// camera position.
///
/// Map controller and sync behavior are fully preserved.
/// Only the surrounding container has been migrated to M3 surface semantics.
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
              compassEnabled: false,
              mapToolbarEnabled: false,
              rotateGesturesEnabled: false,
              scrollGesturesEnabled: false,
              tiltGesturesEnabled: false,
              zoomGesturesEnabled: false,
              onMapCreated: (controller) {
                _mapSyncService.setMapController(controller);
              },
            ),
            // Sync status overlay chip
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
                    Icon(Icons.sync, size: 12, color: colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Galaxy Sync Active',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
