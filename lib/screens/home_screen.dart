import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lg_connection/components/glass_card.dart';
import 'package:lg_connection/screens/category_detail_screen.dart';
import 'package:lg_connection/connections/ssh.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  double _timelineValue = 2013;
  late AnimationController _pulseController;
  final SSH ssh = SSH();

  GoogleMapController? _mapController;
  LatLng _lastTarget = const LatLng(0, 0);
  double _lastZoom = 2;
  double _lastTilt = 0;
  double _lastBearing = 0;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    ssh.connectToLG();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _syncToLG() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ssh.flyToCoordinates(
        _lastTarget.latitude,
        _lastTarget.longitude,
        _lastZoom,
        _lastTilt,
        _lastBearing,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const slate950 = Color(0xFF020617);
    const electricBlue = Color(0xFF3B82F6);
    const neonGreen = Color(0xFF22C55E);
    const cyanWhite = Color(0xFFE0F7FA);
    const goldAccent = Color(0xFFFFC107);
    const purpleAccent = Color(0xFF9C27B0);
    const orangeAccent = Color(0xFFFF9800);

    return Scaffold(
      backgroundColor: slate950,
      body: Container(
        color: slate950,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 32),
              ValueListenableBuilder<bool>(
                valueListenable: ssh.isConnected,
                builder: (context, connected, child) {
                  return _buildLiveStatus(connected ? neonGreen : Colors.redAccent, connected);
                },
              ),
              const SizedBox(height: 16),
              
              Text(
                'Earth Systems',
                style: GoogleFonts.outfit(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
              Text(
                'Explorer',
                style: GoogleFonts.outfit(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: electricBlue,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Precision planetary monitoring and immersive data visualization.',
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
              
              const SizedBox(height: 40),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.85,
                children: [
                  _buildScientificCard(context, 'Global Winds', CupertinoIcons.wind, electricBlue, 'Global Wind Systems'),
                  _buildScientificCard(context, 'Ocean Currents', CupertinoIcons.waveform, goldAccent, 'Ocean Currents'),
                  _buildScientificCard(context, 'Storm Tracking', CupertinoIcons.cloud_rain, purpleAccent, 'Cyclone Formation'),
                  // Changed orangeAccent to neonGreen here
                  _buildScientificCard(context, 'Thermal Data', CupertinoIcons.thermometer, neonGreen, 'Extreme Weather'),
                ],
              ),
              
              const SizedBox(height: 40),
              
              _buildSectionHeader('Synced Navigation'),
              const SizedBox(height: 16),
              _buildMapPreview(electricBlue, cyanWhite),
              
              const SizedBox(height: 20),
              _buildOrbitButton(electricBlue, neonGreen),
              
              const SizedBox(height: 40),
              _buildSectionHeader('Temporal Analysis'),
              const SizedBox(height: 16),
              _buildTimelineCard(electricBlue),
              
              const SizedBox(height: 32),
              _buildGuidedStoryButton(electricBlue, neonGreen),
              
              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveStatus(Color statusColor, bool connected) {
    return Row(
      children: [
        FadeTransition(
          opacity: Tween(begin: 0.4, end: 1.0).animate(_pulseController),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: statusColor.withOpacity(0.5), blurRadius: 10, spreadRadius: 2),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          connected ? 'STATION ONLINE' : 'STATION OFFLINE',
          style: GoogleFonts.outfit(
            color: statusColor,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        const Icon(CupertinoIcons.camera, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.outfit(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildScientificCard(BuildContext context, String title, IconData icon, Color accentColor, String categoryName) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // Increased opacity from 0.15 to 0.22 for slightly higher intensity
            color: accentColor.withOpacity(0.22),
            blurRadius: 25,
            spreadRadius: -4,
          ),
        ],
      ),
      child: GlassCard(
        onTap: () {
          Navigator.push(context, CupertinoPageRoute(builder: (context) => CategoryDetailScreen(categoryName: categoryName)));
        },
        padding: const EdgeInsets.all(22),
        borderRadius: 24,
        borderColor: accentColor.withOpacity(0.2),
        backgroundColor: Colors.white.withOpacity(0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accentColor.withOpacity(0.2)),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Live Telemetry',
              style: GoogleFonts.outfit(
                color: accentColor.withOpacity(0.5),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPreview(Color electricBlue, Color cyanWhite) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 24,
      borderColor: cyanWhite.withOpacity(0.1),
      child: Container(
        height: 300,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: _lastTarget, zoom: _lastZoom),
                onMapCreated: (controller) => _mapController = controller,
                onCameraMove: (position) {
                  _lastTarget = position.target;
                  _lastZoom = position.zoom;
                  _lastTilt = position.tilt;
                  _lastBearing = position.bearing;
                  _syncToLG();
                },
                mapType: MapType.satellite,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text('Open in Maps', style: GoogleFonts.outfit(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 4),
                    const Icon(CupertinoIcons.arrow_up_right, color: Colors.blue, size: 14),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('Live Sync', style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.fullscreen, color: Colors.black54, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrbitButton(Color startColor, Color endColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 16),
          onPressed: () => ssh.buildOrbit(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.arrow_2_circlepath, color: Colors.white),
              const SizedBox(width: 12),
              Text('Orbit Location', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineCard(Color electricBlue) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      borderColor: const Color(0xFFE0F7FA).withOpacity(0.1),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Timeline',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_timelineValue.toInt()}',
                style: GoogleFonts.outfit(
                  color: electricBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CupertinoSlider(
            min: 2000,
            max: 2026,
            value: _timelineValue,
            activeColor: electricBlue,
            thumbColor: Colors.white,
            onChanged: (val) => setState(() => _timelineValue = val),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('2000', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
              Text('2026', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuidedStoryButton(Color startColor, Color endColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 20),
          onPressed: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.play_fill, color: Colors.white),
              const SizedBox(width: 12),
              Text('Start Guided Story', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
