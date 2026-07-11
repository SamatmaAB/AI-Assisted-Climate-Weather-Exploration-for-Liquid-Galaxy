import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/core/common_widgets/glass_card.dart';

/// A smaller card for quick actions like clearing layers.
class QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final FutureOr<void> Function() onTap;
  final bool isLoading;

  const QuickActionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: isLoading ? null : onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      borderRadius: 18,
      borderColor: color.withOpacity(0.22),
      backgroundColor: Colors.white.withOpacity(0.035),
      child: Row(
        children: [
          isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CupertinoActivityIndicator(color: Colors.white),
                )
              : Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
