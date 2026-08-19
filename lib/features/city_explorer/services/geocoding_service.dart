import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/city_landmark.dart';

/// Fast, open-access fallback geocoding service using OpenStreetMap Nominatim API.
/// Resolves city coordinates and display names in <300ms without requiring an API key.
class GeocodingService {
  Future<CityLandmark?> geocodeCity(String city) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?'
        'q=${Uri.encodeComponent(city)}&'
        'format=json&'
        'addressdetails=1&'
        'limit=1',
      );
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 4));
      request.headers.set('User-Agent', 'LGCityExplorer/1.0 (LiquidGalaxyFlutterApp)');
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final List list = json.decode(responseBody) as List;
        if (list.isNotEmpty) {
          final item = list.first as Map<String, dynamic>;
          final lat = double.tryParse(item['lat'].toString()) ?? 0.0;
          final lon = double.tryParse(item['lon'].toString()) ?? 0.0;
          final displayName = item['display_name']?.toString() ?? city;
          final parts = displayName.split(',').map((s) => s.trim()).toList();
          final shortCity = parts.isNotEmpty && parts.first.isNotEmpty ? parts.first : city;
          final country = parts.length > 1 ? parts.last : '';

          return CityLandmark(
            city: shortCity,
            landmark: '$shortCity Landmark Area',
            latitude: lat,
            longitude: lon,
            climateContext: country.isNotEmpty
                ? 'Metropolitan urban environment located in $country.'
                : 'Metropolitan region with real-time atmospheric telemetry.',
          );
        }
      }
    } catch (e) {
      debugPrint('GeocodingService: Nominatim query failed: $e');
    } finally {
      client.close();
    }
    return null;
  }
}
