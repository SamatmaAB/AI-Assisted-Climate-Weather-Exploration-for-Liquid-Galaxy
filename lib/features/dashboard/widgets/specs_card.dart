import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/core/common_widgets/glass_card.dart';

/// A card displaying technical specifications for KML transfer.
class SpecsCard extends StatelessWidget {
  final Color accentColor;

  const SpecsCard({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: -5,
          ),
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
                Icon(
                  CupertinoIcons.chevron_left_slash_chevron_right,
                  color: accentColor.withOpacity(0.8),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  'KML TRANSFER SPECS',
                  style: GoogleFonts.outfit(
                    color: accentColor.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSpecRow(CupertinoIcons.doc_text, 'Source', 'Ready KML Asset'),
            const SizedBox(height: 18),
            _buildSpecRow(CupertinoIcons.location, 'Markers', 'High-Res Glyphs'),
            const SizedBox(height: 18),
            _buildSpecRow(CupertinoIcons.arrow_2_circlepath, 'Sync', '3 Rig Nodes'),
            const SizedBox(height: 24),
            Text(
              'Prepared KML files are loaded by Flutter and sent directly to the rig.',
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
}
