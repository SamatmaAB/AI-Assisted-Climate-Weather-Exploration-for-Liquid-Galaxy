import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/components/glass_card.dart';

class DatasetDetailScreen extends StatelessWidget {
  final Map<String, dynamic> dataset;

  const DatasetDetailScreen({super.key, required this.dataset});

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
        child: Column(
          children: [
            // Header with Back Button
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    _buildCircleButton(
                      context: context,
                      icon: CupertinoIcons.chevron_left,
                      onTap: () => Navigator.of(context).pop(),
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
                  
                  Text(
                    dataset['title'],
                    style: GoogleFonts.outfit(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -1.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Global Research Federation Repository',
                    style: GoogleFonts.outfit(
                      color: electricBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  _buildSectionHeader('ABSTRACT'),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 24,
                    borderColor: cyanWhite.withOpacity(0.05),
                    backgroundColor: Colors.white.withOpacity(0.02),
                    child: Text(
                      _getDatasetDescription(dataset['title']),
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        height: 1.6,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  _buildSectionHeader('VISUALIZATION CAPABILITIES'),
                  const SizedBox(height: 16),
                  
                  ..._getVisualizationPoints(dataset['title']).map((point) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      borderRadius: 20,
                      borderColor: cyanWhite.withOpacity(0.05),
                      backgroundColor: Colors.white.withOpacity(0.02),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: electricBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              point,
                              style: GoogleFonts.outfit(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )).toList(),

                  const SizedBox(height: 32),
                  _buildSectionHeader('SOURCE METADATA'),
                  const SizedBox(height: 16),
                  
                  // Localized glow for the source card
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: electricBlue.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      borderRadius: 24,
                      borderColor: electricBlue.withOpacity(0.2),
                      backgroundColor: electricBlue.withOpacity(0.05),
                      onTap: () {},
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: electricBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(CupertinoIcons.link, color: electricBlue, size: 20),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'OFFICIAL REPOSITORY',
                                  style: GoogleFonts.outfit(
                                    color: electricBlue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Text(
                                  dataset['url'],
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(CupertinoIcons.arrow_up_right, color: Colors.white24, size: 18),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({required BuildContext context, required IconData icon, required VoidCallback onTap}) {
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

  Widget _buildStatusBadge(Color neonGreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: neonGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: neonGreen.withOpacity(0.2)),
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
            'FEDERATED',
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

  String _getDatasetDescription(String title) {
    if (title.contains('NASA Earthdata')) {
      return 'NASA Earthdata provides access to a wide range of Earth observation datasets collected from satellites and climate monitoring systems.';
    } else if (title.contains('Ocean')) {
      return 'NASA satellite missions collect global ocean data including sea surface temperature, ocean circulation, and ocean heat transport.';
    } else if (title.contains('Cyclone')) {
      return 'The cyclone track dataset contains historical records of tropical storms and hurricanes around the world, including intensity and trajectories.';
    } else {
      return 'Tracking ocean temperature anomalies and atmospheric changes associated with the El Niño–Southern Oscillation.';
    }
  }

  List<String> _getVisualizationPoints(String title) {
    if (title.contains('NASA Earthdata')) {
      return ['Global wind patterns', 'Atmospheric moisture transport', 'Temperature anomalies'];
    } else if (title.contains('Ocean')) {
      return ['Warm and cold ocean currents', 'Global ocean circulation', 'Marine climate interactions'];
    } else if (title.contains('Cyclone')) {
      return ['Cyclone formation locations', 'Storm trajectories', 'Intensity changes'];
    } else {
      return ['El Niño warming events', 'La Niña cooling patterns', 'Pacific climate variability'];
    }
  }
}
