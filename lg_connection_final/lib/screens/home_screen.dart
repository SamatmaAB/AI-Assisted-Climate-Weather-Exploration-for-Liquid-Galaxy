import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const slate950 = Color(0xFF020617);
    const blue950 = Color(0xFF172554);
    const electricBlue = Color(0xFF3B82F6);
    const neonGreen = Color(0xFF22C55E);
    const cyanWhite = Color(0xFFE0F7FA);
    const goldAccent = Color(0xFFFFC107);
    const purpleAccent = Color(0xFF9C27B0);
    const orangeAccent = Color(0xFFFF9800);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [slate950, blue950],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // atmospheric Glows for Premium colorful feel
            Positioned(
              top: -150,
              left: -50,
              child: _buildGlow(electricBlue.withOpacity(0.12), 400),
            ),
            Positioned(
              top: 200,
              right: -100,
              child: _buildGlow(purpleAccent.withOpacity(0.08), 350),
            ),
            Positioned(
              bottom: 100,
              left: -120,
              child: _buildGlow(goldAccent.withOpacity(0.05), 450),
            ),
            Positioned(
              bottom: -50,
              right: -50,
              child: _buildGlow(neonGreen.withOpacity(0.08), 400),
            ),

            SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 32),
                  _buildLiveStatus(neonGreen),
                  const SizedBox(height: 16),
                  
                  // Bold 32pt Headers (Outfit)
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
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // 2-Column Grid with varied colors
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
                      _buildScientificCard(context, 'Thermal Data', CupertinoIcons.thermometer, orangeAccent, 'Extreme Weather'),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader('Observational Rig Control'),
                  const SizedBox(height: 16),
                  
                  _buildControlPanel(cyanWhite, electricBlue),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader('Temporal Analysis'),
                  const SizedBox(height: 16),
                  
                  _buildTimelineCard(electricBlue),
                  
                  const SizedBox(height: 140), // Space for nav bar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: Container(),
      ),
    );
  }

  Widget _buildLiveStatus(Color neonGreen) {
    return Row(
      children: [
        FadeTransition(
          opacity: Tween(begin: 0.4, end: 1.0).animate(_pulseController),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: neonGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: neonGreen.withOpacity(0.6), blurRadius: 10, spreadRadius: 2),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'STATION ONLINE',
          style: GoogleFonts.outfit(
            color: neonGreen,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.outfit(
        color: Colors.white.withOpacity(0.4),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildScientificCard(BuildContext context, String title, IconData icon, Color accentColor, String categoryName) {
    return GlassCard(
      onTap: () {
        Navigator.push(context, CupertinoPageRoute(builder: (context) => CategoryDetailScreen(categoryName: categoryName)));
      },
      padding: const EdgeInsets.all(22),
      borderRadius: 24,
      borderColor: accentColor.withOpacity(0.2),
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
              color: accentColor.withOpacity(0.4),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(Color cyanWhite, Color electricBlue) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      borderColor: cyanWhite.withOpacity(0.1),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Liquid Galaxy Sync',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Multi-display coordination active',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: electricBlue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            onPressed: () {},
            child: Text(
              'RE-SYNC',
              style: GoogleFonts.outfit(
                color: electricBlue,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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
                'Simulation Epoch',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_timelineValue.toInt()}',
                style: GoogleFonts.outfit(
                  color: electricBlue,
                  fontSize: 22,
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
        ],
      ),
    );
  }
}
