import 'dart:math' as math;
import 'package:flutter/foundation.dart';

class LookAt {
  final double latitude;
  final double longitude;
  final double zoom;
  final double tilt;
  final double bearing;

  const LookAt({
    required this.latitude,
    required this.longitude,
    required this.zoom,
    this.tilt = 0.0,
    this.bearing = 0.0,
  });

  factory LookAt.fromXml(String lookAtXml) {
    try {
      final latMatch = RegExp(r'<latitude>([^<]+)</latitude>').firstMatch(lookAtXml);
      final lngMatch = RegExp(r'<longitude>([^<]+)</longitude>').firstMatch(lookAtXml);
      final tiltMatch = RegExp(r'<tilt>([^<]+)</tilt>').firstMatch(lookAtXml);
      final headingMatch = RegExp(r'<heading>([^<]+)</heading>').firstMatch(lookAtXml);
      final rangeMatch = RegExp(r'<range>([^<]+)</range>').firstMatch(lookAtXml);

      if (latMatch == null || lngMatch == null) {
        throw const FormatException('Latitude or Longitude tags missing in LookAt XML');
      }

      final lat = double.parse(latMatch.group(1)!);
      final lng = double.parse(lngMatch.group(1)!);
      final tiltValue = tiltMatch != null ? double.parse(tiltMatch.group(1)!) : 0.0;
      final headingValue = headingMatch != null ? double.parse(headingMatch.group(1)!) : 0.0;
      final rangeValue = rangeMatch != null ? double.parse(rangeMatch.group(1)!) : 1000.0;

      double zoomValue = (math.log(591657550.5 / rangeValue) / math.log(2)) + 1.0 - 3.8;
      if (zoomValue < 1.0) zoomValue = 1.0;
      if (zoomValue > 21.0) zoomValue = 21.0;

      return LookAt(
        latitude: lat,
        longitude: lng,
        zoom: zoomValue,
        tilt: tiltValue,
        bearing: headingValue,
      );
    } catch (e) {
      debugPrint('Error parsing LookAt XML, falling back to defaults: $e');
      return const LookAt(latitude: 20.5937, longitude: 78.9629, zoom: 4.0);
    }
  }

  String toXml() {

    final double adjustedZoom = zoom + 3.8;
    final double range = 591657550.5 / math.pow(2, adjustedZoom - 1);
    return '<LookAt>'
        '<longitude>$longitude</longitude>'
        '<latitude>$latitude</latitude>'
        '<altitude>0</altitude>'
        '<heading>$bearing</heading>'
        '<tilt>$tilt</tilt>'
        '<range>$range</range>'
        '<gx:altitudeMode>relativeToGround</gx:altitudeMode>'
        '</LookAt>';
  }
}
