import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/core/common_widgets/glass_card.dart';

/// A square action button used for system tasks in the controls screen.
class TaskButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const TaskButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: -5,
          ),
        ],
      ),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 20),
        borderRadius: 20,
        borderColor: color.withOpacity(0.2),
        backgroundColor: Colors.white.withOpacity(0.03),
        onTap: onPressed,
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
