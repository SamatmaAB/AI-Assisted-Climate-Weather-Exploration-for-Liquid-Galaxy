import 'dart:async';
import 'package:flutter/material.dart';

/// A compact action card for destructive or utility operations.
class QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDestructive;
  final FutureOr<void> Function() onTap;
  final bool isLoading;

  const QuickActionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isDestructive) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : () => onTap(),
        icon: isLoading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.error,
          side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
          minimumSize: const Size(double.infinity, 48),
        ),
      );
    }

    return FilledButton.tonal(
      onPressed: isLoading ? null : () => onTap(),
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
      child: isLoading
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
            ),
    );
  }
}
