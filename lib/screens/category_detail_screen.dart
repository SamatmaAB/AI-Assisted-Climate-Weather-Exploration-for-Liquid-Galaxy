import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/components/glass_card.dart';
import 'package:lg_connection/connections/ssh.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;

  const CategoryDetailScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    const slate950 = Color(0xFF020617);
    const electricBlue = Color(0xFF3B82F6);
    const neonGreen = Color(0xFF22C55E);
    const cyanWhite = Color(0xFFE0F7FA);
    const goldAccent = Color(0xFFFFC107);
    const orangeAccent = Color(0xFFFF9800);
    const purpleAccent = Color(0xFF9C27B0);

    final SSH ssh = SSH();

    String subTitle = 'Global Systems';
    String description = 'Advanced planetary data visualization and monitoring.';
    IconData categoryIcon = CupertinoIcons.wind;
    Color themeColor = electricBlue;

    if (categoryName == 'Global Wind Systems') {
      subTitle = 'Indian subcontinent';
      description = 'Arabian Sea and Bay of Bengal moisture flows toward India.';
      categoryIcon = CupertinoIcons.wind;
      themeColor = goldAccent;
    } else if (categoryName == 'Ocean Currents') {
      subTitle = 'Pacific & Atlantic';
      description = 'Western boundary currents transporting heat toward the poles.';
      categoryIcon = CupertinoIcons.waveform;
      themeColor = cyanWhite;
    } else if (categoryName == 'Cyclone Formation') {
      subTitle = 'Tropical Systems';
      description = 'Real-time tracking of pressure systems and storm paths.';
      categoryIcon = CupertinoIcons.cloud_rain;
      themeColor = purpleAccent;
    } else if (categoryName == 'Extreme Weather') {
      subTitle = 'Thermal Analysis';
      description = 'Monitoring global temperature anomalies and heat distribution.';
      categoryIcon = CupertinoIcons.thermometer;
      themeColor = neonGreen;
    }

    return Scaffold(
      backgroundColor: slate950,
      body: Container(
        color: slate950,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    _buildCircleButton(
                      icon: CupertinoIcons.chevron_left,
                      onTap: () => Navigator.of(context).pop(),
                      borderColor: cyanWhite.withOpacity(0.1),
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
                    
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: themeColor.withOpacity(0.15)),
                            boxShadow: [
                              BoxShadow(color: themeColor.withOpacity(0.1), blurRadius: 15, spreadRadius: -2),
                            ],
                          ),
                          child: Icon(categoryIcon, color: themeColor, size: 34),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subTitle,
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
                      description,
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 36),

                    _buildSpecsCard(themeColor),
                    const SizedBox(height: 24),

                    _buildInfoCard(
                      title: 'DATA FEED',
                      icon: CupertinoIcons.antenna_radiowaves_left_right,
                      color: themeColor,
                      description: 'High-fidelity telemetry sourced from global observation networks.',
                    ),
                    const SizedBox(height: 20),

                    if (categoryName == 'Global Wind Systems') ...[
                      _buildActionItem(
                        title: 'Visualize Indian Monsoon',
                        subtitle: 'Run analysis and project monsoon KML',
                        icon: CupertinoIcons.wind,
                        color: orangeAccent,
                        onTap: () => ssh.visualizeIndianMonsoon(),
                      ),
                      const SizedBox(height: 14),
                    ],

                    if (categoryName == 'Ocean Currents') ...[
                      _buildActionItem(
                        title: 'Kuroshio current',
                        subtitle: 'Visualize the North Pacific western boundary current',
                        icon: CupertinoIcons.waveform,
                        color: goldAccent,
                        onTap: () => ssh.visualizeKuroshioCurrent(),
                      ),
                      const SizedBox(height: 14),
                    ],

                    _buildActionItem(
                      title: 'Project KML Layer',
                      subtitle: 'Generate Bezier-arrow KML and send it to Liquid Galaxy',
                      icon: CupertinoIcons.device_desktop,
                      color: electricBlue,
                      onTap: () {},
                    ),
                    const SizedBox(height: 14),
                    _buildActionItem(
                      title: 'Fly To Region',
                      subtitle: 'Move the rig camera to the tour viewpoint',
                      icon: CupertinoIcons.location_north_fill,
                      color: neonGreen,
                      onTap: () {
                        if (categoryName == 'Global Wind Systems') {
                          ssh.flyTo('<LookAt><longitude>78.9629</longitude><latitude>20.5937</latitude><altitude>0</altitude><heading>0</heading><tilt>45</tilt><range>5000000</range><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt>');
                        } else if (categoryName == 'Ocean Currents') {
                          ssh.flyTo('<LookAt><longitude>135.0</longitude><latitude>35.0</latitude><altitude>0</altitude><heading>0</heading><tilt>30</tilt><range>4000000</range><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt>');
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildActionItem(
                      title: 'Clear Rig Layers',
                      subtitle: 'Remove the active KML visualization',
                      icon: CupertinoIcons.trash,
                      color: const Color(0xFFEF4444),
                      onTap: () => ssh.clearKML(),
                    ),
                    
                    const SizedBox(height: 140),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap, required Color borderColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          shape: BoxShape.circle,
          border: Border.all(color: borderColor),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
      ),
    );
  }

  Widget _buildSpecsCard(Color accent) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: accent.withOpacity(0.08), blurRadius: 20, spreadRadius: -5),
        ],
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 32,
        borderColor: Colors.white.withOpacity(0.05),
        backgroundColor: Colors.white.withOpacity(0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(CupertinoIcons.chevron_left_slash_chevron_right, color: accent.withOpacity(0.8), size: 18),
                const SizedBox(width: 12),
                Text(
                  'KML GENERATION SPECS',
                  style: GoogleFonts.outfit(
                    color: accent.withOpacity(0.8),
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
              'High-fidelity vector math used to project accurate environmental flows.',
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
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
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white.withOpacity(0.9), 
            fontSize: 15, 
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required IconData icon, required Color color, required String description}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 15, spreadRadius: -5),
        ],
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        borderColor: Colors.white.withOpacity(0.05),
        backgroundColor: Colors.white.withOpacity(0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color.withOpacity(0.8), size: 20),
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
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                height: 1.6,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.08), blurRadius: 15, spreadRadius: -5),
        ],
      ),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        borderRadius: 22,
        borderColor: color.withOpacity(0.08),
        backgroundColor: Colors.white.withOpacity(0.03),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: color.withOpacity(0.1)),
              ),
              child: Icon(icon, color: color.withOpacity(0.7), size: 24),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white.withOpacity(0.9), 
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
      ),
    );
  }
}
