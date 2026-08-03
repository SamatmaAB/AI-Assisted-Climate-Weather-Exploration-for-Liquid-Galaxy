import 'package:flutter/material.dart';

/// Domain-specific colors for climate visualization overlays and category accents.
///
/// These colors represent SCIENTIFIC/DATA visualization semantics, NOT general
/// application interface semantics. They must NOT be used for buttons, navigation,
/// settings, dialogs, or generic card backgrounds.
///
/// Valid usage: climate category badges, map overlay legend, dataset tags,
/// visualization card leading icons, category accent lines.
abstract final class ClimateColors {
  /// Indian Monsoon – warm blue associated with summer rainfall systems.
  static const Color monsoon = Color(0xFF4FC3F7);

  /// Kuroshio Current – deep teal-gold associated with western boundary current.
  static const Color kuroshio = Color(0xFFFFCA28);

  /// Gulf Stream – warm amber conveyor belt.
  static const Color gulfStream = Color(0xFFFFB74D);

  /// El Niño – warm anomaly, equatorial Pacific warming.
  static const Color elNino = Color(0xFFFF8A65);

  /// La Niña – cool anomaly, equatorial Pacific cooling.
  static const Color laNina = Color(0xFF4DD0E1);

  /// Mumbai Monsoon – intensified regional precipitation.
  static const Color mumbaiMonsoon = Color(0xFF81C784);

  /// Ocean Currents category.
  static const Color oceanCurrents = Color(0xFF4FC3F7);

  /// Global Wind Systems category.
  static const Color windSystems = Color(0xFF90CAF9);

  /// Atmospheric phenomena – general.
  static const Color atmospheric = Color(0xFFB39DDB);

  /// Returns the climate domain color for a given phenomenon name.
  /// Used by visualization cards to decorate the icon without polluting
  /// the general ColorScheme.
  static Color forPhenomenon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('monsoon') && lower.contains('mumbai')) return mumbaiMonsoon;
    if (lower.contains('monsoon')) return monsoon;
    if (lower.contains('kuroshio')) return kuroshio;
    if (lower.contains('gulf')) return gulfStream;
    if (lower.contains('el niño') || lower.contains('el nino')) return elNino;
    if (lower.contains('la niña') || lower.contains('la nina')) return laNina;
    if (lower.contains('wind')) return windSystems;
    if (lower.contains('ocean') || lower.contains('current')) return oceanCurrents;
    return atmospheric;
  }
}
