import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lg_connection/core/common_widgets/glass_card.dart';
import 'package:lg_connection/core/theme/app_colors.dart';
import 'package:lg_connection/shared/services/map_sync_service.dart';

/// A panel containing a Google Map preview that is read-only and syncs its camera
/// dynamically to follow Liquid Galaxy updates.
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
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 22,
      borderColor: AppColors.cyanWhite.withOpacity(0.1),
      child: SizedBox(
        height: 260,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.initialTarget,
                  zoom: widget.initialZoom,
                ),
                mapType: MapType.satellite,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                // Disable all map gestures to make it strictly read-only
                rotateGesturesEnabled: false,
                scrollGesturesEnabled: false,
                tiltGesturesEnabled: false,
                zoomGesturesEnabled: false,
                onMapCreated: (controller) {
                  _mapSyncService.setMapController(controller);
                },
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.62),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.electricBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Galaxy Sync Active',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 11,
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
