import 'package:flutter/material.dart';
import 'package:lg_connection/core/theme/climate_colors.dart';
import 'package:lg_connection/features/dashboard/category_detail_screen.dart';

class ExploreCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String climateName;
  final String categoryName;

  const ExploreCard({
    super.key,
    required this.title,
    required this.icon,
    required this.climateName,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final domainColor = ClimateColors.forPhenomenon(climateName);

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryDetailScreen(categoryName: categoryName),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: domainColor, size: 24),
              const SizedBox(height: 16),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                'Explore',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
