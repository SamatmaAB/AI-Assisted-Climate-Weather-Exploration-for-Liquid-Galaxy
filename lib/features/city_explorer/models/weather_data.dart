class WeatherData {
  final double temperature;
  final String condition;
  final int humidity;
  final double windSpeed;
  final double precipitation;
  final int weatherCode;

  const WeatherData({
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.precipitation,
    required this.weatherCode,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final code = (current['weather_code'] as num).toInt();

    return WeatherData(
      temperature: (current['temperature_2m'] as num).toDouble(),
      condition: _mapWeatherCodeToText(code),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      precipitation: (current['precipitation'] as num).toDouble(),
      weatherCode: code,
    );
  }

  static String _mapWeatherCodeToText(int code) {
    if (code == 0) return 'Clear';
    if (code >= 1 && code <= 3) return 'Partly Cloudy';
    if (code >= 45 && code <= 48) return 'Foggy';
    if (code >= 51 && code <= 55) return 'Drizzle';
    if (code >= 56 && code <= 57) return 'Freezing Drizzle';
    if (code >= 61 && code <= 65) return 'Rain';
    if (code >= 66 && code <= 67) return 'Freezing Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain Showers';
    if (code >= 85 && code <= 86) return 'Snow Showers';
    if (code >= 95 && code <= 99) return 'Thunderstorm';
    return 'Cloudy';
  }
}
