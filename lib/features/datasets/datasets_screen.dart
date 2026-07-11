import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/core/theme/app_colors.dart';
import 'package:lg_connection/features/datasets/data/datasets_provider.dart';
import 'package:lg_connection/features/datasets/widgets/dataset_card.dart';

/// Screen displaying a list of available Earth system datasets.
class DatasetsScreen extends StatelessWidget {
  const DatasetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final datasets = DatasetsProvider.getDatasets();

    return Scaffold(
      backgroundColor: AppColors.slate950,
      body: Container(
        color: AppColors.slate950,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 40),
              Text(
                'Earth System\nData Sources',
                style: GoogleFonts.outfit(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 32),
              ...datasets.map((dataset) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: DatasetCard(dataset: dataset),
              )).toList(),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
