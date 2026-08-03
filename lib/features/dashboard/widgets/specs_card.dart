import 'package:flutter/material.dart';

/// A card displaying technical specifications for KML transfer.
class SpecsCard extends StatelessWidget {
  final Color accentColor;

  const SpecsCard({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.code_outlined, color: accentColor, size: 18),
                const SizedBox(width: 10),
                Text(
                  'KML TRANSFER SPECS',
                  style: textTheme.labelSmall?.copyWith(
                    color: accentColor,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSpecRow(context, Icons.description_outlined, 'Source', 'Ready KML Asset'),
            const SizedBox(height: 12),
            _buildSpecRow(context, Icons.place_outlined, 'Markers', 'High-Res Glyphs'),
            const SizedBox(height: 12),
            _buildSpecRow(context, Icons.sync_outlined, 'Sync', '3 Rig Nodes'),
            const SizedBox(height: 16),
            Text(
              'Prepared KML files are loaded by Flutter and sent directly to the rig.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, color: colorScheme.onSurface.withValues(alpha: 0.4), size: 18),
        const SizedBox(width: 12),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
