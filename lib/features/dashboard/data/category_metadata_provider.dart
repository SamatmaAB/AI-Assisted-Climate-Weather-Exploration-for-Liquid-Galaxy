import 'package:flutter/cupertino.dart';
import 'package:lg_connection/core/theme/app_colors.dart';
import 'package:lg_connection/features/dashboard/models/category_model.dart';

/// Provides metadata for different climate categories.
class CategoryMetadataProvider {
  static CategoryMetadata getMetadata(String categoryName) {
    switch (categoryName) {
      case 'Global Wind Systems':
        return CategoryMetadata(
          subTitle: 'Indian subcontinent',
          description: 'Arabian Sea and Bay of Bengal moisture flows toward India.',
          icon: CupertinoIcons.wind,
          themeColor: AppColors.goldAccent,
        );
      case 'Ocean Currents':
        return CategoryMetadata(
          subTitle: 'Pacific & Atlantic',
          description: 'Western boundary currents transporting heat toward the poles.',
          icon: CupertinoIcons.waveform,
          themeColor: AppColors.cyanWhite,
        );
      case 'Cyclone Formation':
        return CategoryMetadata(
          subTitle: 'Tropical Systems',
          description: 'Real-time tracking of pressure systems and storm paths.',
          icon: CupertinoIcons.cloud_rain,
          themeColor: AppColors.purpleAccent,
        );
      case 'Extreme Weather':
        return CategoryMetadata(
          subTitle: 'Thermal Analysis',
          description: 'Monitoring global temperature anomalies and heat distribution.',
          icon: CupertinoIcons.thermometer,
          themeColor: AppColors.neonGreen,
        );
      default:
        return CategoryMetadata(
          subTitle: 'Global Systems',
          description: 'Advanced planetary data visualization and monitoring.',
          icon: CupertinoIcons.wind,
          themeColor: AppColors.electricBlue,
        );
    }
  }
}
