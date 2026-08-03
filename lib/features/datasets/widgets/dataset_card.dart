import 'package:flutter/material.dart';
import 'package:lg_connection/features/datasets/models/dataset_model.dart';
import 'package:lg_connection/features/datasets/dataset_detail_screen.dart';

/// A card displaying summary information for a climate dataset.
class DatasetCard extends StatelessWidget {
  final Dataset dataset;

  const DatasetCard({super.key, required this.dataset});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DatasetDetailScreen(dataset: dataset),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      dataset.title,
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  _buildStatusBadge(colorScheme, textTheme),
                ],
              ),
              const SizedBox(height: 16),
              _buildTagsRow(context),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reference Dataset',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ColorScheme colorScheme, TextTheme textTheme) {
    final isAvailable = dataset.status.toLowerCase().contains('available') ||
        dataset.status.toLowerCase().contains('active');
    final bg = isAvailable ? colorScheme.secondaryContainer : colorScheme.surfaceContainerHighest;
    final fg = isAvailable ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        dataset.status,
        style: textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildTagsRow(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: dataset.tags.map((tag) {
        return Chip(
          avatar: Icon(dataset.icon, size: 14),
          label: Text(tag),
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }
}
