import 'package:flutter/material.dart';

/// Screen providing technical documentation and operational guidelines.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentation'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Operational guidelines for Earth Systems Explorer and Liquid Galaxy integration.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader(context, 'MISSION OVERVIEW'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'This application is part of the GSOC project "Earth Systems Explorer: Immersive Visualization of Global Climate Processes using Liquid Galaxy". It leverages multi-display synchronization to render complex planetary phenomena.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader(context, 'OPERATIONAL PROTOCOLS'),
          const SizedBox(height: 8),
          _buildInstructionTile(
            context,
            Icons.settings_outlined,
            'Configuration',
            'Navigate to System Settings to establish the SSH handshake with the master Liquid Galaxy node.',
          ),
          const SizedBox(height: 8),
          _buildInstructionTile(
            context,
            Icons.grid_view_outlined,
            'Data Selection',
            'Identify climate phenomena from the explorer grid to initiate high-fidelity planetary overlays.',
          ),
          const SizedBox(height: 8),
          _buildInstructionTile(
            context,
            Icons.play_circle_outline,
            'Rig Synchronization',
            'Execute visualization actions to synchronize visual state across the entire cluster of displays.',
          ),
          const SizedBox(height: 24),

          _buildSectionHeader(context, 'CORE VISUALIZATIONS'),
          const SizedBox(height: 8),
          ...[
            'Global Ocean Currents',
            'Atmospheric Trade Winds',
            'ENSO Thermal States',
            'Regional Precipitation',
          ].map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.check_circle_outline, size: 20, color: colorScheme.secondary),
                title: Text(item, style: textTheme.bodyMedium),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Guided by the Liquid Galaxy Lab',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.5),
        letterSpacing: 1.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildInstructionTile(BuildContext context, IconData icon, String title, String desc) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(desc, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6))),
      ),
    );
  }
}
