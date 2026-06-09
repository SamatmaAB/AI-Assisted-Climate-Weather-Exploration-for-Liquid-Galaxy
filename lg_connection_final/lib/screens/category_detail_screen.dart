import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/components/glass_card.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;

  const CategoryDetailScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    // Theme Specs
    const slate950 = Color(0xFF020617);
    const blue950 = Color(0xFF172554);
    const electricBlue = Color(0xFF3B82F6);
    const neonGreen = Color(0xFF22C55E);
    const cyanWhite = Color(0xFFE0F7FA);
    const goldAccent = Color(0xFFFFC107);
    const orangeAccent = Color(0xFFFF9800);
    const purpleAccent = Color(0xFF9C27B0);
    const vibrantPurple = Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: slate950,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [slate950, blue950, slate950],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Multi-colored Atmospheric Glow Effects
            Positioned(
              top: -100,
              right: -50,
              child: _buildGlow(electricBlue.withOpacity(0.15), 450),
            ),
            Positioned(
              top: 200,
              left: -80,
              child: _buildGlow(vibrantPurple.withOpacity(0.1), 350),
            ),
            Positioned(
              bottom: 150,
              left: -120,
              child: _buildGlow(goldAccent.withOpacity(0.08), 400),
            ),
            Positioned(
              bottom: -50,
              right: -50,
              child: _buildGlow(neonGreen.withOpacity(0.1), 350),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(
                      children: [
                        _buildCircleButton(
                          icon: CupertinoIcons.chevron_left,
                          onTap: () => Navigator.of(context).pop(),
                          borderColor: cyanWhite.withOpacity(0.2),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const SizedBox(height: 32),
                        
                        // Title Section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [goldAccent.withOpacity(0.2), goldAccent.withOpacity(0.05)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: goldAccent.withOpacity(0.4)),
                                boxShadow: [
                                  BoxShadow(color: goldAccent.withOpacity(0.1), blurRadius: 10, spreadRadius: 1),
                                ],
                              ),
                              child: const Icon(CupertinoIcons.cloud_rain, color: goldAccent, size: 34),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Indian subcontinent',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    categoryName,
                                    style: GoogleFonts.outfit(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Arabian Sea and Bay of Bengal moisture flows toward India.',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // KML GENERATION SPECS card
                        _buildSpecsCard(goldAccent),
                        const SizedBox(height: 24),

                        // TOUR FOCUS card
                        _buildInfoCard(
                          title: 'TOUR FOCUS',
                          icon: CupertinoIcons.location_circle,
                          color: goldAccent,
                          description: 'Moisture transport, low pressure over northwest India, and major rainfall belts.',
                        ),
                        const SizedBox(height: 20),

                        // REGIONAL IMPACT card
                        _buildInfoCard(
                          title: 'REGIONAL IMPACT',
                          icon: CupertinoIcons.location_solid,
                          color: orangeAccent,
                          description: 'Heavy rainfall along Kerala, Mumbai, Odisha, northeast India, and the Gangetic plain.',
                        ),
                        const SizedBox(height: 20),

                        // NARRATION BRIEF card
                        _buildInfoCard(
                          title: 'NARRATION BRIEF',
                          icon: CupertinoIcons.speaker_2_fill,
                          color: purpleAccent,
                          description: 'The southwest monsoon forms when land heating creates low pressure over India, pulling moist ocean winds inland from two major branches.',
                        ),
                        const SizedBox(height: 36),

                        // Action Items
                        _buildActionItem(
                          title: 'Project KML Layer',
                          subtitle: 'Generate Bezier-arrow KML and send it to Liquid Galaxy',
                          icon: CupertinoIcons.device_desktop,
                          color: electricBlue,
                        ),
                        const SizedBox(height: 14),
                        _buildActionItem(
                          title: 'Fly To Region',
                          subtitle: 'Move the rig camera to the tour viewpoint',
                          icon: CupertinoIcons.location_north_fill,
                          color: neonGreen,
                        ),
                        const SizedBox(height: 14),
                        _buildActionItem(
                          title: 'Clear Rig Layers',
                          subtitle: 'Remove the active KML visualization',
                          icon: CupertinoIcons.trash,
                          color: Color(0xFFEF4444),
                        ),
                        
                        const SizedBox(height: 140), // Space for floating nav bar
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Floating Navigation Bar
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: _buildBottomNavBar(electricBlue),
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
        filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
        child: Container(),
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap, required Color borderColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: borderColor),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildSpecsCard(Color accent) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 32,
      borderColor: Colors.white.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.chevron_left_slash_chevron_right, color: accent, size: 18),
              const SizedBox(width: 12),
              Text(
                'KML GENERATION SPECS',
                style: GoogleFonts.outfit(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSpecRow(CupertinoIcons.graph_square, 'Geometry', 'Bezier Splines'),
          const SizedBox(height: 18),
          _buildSpecRow(CupertinoIcons.location, 'Markers', 'High-Res Glyphs'),
          const SizedBox(height: 18),
          _buildSpecRow(CupertinoIcons.arrow_2_circlepath, 'Sync', '3 Rig Nodes'),
          const SizedBox(height: 24),
          Text(
            'This layer uses high-fidelity vector math to project accurate Indian Monsoon flows onto the Liquid Galaxy sphere.',
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.3), size: 18),
        const SizedBox(width: 14),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white.withOpacity(0.4), 
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white, 
            fontSize: 15, 
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required IconData icon, required Color color, required String description}) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      borderColor: Colors.white.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            description,
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              height: 1.6,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({required String title, required String subtitle, required IconData icon, required Color color}) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      borderRadius: 22,
      borderColor: color.withOpacity(0.15),
      backgroundColor: Colors.white.withOpacity(0.06),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color.withOpacity(0.9), size: 24),
          ),
          const SizedBox(width: 18),
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
                  subtitle,
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.4), 
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(CupertinoIcons.chevron_right, color: Colors.white.withOpacity(0.2), size: 18),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(Color activeColor) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      borderRadius: 40,
      blur: 25,
      borderColor: Colors.white.withOpacity(0.1),
      backgroundColor: Colors.white.withOpacity(0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(CupertinoIcons.house_fill, 'Explore', true, activeColor),
          _buildNavItem(CupertinoIcons.circle_grid_hex, 'Data', false, activeColor),
          _buildNavItem(CupertinoIcons.layers_fill, 'Control', false, activeColor),
          _buildNavItem(CupertinoIcons.settings_solid, 'Settings', false, activeColor),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, Color activeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: isActive ? BoxDecoration(
        color: activeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? activeColor : Colors.white.withOpacity(0.4), size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: isActive ? activeColor : Colors.white.withOpacity(0.4),
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
