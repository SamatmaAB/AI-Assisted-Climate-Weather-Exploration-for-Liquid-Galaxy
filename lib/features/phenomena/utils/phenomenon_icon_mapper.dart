/// Maps a climate phenomenon to a local Flutter asset icon and the
/// corresponding remote filename hosted on the LG web server.
///
/// Mirrors [WeatherIconMapper]. The asset paths must match pubspec.yaml
/// `assets/weather_icons/`.
class PhenomenonIconMapper {
  PhenomenonIconMapper._();

  /// Local asset path for a phenomenon id.
  static String assetPathFor(String phenomenonId) {
    return 'assets/weather_icons/${_filenameFor(phenomenonId)}';
  }

  /// Single fixed remote filename so only the *content* changes per deploy.
  static const String remoteFilename = 'phenomenon_card_icon.png';

  /// Remote path on the LG rig's web server.
  static const String remotePath = '/var/www/html/$remoteFilename';

  /// Full HTTP URL at which Google Earth can fetch the uploaded icon.
  static const String remoteUrl = 'http://lg1:81/$remoteFilename';

  // ─── Private helpers ───────────────────────────────────────────────────────

  static String _filenameFor(String id) {
    switch (id) {
      case 'indian_monsoon':
      case 'mumbai_monsoon':
        return 'monsoon.png';
      case 'kuroshio_current':
      case 'gulf_stream':
        return 'coastline.png';
      case 'el_nino':
        return 'heatwave.png';
      case 'la_nina':
        return 'cold.png';
      default:
        return 'cyclone.png';
    }
  }
}
