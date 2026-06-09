import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/components/glass_card.dart';
import 'package:lg_connection/screens/dataset_detail_screen.dart';

class DatasetsScreen extends StatelessWidget {
  const DatasetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const slate950 = Color(0xFF020617);
    const blue950 = Color(0xFF172554);
    const electricBlue = Color(0xFF3B82F6);
    const neonGreen = Color(0xFF22C55E);

    final List<Map<String, dynamic>> datasets = [
      {
        'title': 'NOAA Ocean Currents',
        'tags': ['Current Path', 'KML-ready'],
        'status': 'Synced',
        'statusColor': electricBlue,
        'icon': CupertinoIcons.doc_text,
      },
      {
        'title': 'NOAA ENSO SST Anomalies',
        'tags': ['Climate Index', 'KML-ready'],
        'status': 'Ready',
        'statusColor': electricBlue,
        'icon': CupertinoIcons.doc_text,
      },
      {
        'title': 'NASA Earth Observations',
        'tags': ['Atmosphere/Ocean', 'Layer source'],
        'status': 'Ready',
        'statusColor': electricBlue,
        'icon': CupertinoIcons.doc_text,
      },
      {
        'title': 'Atmospheric Circulation Models',
        'tags': ['Vector Field', 'Tour source'],
        'status': 'Live',
        'statusColor': neonGreen,
        'icon': CupertinoIcons.doc_text,
      },
    ];

    return Scaffold(
      backgroundColor: slate950,
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
            Positioned(
              top: -100,
              right: -50,
              child: _buildGlow(electricBlue.withOpacity(0.1), 400),
            ),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Earth System\nData Sources',
                    style: GoogleFonts.outfit(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...datasets.map((dataset) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _buildDatasetCard(dataset, context),
                  )).toList(),
                  const SizedBox(height: 120),
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
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(),
      ),
    );
  }

  Widget _buildDatasetCard(Map<String, dynamic> dataset, BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      borderColor: Colors.white.withOpacity(0.1),
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => DatasetDetailScreen(dataset: {
              'title': dataset['title'],
              'url': 'https://earthdata.nasa.gov',
            }),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  dataset['title'],
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: (dataset['statusColor'] as Color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  dataset['status'],
                  style: GoogleFonts.outfit(
                    color: dataset['statusColor'],
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: (dataset['tags'] as List<String>).map((tag) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(dataset['icon'], color: Colors.white.withOpacity(0.4), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      tag,
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Last updated: Reference',
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 13,
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                color: Colors.white.withOpacity(0.3),
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
