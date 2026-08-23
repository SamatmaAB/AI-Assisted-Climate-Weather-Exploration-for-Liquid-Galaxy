import 'package:flutter/material.dart';

enum TaskButtonRole {

  normal,

  warning,

  destructive,
}

class TaskButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final TaskButtonRole role;
  final VoidCallback? onPressed;

  const TaskButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.role = TaskButtonRole.normal,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    switch (role) {
      case TaskButtonRole.destructive:
        return FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.errorContainer,
            foregroundColor: colorScheme.onErrorContainer,
            minimumSize: const Size(double.infinity, 72),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          child: _ButtonContent(icon: icon, label: label, textTheme: textTheme),
        );
      case TaskButtonRole.warning:
        return FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.tertiaryContainer,
            foregroundColor: colorScheme.onTertiaryContainer,
            minimumSize: const Size(double.infinity, 72),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          child: _ButtonContent(icon: icon, label: label, textTheme: textTheme),
        );
      case TaskButtonRole.normal:
        return FilledButton.tonal(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 72),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          child: _ButtonContent(icon: icon, label: label, textTheme: textTheme),
        );
    }
  }
}

class _ButtonContent extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextTheme textTheme;

  const _ButtonContent({
    required this.icon,
    required this.label,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 22),
        const SizedBox(height: 6),
        Text(
          label,
          style: textTheme.labelMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
