import 'package:flutter/cupertino.dart';
import 'package:lg_connection/core/theme/app_colors.dart';
import 'package:lg_connection/features/datasets/models/dataset_model.dart';

/// Provides a list of available climate datasets with full metadata.
class DatasetsProvider {
  static List<Dataset> getDatasets() {
    return [
      Dataset(
        title: 'NASA Earth Observations',
        tags: ['Atmosphere/Ocean', 'Layer source'],
        status: 'Ready',
        statusColor: AppColors.electricBlue,
        icon: CupertinoIcons.doc_text,
        url: 'https://earthdata.nasa.gov',
        description: 'NASA Earthdata provides access to a wide range of Earth observation datasets collected from satellites and climate monitoring systems.',
        visualizationPoints: ['Global wind patterns', 'Atmospheric moisture transport', 'Temperature anomalies'],
        tourKmlPath: 'assets/kml/indianmonsoon_tour.kml',
      ),
      Dataset(
        title: 'NOAA Ocean Currents',
        tags: ['Current Path', 'KML-ready'],
        status: 'Synced',
        statusColor: AppColors.electricBlue,
        icon: CupertinoIcons.doc_text,
        url: 'https://earthdata.nasa.gov',
        description: 'NASA satellite missions collect global ocean data including sea surface temperature, ocean circulation, and ocean heat transport.',
        visualizationPoints: ['Warm and cold ocean currents', 'Global ocean circulation', 'Marine climate interactions'],
        tourKmlPath: 'assets/kml/kuroshio_tour.kml',
      ),
      Dataset(
        title: 'Tropical Cyclone Track',
        tags: ['Intensity', 'Historical'],
        status: 'Ready',
        statusColor: AppColors.electricBlue,
        icon: CupertinoIcons.doc_text,
        url: 'https://earthdata.nasa.gov',
        description: 'The cyclone track dataset contains historical records of tropical storms and hurricanes around the world, including intensity and trajectories.',
        visualizationPoints: ['Cyclone formation locations', 'Storm trajectories', 'Intensity changes'],
        tourKmlPath: 'assets/kml/gulf_stream_tour.kml',
      ),
      Dataset(
        title: 'Atmospheric Circulation Models',
        tags: ['Vector Field', 'Tour source'],
        status: 'Live',
        statusColor: AppColors.neonGreen,
        icon: CupertinoIcons.doc_text,
        url: 'https://earthdata.nasa.gov',
        description: 'Tracking ocean temperature anomalies and atmospheric changes associated with the El Niño–Southern Oscillation.',
        visualizationPoints: ['El Niño warming events', 'La Niña cooling patterns', 'Pacific climate variability'],
        tourKmlPath: 'assets/kml/el_nino_tour.kml',
      ),
    ];
  }
}
