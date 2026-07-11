import 'package:flutter/cupertino.dart';

/// Represents a climate dataset repository entry with detailed information.
class Dataset {
  final String title;
  final List<String> tags;
  final String status;
  final Color statusColor;
  final IconData icon;
  final String url;
  final String description;
  final List<String> visualizationPoints;

  Dataset({
    required this.title,
    required this.tags,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.url,
    required this.description,
    required this.visualizationPoints,
  });
}
