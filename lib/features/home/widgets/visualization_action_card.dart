import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lg_connection/core/theme/climate_colors.dart';

/// A card representing a major climate visualization action.
///
/// Climate domain identity is expressed through the icon tint (domain color),
/// while the card surface itself uses M3 surface containers.
class VisualizationActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String climateName;
  final bool isLoading;
  final FutureOr<void> Function() onTap;

  const VisualizationActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.climateName,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final domainColor = ClimateColors.forPhenomenon(climateName);

    return Card(
      child: InkWell(
        onTap: isLoading ? null : () => onTap(),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Domain-colored icon container
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
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
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
    );
  }
}
