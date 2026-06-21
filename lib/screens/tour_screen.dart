import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/components/glass_card.dart';
import 'package:lg_connection/connections/ssh.dart';

class TourScreen extends StatefulWidget {
  final String phenomenon;

  const TourScreen({super.key, required this.phenomenon});

  @override
  State<TourScreen> createState() => _TourScreenState();
}

class _TourScreenState extends State<TourScreen> with SingleTickerProviderStateMixin {
  late SSH ssh;
  bool _isPlaying = false;
  bool _isSynced = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    ssh = SSH();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startTour() {
    setState(() => _isPlaying = true);
  }

  void _stopTour() {
    setState(() => _isPlaying = false);
    ssh.executeCommand('echo "exittour=true" > /tmp/query.txt');
  }

  @override
  Widget build(BuildContext context) {
    const slate950 = Color(0xFF020617);
    const electricBlue = Color(0xFF3B82F6);
    const neonGreen = Color(0xFF22C55E);
    const cyanWhite = Color(0xFFE0F7FA);

    return Scaffold(
      backgroundColor: slate950, // Pure dark background
      body: Container(
        color: slate950,
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(
                      children: [
                        _buildCircleButton(
                          icon: CupertinoIcons.chevron_left,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const Spacer(),
                        _buildSyncToggle(neonGreen),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const SizedBox(height: 32),
                      // Bold Header
                      Text(
                        widget.phenomenon,
                        style: GoogleFonts.outfit(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -1.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PLANETARY SIMULATION',
                        style: GoogleFonts.outfit(
                          color: electricBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildStatusCard(electricBlue, neonGreen, cyanWhite),
                      
                      const SizedBox(height: 32),
                      _buildSectionHeader('SIMULATION METRICS'),
                      const SizedBox(height: 16),
                      _buildMetricsGrid(electricBlue, cyanWhite),

                      const SizedBox(height: 32),
                      _buildSectionHeader('MECHANISM ANALYSIS'),
                      const SizedBox(height: 16),
                      _buildExplanatorySection(cyanWhite),

                      const SizedBox(height: 140), // Space for controls
                    ],
                  ),
                ),
              ],
            ),

            // Floating Control Bar with localized glow
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: electricBlue.withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 32,
                  blur: 25,
                  borderColor: cyanWhite.withOpacity(0.1),
                  backgroundColor: Colors.white.withOpacity(0.05),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSecondaryButton(
                          'KML LAYER',
                          CupertinoIcons.layers_fill,
                          electricBlue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildPrimaryButton(
                          _isPlaying ? 'TERMINATE TOUR' : 'INITIATE TOUR',
                          _isPlaying ? CupertinoIcons.stop_fill : CupertinoIcons.play_fill,
                          _isPlaying ? const Color(0xFFEF4444) : electricBlue,
                          () => _isPlaying ? _stopTour() : _startTour(),
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

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildSyncToggle(Color neonGreen) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: neonGreen.withOpacity(0.1), blurRadius: 10, spreadRadius: -2),
        ],
      ),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        borderRadius: 20,
        borderColor: neonGreen.withOpacity(0.2),
        backgroundColor: neonGreen.withOpacity(0.05),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'RIG SYNC',
              style: GoogleFonts.outfit(color: neonGreen, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0),
            ),
            const SizedBox(width: 8),
            Transform.scale(
              scale: 0.7,
              child: CupertinoSwitch(
                value: _isSynced,
                activeColor: neonGreen,
                onChanged: (val) => setState(() => _isSynced = val),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5),
    );
  }

  Widget _buildStatusCard(Color electricBlue, Color neonGreen, Color cyanWhite) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (_isPlaying ? neonGreen : electricBlue).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        borderColor: cyanWhite.withOpacity(0.1),
        backgroundColor: Colors.white.withOpacity(0.04),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (_isPlaying ? neonGreen : electricBlue).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: (_isPlaying ? neonGreen : electricBlue).withOpacity(0.2)),
              ),
              child: Icon(
                _isPlaying ? CupertinoIcons.waveform_path : CupertinoIcons.globe,
                color: _isPlaying ? neonGreen : electricBlue,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isPlaying ? 'Tour Active' : 'System Standby',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _isPlaying ? 'Synchronizing multi-display rig...' : 'Ready for planetary visualization.',
                    style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(Color electricBlue, Color cyanWhite) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricItem(CupertinoIcons.thermometer, 'TEMP', '24.2°C', electricBlue, cyanWhite),
        _buildMetricItem(CupertinoIcons.wind, 'VELOCITY', '12m/s', electricBlue, cyanWhite),
        _buildMetricItem(CupertinoIcons.drop_fill, 'HUMIDITY', '68%', electricBlue, cyanWhite),
      ],
    );
  }

  Widget _buildMetricItem(IconData icon, String label, String value, Color accent, Color cyanWhite) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 20,
      borderColor: cyanWhite.withOpacity(0.05),
      backgroundColor: Colors.white.withOpacity(0.03),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: accent.withOpacity(0.6), size: 20),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildExplanatorySection(Color cyanWhite) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      borderColor: cyanWhite.withOpacity(0.05),
      backgroundColor: Colors.white.withOpacity(0.02),
      child: Text(
        _getMechanismDescription(widget.phenomenon),
        style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7), fontSize: 15, height: 1.6, fontWeight: FontWeight.w300),
      ),
    );
  }

  Widget _buildPrimaryButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.outfit(color: color, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  String _getMechanismDescription(String name) {
    switch (name) {
      case 'Gulf Stream':
        return 'The Gulf Stream is a strong ocean current that brings warm water from the Gulf of Mexico into the Atlantic Ocean. It extends all the way up the eastern coast of the United States and Canada.';
      case 'Indian Monsoon':
        return 'A complex atmospheric process driven by the temperature difference between the Indian Ocean and the Asian landmass, resulting in seasonal wind reversals.';
      case 'El Nino':
        return 'Characterized by unusually warm ocean temperatures in the Equatorial Pacific, El Nino affects global weather patterns, disrupting normal trade winds.';
      default:
        return 'This Earth system process involves complex interactions between the atmosphere and hydrosphere, driving global climate patterns and regional weather events.';
    }
  }
}
