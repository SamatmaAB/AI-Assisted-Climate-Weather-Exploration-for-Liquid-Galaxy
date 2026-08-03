import 'package:flutter/material.dart';

/// A card displaying the current Liquid Galaxy rig connection status and cluster info.
///
/// Status is communicated through both icon, label text, AND color to meet
/// accessibility requirements.
class AvailabilityCard extends StatelessWidget {
  final bool isConnected;

  const AvailabilityCard({
    super.key,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final statusColor = isConnected ? colorScheme.secondary : colorScheme.error;
    final statusBgColor = isConnected ? colorScheme.secondaryContainer : colorScheme.errorContainer;
    final statusOnColor = isConnected ? colorScheme.onSecondaryContainer : colorScheme.onErrorContainer;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isConnected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                  color: statusColor,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  'Rig Availability',
                  style: textTheme.titleMedium,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isConnected ? 'ONLINE' : 'OFFLINE',
                    style: textTheme.labelSmall?.copyWith(
                      color: statusOnColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Linear progress showing connection health
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: isConnected ? 1.0 : 0.05,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, 'Node Connection', isConnected ? 'Connected' : 'Not Configured'),
            const SizedBox(height: 8),
            _buildInfoRow(context, 'Cluster Size', '3 Rigs'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.5))),
        Text(value, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
