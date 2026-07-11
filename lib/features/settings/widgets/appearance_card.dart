import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/core/common_widgets/glass_card.dart';

class AppearanceCard extends StatelessWidget {
  final bool isDarkMode;
  final bool isColorblindMode;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onColorblindModeChanged;
  final Color activeColor;

  const AppearanceCard({
    super.key,
    required this.isDarkMode,
    required this.isColorblindMode,
    required this.onDarkModeChanged,
    required this.onColorblindModeChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      borderRadius: 28,
      borderColor: Colors.white.withOpacity(0.04),
      backgroundColor: Colors.white.withOpacity(0.02),
      child: Column(
        children: [
          _buildSwitchRow(
            'Dark Mode',
            CupertinoIcons.moon,
            isDarkMode,
            onDarkModeChanged,
            activeColor,
          ),
          _buildDivider(),
          _buildSwitchRow(
            'Color Blind Mode',
            CupertinoIcons.eye,
            isColorblindMode,
            onColorblindModeChanged,
            activeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
    String label,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
    Color activeColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
          Transform.scale(
            scale: 0.8,
            child: CupertinoSwitch(
              value: value,
              activeColor: activeColor.withOpacity(0.7),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white.withOpacity(0.03), height: 1, indent: 64);
  }
}
