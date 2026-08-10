import 'dart:convert';
import 'dart:io';
import '../models/weather_data.dart';

class WeatherService {
  Future<WeatherData> fetchWeather(double latitude, double longitude) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?'
        'latitude=$latitude&'
        'longitude=$longitude&'
        'current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,precipitation'
      );
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 10));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw HttpException('Failed to fetch weather: ${response.statusCode}');
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final data = json.decode(responseBody) as Map<String, dynamic>;

      if (data['current'] == null) {
        throw const FormatException('Missing current weather data from API response');
      }

      return WeatherData.fromJson(data);
    } finally {
      client.close();
    }
  }
}
