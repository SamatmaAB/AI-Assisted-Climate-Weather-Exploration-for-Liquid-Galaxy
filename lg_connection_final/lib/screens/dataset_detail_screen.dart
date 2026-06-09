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
            // Atmospheric Glow Effects
            Positioned(
              top: -100,
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
                      
                      // Bold 32pt Header (Outfit)
                      Text(
                        dataset['title'],
                        style: GoogleFonts.outfit(
                          fontSize: 42, // Approx 32pt
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

                      // Description Glass Card
                      _buildSectionHeader('ABSTRACT'),
                      const SizedBox(height: 16),
                      GlassCard(
                        padding: const EdgeInsets.all(24),
                        borderRadius: 24,
                        borderColor: cyanWhite.withOpacity(0.15),
                        backgroundColor: Colors.white.withOpacity(0.07),
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
                          borderColor: cyanWhite.withOpacity(0.1),
                          backgroundColor: Colors.white.withOpacity(0.04),
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
                      
                      GlassCard(
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
                      
                      const SizedBox(height: 140), // Space for nav bar overlap
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
      return 'NASA Earthdata provides access to a wide range of Earth observation datasets collected from satellites and climate monitoring systems. These datasets include atmospheric conditions, land surface measurements, ocean parameters, and environmental changes.';
    } else if (title.contains('Ocean')) {
      return 'NASA satellite missions collect global ocean data including sea surface temperature, ocean circulation, and ocean heat transport. These observations help scientists understand how oceans influence weather patterns and climate systems.';
    } else if (title.contains('Cyclone')) {
      return 'The cyclone track dataset provided by the National Oceanic and Atmospheric Administration contains historical records of tropical storms and hurricanes around the world. It includes information about storm paths, wind speeds, pressure, and storm intensity.';
    } else if (title.contains('Precipitation')) {
      return 'The Global Precipitation Measurement Mission is a joint satellite mission designed to measure rainfall and snowfall across the Earth. It provides near-real-time global precipitation data used for weather forecasting and climate studies.';
    } else {
      return 'The ENSO dataset tracks ocean temperature anomalies and atmospheric changes associated with the El Niño–Southern Oscillation. These data help scientists monitor climate oscillations that influence global weather patterns.';
    }
  }

  List<String> _getVisualizationPoints(String title) {
    if (title.contains('NASA Earthdata')) {
      return ['Global wind patterns', 'Atmospheric moisture transport', 'Temperature anomalies', 'Environmental changes'];
    } else if (title.contains('Ocean')) {
      return ['Warm and cold ocean currents', 'Global ocean circulation', 'Ocean temperature variations', 'Marine climate interactions'];
    } else if (title.contains('Cyclone')) {
      return ['Cyclone formation locations', 'Storm trajectories', 'Storm intensity changes over time'];
    } else if (title.contains('Precipitation')) {
      return ['Rainfall intensity maps', 'Storm precipitation patterns', 'Monsoon rainfall zones'];
    } else {
      return ['El Niño warming events', 'La Niña cooling patterns', 'Climate variability across the Pacific Ocean'];
    }
  }
}
