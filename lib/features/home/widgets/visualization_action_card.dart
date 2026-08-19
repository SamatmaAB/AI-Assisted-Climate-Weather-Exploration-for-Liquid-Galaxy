import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lg_connection/core/theme/climate_colors.dart';
import 'package:lg_connection/features/onboarding/widgets/mascot_animation.dart';

class VisualizationActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String climateName;
  final bool isLoading;
  final bool isEnabled;
  final FutureOr<void> Function() onTap;

  const VisualizationActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.climateName,
    required this.isLoading,
    this.isEnabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final domainColor = ClimateColors.forPhenomenon(climateName);

    return Card(
      child: InkWell(
        onTap: (isEnabled && !isLoading) ? () => onTap() : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedOpacity(
          opacity: isEnabled ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: domainColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: domainColor, size: 22),
                    ),
                    const Spacer(),
                    if (isLoading)
                      const MascotAnimation(
                        assetPath: 'assets/spriteanimations/thinking.webp',
                        width: 36,
                        height: 36,
                      )
                    else
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
