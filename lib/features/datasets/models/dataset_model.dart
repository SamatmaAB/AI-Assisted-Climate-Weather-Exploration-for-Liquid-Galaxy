import 'package:flutter/material.dart';

class Dataset {
  final String title;
  final List<String> tags;
  final String status;
  final Color statusColor;
  final IconData icon;
  final String url;
  final String description;
  final List<String> visualizationPoints;
  final String? tourKmlPath;

  Dataset({
    required this.title,
    required this.tags,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.url,
    required this.description,
    required this.visualizationPoints,
    this.tourKmlPath,
  });
}
