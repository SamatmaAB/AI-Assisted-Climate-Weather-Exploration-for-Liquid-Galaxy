import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/core/common_widgets/glass_card.dart';

/// A card for displaying high-level information or descriptions.
class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;

  const InfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: -5,
          ),
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
}
