import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/core/common_widgets/glass_card.dart';
import 'package:lg_connection/core/theme/app_colors.dart';

/// Screen providing technical documentation and operational guidelines.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate950,
      body: Container(
        color: AppColors.slate950,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 32),
                  _buildTitleSection(),
                  const SizedBox(height: 40),
                  _buildSectionHeader('MISSION OVERVIEW'),
                  const SizedBox(height: 16),
                  _buildMissionCard(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('OPERATIONAL PROTOCOLS'),
                  const SizedBox(height: 16),
                  _buildProtocols(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('CORE VISUALIZATIONS'),
                  const SizedBox(height: 16),
                  _buildBulletGrid([
                    'Global Ocean Currents',
                    'Atmospheric Trade Winds',
                    'ENSO Thermal States',
                    'Regional Precipitation',
                  ]),
                  const SizedBox(height: 40),
                  _buildFooter(),
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
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
            _buildStatusBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            color: AppColors.electricBlue,
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
      ],
    );
  }

  Widget _buildMissionCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      borderColor: AppColors.cyanWhite.withOpacity(0.05),
      backgroundColor: Colors.white.withOpacity(0.02),
      child: Text(
        'This application is part of the GSOC 2026 project "Earth Systems Explorer: Immersive Visualization of Global Climate Processes using Liquid Galaxy". It leverages multi-display synchronization to render complex planetary phenomena.',
        style: GoogleFonts.outfit(
          color: Colors.white.withOpacity(0.7),
          fontSize: 15,
          height: 1.6,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildProtocols() {
    return Column(
      children: [
        _buildInstructionTile(
          CupertinoIcons.settings,
          'Configuration',
          'Navigate to System Settings to establish the SSH handshake with the master Liquid Galaxy node.',
          AppColors.electricBlue,
        ),
        const SizedBox(height: 12),
        _buildInstructionTile(
          CupertinoIcons.square_grid_2x2,
          'Data Selection',
          'Identify climate phenomena from the explorer grid to initiate high-fidelity planetary overlays.',
          AppColors.electricBlue,
        ),
        const SizedBox(height: 12),
        _buildInstructionTile(
          CupertinoIcons.play_circle,
          'Rig Synchronization',
          'Execute "START TOUR" to synchronize the visual state across the entire cluster of displays.',
          AppColors.electricBlue,
        ),
      ],
    );
  }

  Widget _buildInstructionTile(IconData icon, String title, String desc, Color accent) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: -5,
          ),
        ],
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        borderColor: AppColors.cyanWhite.withOpacity(0.05),
        backgroundColor: Colors.white.withOpacity(0.02),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withOpacity(0.1)),
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
      ),
    );
  }

  Widget _buildBulletGrid(List<String> items) {
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
          borderColor: AppColors.cyanWhite.withOpacity(0.05),
          backgroundColor: Colors.white.withOpacity(0.02),
          child: Row(
            children: [
              Icon(CupertinoIcons.checkmark_circle_fill, color: AppColors.neonGreen.withOpacity(0.4), size: 14),
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

  Widget _buildFooter() {
    return Center(
      child: Text(
        'Guided by the Liquid Galaxy Lab',
        style: GoogleFonts.outfit(
          color: AppColors.electricBlue.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
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

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neonGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonGreen.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: AppColors.neonGreen, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            'KNOWLEDGE BASE',
            style: GoogleFonts.outfit(
              color: AppColors.neonGreen,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
