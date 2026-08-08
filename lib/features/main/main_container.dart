import 'package:flutter/material.dart';
import 'package:lg_connection/features/home/home_screen.dart';
import 'package:lg_connection/features/datasets/datasets_screen.dart';
import 'package:lg_connection/features/controls/controls_screen.dart';
import 'package:lg_connection/features/settings/settings_screen.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    DatasetsScreen(),
    ControlsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
            tooltip: 'Climate View',
          ),
          NavigationDestination(
            icon: Icon(Icons.dataset_outlined),
            selectedIcon: Icon(Icons.dataset),
            label: 'Data',
            tooltip: 'Data Sources',
          ),
          NavigationDestination(
            icon: Icon(Icons.display_settings_outlined),
            selectedIcon: Icon(Icons.display_settings),
            label: 'Rig',
            tooltip: 'Liquid Galaxy Services',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Setup',
            tooltip: 'Connection Settings',
          ),
        ],
      ),
    );
  }
}
