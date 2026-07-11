import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/core/common_widgets/glass_card.dart';
import 'package:lg_connection/features/dashboard/category_detail_screen.dart';

/// A card used in the "More Patterns" section of the home screen.
class ExploreCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String categoryName;

  const ExploreCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => CategoryDetailScreen(
              categoryName: categoryName,
            ),
          ),
        );
      },
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      borderColor: color.withOpacity(0.22),
      backgroundColor: Colors.white.withOpacity(0.035),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 18),
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Open',
            style: GoogleFonts.outfit(
              color: color.withOpacity(0.72),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
