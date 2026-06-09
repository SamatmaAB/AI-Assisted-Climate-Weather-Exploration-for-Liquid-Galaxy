import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/components/glass_card.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const slate950 = Color(0xFF020617);
    const blue950 = Color(0xFF172554);
    const electricBlue = Color(0xFF3B82F6);
    const neonGreen = Color(0xFF22C55E);
    const cyanWhite = Color(0xFFE0F7FA);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [slate950, blue950],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Atmospheric Glows
            Positioned(
              top: -150,
              right: -50,
              child: _buildGlow(electricBlue.withOpacity(0.12), 400),
            ),
            Positioned(
              bottom: 100,
              left: -100,
              child: _buildGlow(electricBlue.withOpacity(0.08), 350),
            ),

            Column(
              children: [
                // Header with Back Button
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(
                      children: [
                        GlassCard(
                          padding: const EdgeInsets.all(12),
                          borderRadius: 16,
                          blur: 20,
                          borderColor: cyanWhite.withOpacity(0.3),
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(CupertinoIcons.chevron_left, color: Colors.white, size: 22),
                        ),
                        const Spacer(),
                        _buildStatusBadge(neonGreen),
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
                      // Bold 32pt Header
                      Text(
                        'Technical',
                        style: GoogleFonts.outfit(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -1.5,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        'Documentation',
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
                        'Operational guidelines for the Earth Systems Explorer and Liquid Galaxy rig integration.',
                        style: GoogleFonts.outfit(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),

                      const SizedBox(height: 40),

                      _buildSectionHeader('MISSION OVERVIEW'),
                      const SizedBox(height: 16),
                      GlassCard(
                        padding: const EdgeInsets.all(24),
                        borderRadius: 24,
                        borderColor: cyanWhite.withOpacity(0.15),
                        backgroundColor: Colors.white.withOpacity(0.07),
                        child: Text(
                          'This application is part of the GSOC 2026 project "Earth Systems Explorer: Immersive Visualization of Global Climate Processes using Liquid Galaxy". It leverages multi-display synchronization to render complex planetary phenomena.',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 15,
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                      _buildSectionHeader('OPERATIONAL PROTOCOLS'),
                      const SizedBox(height: 16),
                      _buildInstructionTile(
                        CupertinoIcons.settings,
                        'Configuration',
                        'Navigate to System Settings to establish the SSH handshake with the master Liquid Galaxy node.',
                        electricBlue,
                        cyanWhite,
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionTile(
                        CupertinoIcons.square_grid_2x2,
                        'Data Selection',
                        'Identify climate phenomena from the explorer grid to initiate high-fidelity planetary overlays.',
                        electricBlue,
                        cyanWhite,
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionTile(
                        CupertinoIcons.play_circle,
                        'Rig Synchronization',
                        'Execute "START TOUR" to synchronize the visual state across the entire cluster of displays.',
                        electricBlue,
                        cyanWhite,
                      ),

                      const SizedBox(height: 32),
                      _buildSectionHeader('CORE VISUALIZATIONS'),
                      const SizedBox(height: 16),
                      _buildBulletGrid([
                        'Global Ocean Currents',
                        'Atmospheric Trade Winds',
                        'ENSO Thermal States',
                        'Regional Precipitation',
                      ], neonGreen, cyanWhite),

                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          'Guided by the Liquid Galaxy Lab',
                          style: GoogleFonts.outfit(
                            color: electricBlue.withOpacity(0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ],
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
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: Container(),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: Colors.white.withOpacity(0.4),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildStatusBadge(Color neonGreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: neonGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: neonGreen.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: neonGreen, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            'KNOWLEDGE BASE',
            style: GoogleFonts.outfit(
              color: neonGreen,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionTile(IconData icon, String title, String desc, Color accent, Color cyanWhite) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      borderColor: cyanWhite.withOpacity(0.1),
      backgroundColor: Colors.white.withOpacity(0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletGrid(List<String> items, Color neonGreen, Color cyanWhite) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          borderRadius: 16,
          borderColor: cyanWhite.withOpacity(0.05),
          backgroundColor: Colors.white.withOpacity(0.03),
          child: Row(
            children: [
              Icon(CupertinoIcons.checkmark_circle_fill, color: neonGreen.withOpacity(0.6), size: 14),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  items[index],
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
