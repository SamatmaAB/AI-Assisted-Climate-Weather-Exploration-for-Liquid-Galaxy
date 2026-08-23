
class PhenomenonIconMapper {
  PhenomenonIconMapper._();

  static String assetPathFor(String phenomenonId) {
    return 'assets/weather_icons/${_filenameFor(phenomenonId)}';
  }

  static const String remoteFilename = 'phenomenon_card_icon.png';

  static const String remotePath = '/var/www/html/$remoteFilename';

  static const String remoteUrl = 'http://lg1:81/$remoteFilename';

  static String _filenameFor(String id) {
    switch (id) {
      case 'indian_monsoon':
        return 'monsoon.png';
      case 'kuroshio_current':
      case 'gulf_stream':
        return 'coastal_flooding.png';
      case 'el_nino':
        return 'heatwave.png';
      case 'la_nina':
        return 'cold.png';
      default:
        return 'cyclone.png';
    }
  }
}
