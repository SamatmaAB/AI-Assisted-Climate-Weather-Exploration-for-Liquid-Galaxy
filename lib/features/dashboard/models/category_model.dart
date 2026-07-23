import 'package:flutter/cupertino.dart';

class CategoryMetadata {
  final String subTitle;
  final String description;
  final IconData icon;
  final Color themeColor;
  final String? tourKmlPath;

  CategoryMetadata({
    required this.subTitle,
    required this.description,
    required this.icon,
    required this.themeColor,
    this.tourKmlPath,
  });
}
