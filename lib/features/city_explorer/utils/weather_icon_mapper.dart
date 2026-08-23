
class WeatherIconMapper {
  WeatherIconMapper._();

  static String assetPathFor(int weatherCode) {
    return 'assets/weather_icons/${_filenameFor(weatherCode)}';
  }

  static const String remoteFilename = 'city_explorer_weather_icon.png';

  static const String remotePath = '/var/www/html/$remoteFilename';

  static const String remoteUrl = 'http://lg1:81/$remoteFilename';

  static String _filenameFor(int code) {
    
    if (code == 0) return 'clear.png';

    if (code >= 1 && code <= 3) return 'partly_cloudy.png';

    if (code >= 45 && code <= 48) return 'fog.png';

    if (code >= 51 && code <= 57) return 'rain.png';

    if (code >= 61 && code <= 67) return 'rain.png';

    if (code >= 71 && code <= 77) return 'cold.png';

    if (code >= 80 && code <= 82) return 'rain.png';

    if (code >= 85 && code <= 86) return 'cold.png';

    if (code >= 95 && code <= 99) return 'thunderstorm.png';

    return 'cloudy.png';
  }
}
