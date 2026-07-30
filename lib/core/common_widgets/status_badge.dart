import 'package:flutter/material.dart';
import 'pulse_indicator.dart';

/// Displays the Liquid Galaxy rig connection status using M3 semantic colors.
///
/// The status is communicated via both color AND a text label so it is not
/// conveyed by color alone (accessibility requirement).
class StatusBadge extends StatelessWidget {
  final bool isConnected;

  const StatusBadge({
    super.key,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final statusColor = isConnected
        ? colorScheme.secondary
        : colorScheme.error;
    final label = isConnected ? 'RIG CONNECTED' : 'OFFLINE';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PulseIndicator(color: statusColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
