/// Maps a WMO weather code to a local Flutter asset path and the
/// corresponding remote filename that will be hosted on the LG web server.
///
/// The asset paths match exactly what is declared in pubspec.yaml under
/// `assets/weather_icons/`.
class WeatherIconMapper {
  WeatherIconMapper._();

  /// Returns the Flutter asset path for [weatherCode].
  ///
  /// Example: `assets/weather_icons/rain.png`
  static String assetPathFor(int weatherCode) {
    return 'assets/weather_icons/${_filenameFor(weatherCode)}';
  }

  /// Returns the bare filename that the icon will be stored as on the LG web
  /// server (e.g. `rain.png`). The remote path will be:
  ///   `/var/www/html/city_explorer_weather_icon.png`
  /// Because we always use a single fixed remote name we don't need to vary the
  /// filename — only the *content* changes per exploration.
  static const String remoteFilename = 'city_explorer_weather_icon.png';

  /// Remote path on the LG rig's web server.
  static const String remotePath = '/var/www/html/$remoteFilename';

  /// Full HTTP URL at which Google Earth can fetch the uploaded icon.
  static const String remoteUrl = 'http://lg1:81/$remoteFilename';

  // ─── Private helpers ───────────────────────────────────────────────────────

  static String _filenameFor(int code) {
    // WMO 0: clear sky
    if (code == 0) return 'clear.png';

    // WMO 1–3: mainly clear / partly cloudy / overcast
    if (code >= 1 && code <= 3) return 'partly_cloudy.png';

    // WMO 45–48: fog and depositing rime fog
    if (code >= 45 && code <= 48) return 'fog.png';

    // WMO 51–57: drizzle (light, moderate, dense; freezing)
    if (code >= 51 && code <= 57) return 'rain.png';

    // WMO 61–67: rain (slight, moderate, heavy; freezing)
    if (code >= 61 && code <= 67) return 'rain.png';

    // WMO 71–77: snowfall / snow grains / ice crystals
    if (code >= 71 && code <= 77) return 'cold.png';

    // WMO 80–82: rain showers (slight, moderate, violent)
    if (code >= 80 && code <= 82) return 'rain.png';

    // WMO 85–86: snow showers
    if (code >= 85 && code <= 86) return 'cold.png';

    // WMO 95–99: thunderstorm (slight, moderate, with hail)
    if (code >= 95 && code <= 99) return 'thunderstorm.png';

    // Fallback
    return 'cloudy.png';
  }
}


