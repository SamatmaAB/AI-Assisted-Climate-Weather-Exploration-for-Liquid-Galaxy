import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/core/common_widgets/glass_card.dart';

/// A card displaying information about the app version and user guide.
class AboutCard extends StatelessWidget {
  const AboutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      borderRadius: 28,
      borderColor: Colors.white.withOpacity(0.04),
      backgroundColor: Colors.white.withOpacity(0.02),
      child: Column(
        children: [
          _buildAboutRow('User Guide', CupertinoIcons.book),
          _buildDivider(),
          _buildAboutRow('Version 1.0.0 (Beta)', CupertinoIcons.info),
          _buildDivider(),
          _buildAboutRow('Open Source Code', CupertinoIcons.link),
        ],
      ),
    );
  }

  Widget _buildAboutRow(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.5), size: 22),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.85),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            CupertinoIcons.arrow_up_right,
            color: Colors.white.withOpacity(0.2),
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white.withOpacity(0.03), height: 1, indent: 64);
  }
}
