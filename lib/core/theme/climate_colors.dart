import 'package:flutter/material.dart';

abstract final class ClimateColors {

  static const Color monsoon = Color(0xFF4FC3F7);

  static const Color kuroshio = Color(0xFFFFCA28);

  static const Color gulfStream = Color(0xFFFFB74D);

  static const Color elNino = Color(0xFFFF8A65);

  static const Color laNina = Color(0xFF4DD0E1);

  static const Color mumbaiMonsoon = Color(0xFF81C784);

  static const Color oceanCurrents = Color(0xFF4FC3F7);

  static const Color windSystems = Color(0xFF90CAF9);

  static const Color atmospheric = Color(0xFFB39DDB);

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
