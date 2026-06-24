import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/screens/home_screen.dart';
import 'package:lg_connection/screens/datasets_screen.dart';
import 'package:lg_connection/screens/controls_screen.dart';
import 'package:lg_connection/screens/settings_page.dart';
import 'package:lg_connection/components/glass_card.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DatasetsScreen(),
    const ControlsScreen(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    const electricBlue = Color(0xFF3B82F6);

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF020617),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          borderRadius: 40,
          blur: 25,
          borderColor: Colors.white.withOpacity(0.05),
          backgroundColor: Colors.white.withOpacity(0.04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(CupertinoIcons.house_fill, 'Home', 0, electricBlue),
              _buildNavItem(CupertinoIcons.circle_grid_hex, 'Data', 1, electricBlue),
              _buildNavItem(CupertinoIcons.layers_fill, 'Rig', 2, electricBlue),
              _buildNavItem(CupertinoIcons.settings_solid, 'Setup', 3, electricBlue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, Color activeColor) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected ? BoxDecoration(
          color: activeColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ) : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor.withOpacity(0.9) : Colors.white.withOpacity(0.3),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? activeColor.withOpacity(0.9) : Colors.white.withOpacity(0.3),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
