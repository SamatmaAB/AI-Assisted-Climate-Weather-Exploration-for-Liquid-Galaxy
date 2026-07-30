import 'package:flutter/material.dart';
import 'package:lg_connection/features/datasets/data/datasets_provider.dart';
import 'package:lg_connection/features/datasets/widgets/dataset_card.dart';

/// Screen displaying a list of available Earth system datasets.
class DatasetsScreen extends StatelessWidget {
  const DatasetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final datasets = DatasetsProvider.getDatasets();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 32),
            Text(
              'Earth System\nData Sources',
              style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700, height: 1.1),
            ),
            const SizedBox(height: 28),
            ...datasets.map(
              (dataset) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DatasetCard(dataset: dataset),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
