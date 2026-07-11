import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lg_connection/core/common_widgets/glass_card.dart';
import 'package:lg_connection/core/theme/app_colors.dart';
import 'package:lg_connection/features/home/home_screen.dart';
import 'package:lg_connection/features/datasets/datasets_screen.dart';
import 'package:lg_connection/features/controls/controls_screen.dart';
import 'package:lg_connection/features/settings/settings_screen.dart';

/// The root container that manages the bottom navigation and screen switching.
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
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.slate950,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
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
            _buildNavItem(CupertinoIcons.house_fill, 'Home', 0),
            _buildNavItem(CupertinoIcons.circle_grid_hex, 'Data', 1),
            _buildNavItem(CupertinoIcons.layers_fill, 'Rig', 2),
            _buildNavItem(CupertinoIcons.settings_solid, 'Setup', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    const activeColor = AppColors.electricBlue;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: activeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
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
              style: TextStyle(
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
