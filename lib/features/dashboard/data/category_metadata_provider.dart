import 'package:flutter/material.dart';
import 'package:lg_connection/core/theme/climate_colors.dart';
import 'package:lg_connection/features/dashboard/models/category_model.dart';

class CategoryMetadataProvider {
  static CategoryMetadata getMetadata(String categoryName) {
    switch (categoryName) {
      case 'Global Wind Systems':
        return CategoryMetadata(
          subTitle: 'Indian Subcontinent',
          description: 'Arabian Sea and Bay of Bengal moisture flows toward India.',
          icon: Icons.air_outlined,
          themeColor: ClimateColors.monsoon,
          tourKmlPath: 'assets/kml/indianmonsoon_tour.kml',
        );
      case 'Ocean Currents':
        return CategoryMetadata(
          subTitle: 'Pacific & Atlantic',
          description: 'Western boundary currents transporting heat toward the poles.',
          icon: Icons.waves_outlined,
          themeColor: ClimateColors.kuroshio,
          tourKmlPath: 'assets/kml/kuroshio_tour.kml',
        );
      case 'Cyclone Formation':
        return CategoryMetadata(
          subTitle: 'Tropical Systems',
          description: 'Real-time tracking of pressure systems and storm paths.',
          icon: Icons.grain_outlined,
          themeColor: ClimateColors.atmospheric,
          tourKmlPath: 'assets/kml/gulf_stream_tour.kml',
        );
      case 'Extreme Weather':
        return CategoryMetadata(
          subTitle: 'Thermal Analysis',
          description: 'Monitoring global temperature anomalies and heat distribution.',
          icon: Icons.thermostat_outlined,
          themeColor: ClimateColors.elNino,
          tourKmlPath: 'assets/kml/el_nino_tour.kml',
        );
      default:
        return CategoryMetadata(
          subTitle: 'Global Systems',
          description: 'Advanced planetary data visualization and monitoring.',
          icon: Icons.public_outlined,
          themeColor: ClimateColors.atmospheric,
          tourKmlPath: 'assets/kml/indianmonsoon_tour.kml',
        );
    }
  }
}
