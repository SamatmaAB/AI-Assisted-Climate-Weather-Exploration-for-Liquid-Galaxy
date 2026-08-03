import 'package:flutter/material.dart';
import 'package:lg_connection/features/datasets/models/dataset_model.dart';

/// Detailed view for a specific climate dataset.
class DatasetDetailScreen extends StatelessWidget {
  final Dataset dataset;

  const DatasetDetailScreen({super.key, required this.dataset});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(dataset.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              label: Text(dataset.status),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Global Research Federation Repository',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          _buildSectionHeader(context, 'ABSTRACT'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                dataset.description,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader(context, 'VISUALIZATION CAPABILITIES'),
          const SizedBox(height: 8),
          ...dataset.visualizationPoints.map((point) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.circle, size: 8, color: colorScheme.primary),
                title: Text(point, style: textTheme.bodyMedium),
              ),
            );
          }),
          const SizedBox(height: 24),

          _buildSectionHeader(context, 'SOURCE METADATA'),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.link_outlined),
              title: Text(
                'OFFICIAL REPOSITORY',
                style: textTheme.labelSmall?.copyWith(color: colorScheme.primary),
              ),
              subtitle: Text(
                dataset.url,
                style: textTheme.bodyMedium?.copyWith(
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.open_in_new_outlined, size: 18),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 32),
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
}
