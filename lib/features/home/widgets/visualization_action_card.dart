import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/core/common_widgets/glass_card.dart';

/// A card representing a major climate visualization action (e.g., Monsoon, Currents).
class VisualizationActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final FutureOr<void> Function() onTap;

  const VisualizationActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.22),
            blurRadius: 28,
            spreadRadius: -8,
          ),
        ],
      ),
      child: GlassCard(
        onTap: isLoading ? null : onTap,
        padding: const EdgeInsets.all(22),
        borderRadius: 24,
        borderColor: color.withOpacity(0.28),
        backgroundColor: Colors.white.withOpacity(0.045),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withOpacity(0.25)),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const Spacer(),
                isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CupertinoActivityIndicator(color: Colors.white),
                      )
                    : const Icon(
                        CupertinoIcons.arrow_right_circle_fill,
                        color: Colors.white,
                        size: 28,
                      ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.58),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
