import 'package:flutter/material.dart';

class AppearanceCard extends StatelessWidget {
  final bool isDarkMode;
  final bool isColorblindMode;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onColorblindModeChanged;

  const AppearanceCard({
    super.key,
    required this.isDarkMode,
    required this.isColorblindMode,
    required this.onDarkModeChanged,
    required this.onColorblindModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: isDarkMode,
            onChanged: onDarkModeChanged,
          ),
          const Divider(height: 1, indent: 56),
          SwitchListTile(
            title: const Text('Color Blind Mode'),
            subtitle: const Text('Adjust palette for high contrast and color vision accessibility'),
            secondary: const Icon(Icons.visibility_outlined),
            value: isColorblindMode,
            onChanged: onColorblindModeChanged,
          ),
        ],
      ),
    );
  }
}
