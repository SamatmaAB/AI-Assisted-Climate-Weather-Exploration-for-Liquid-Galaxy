
class ClimatePhenomenon {
  final String id;
  final String name;
  final String kmlAssetPath;
  final String fileName;
  final String tourKmlPath;
  final String tourName;
  final String lookAtXml;
  final String fallbackSummary;

  const ClimatePhenomenon({
    required this.id,
    required this.name,
    required this.kmlAssetPath,
    required this.fileName,
    required this.tourKmlPath,
    required this.tourName,
    required this.lookAtXml,
    required this.fallbackSummary,
  });
}

class ClimatePhenomena {
  static const ClimatePhenomenon indianMonsoon = ClimatePhenomenon(
    id: 'indian_monsoon',
    name: 'Indian Monsoon',
    kmlAssetPath: 'assets/kml/indian_monsoon.kml',
    fileName: 'indian_monsoon.kml',
    tourKmlPath: 'assets/kml/indianmonsoon_tour.kml',
    tourName: 'Indian Monsoon Guided Tour',
    lookAtXml: '<LookAt><longitude>78.9629</longitude><latitude>20.5937</latitude><altitude>0</altitude><heading>0</heading><tilt>45</tilt><range>5000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>',
    fallbackSummary:
        'The Indian Monsoon is a seasonal climate system driven by land-ocean thermal contrasts. Summer monsoons bring moisture-laden winds from the Indian Ocean, delivering vital rainfall across South Asia.',
  );

  static const ClimatePhenomenon kuroshioCurrent = ClimatePhenomenon(
    id: 'kuroshio_current',
    name: 'Kuroshio Current',
    kmlAssetPath: 'assets/kml/kuroshio_current.kml',
    fileName: 'kuroshio_current.kml',
    tourKmlPath: 'assets/kml/kuroshio_tour.kml',
    tourName: 'Kuroshio Current Guided Tour',
    lookAtXml: '<LookAt><longitude>135.0</longitude><latitude>28.0</latitude><altitude>0</altitude><heading>0</heading><tilt>45</tilt><range>6000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>',
    fallbackSummary:
        'The Kuroshio Current is a warm, swift North Pacific ocean current. Flowing northward past Taiwan and Japan, it transports equatorial heat poleward, moderating coastal climate and supporting diverse marine ecosystems.',
  );

  static const ClimatePhenomenon elNino = ClimatePhenomenon(
    id: 'el_nino',
    name: 'El Niño',
    kmlAssetPath: 'assets/kml/el_nino.kml',
    fileName: 'el_nino.kml',
    tourKmlPath: 'assets/kml/el_nino_tour.kml',
    tourName: 'El Niño Guided Tour',
    lookAtXml: '<LookAt><longitude>-160.0</longitude><latitude>0.0</latitude><altitude>0</altitude><heading>0</heading><tilt>30</tilt><range>10000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>',
    fallbackSummary:
        'El Niño is the warming phase of the ENSO climate cycle. Unusually warm sea surface temperatures in the central and eastern tropical Pacific disrupt atmospheric circulation, triggering global weather anomalies such as flooding and droughts.',
  );

  static const ClimatePhenomenon laNina = ClimatePhenomenon(
    id: 'la_nina',
    name: 'La Niña',
    kmlAssetPath: 'assets/kml/la_nina.kml',
    fileName: 'la_nina.kml',
    tourKmlPath: 'assets/kml/la_nina_tour.kml',
    tourName: 'La Niña Guided Tour',
    lookAtXml: '<LookAt><longitude>-160.0</longitude><latitude>0.0</latitude><altitude>0</altitude><heading>0</heading><tilt>30</tilt><range>10000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>',
    fallbackSummary:
        'La Niña is the cooling phase of the ENSO climate cycle, characterized by below-average sea surface temperatures in the equatorial Pacific Ocean. It strengthens trade winds and leads to altered worldwide precipitation patterns.',
  );

  static const ClimatePhenomenon gulfStream = ClimatePhenomenon(
    id: 'gulf_stream',
    name: 'Gulf Stream',
    kmlAssetPath: 'assets/kml/gulf_stream.kml',
    fileName: 'gulf_stream.kml',
    tourKmlPath: 'assets/kml/gulf_stream_tour.kml',
    tourName: 'Gulf Stream Guided Tour',
    lookAtXml: '<LookAt><longitude>-50.0</longitude><latitude>40.0</latitude><altitude>0</altitude><heading>0</heading><tilt>35</tilt><range>7000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>',
    fallbackSummary:
        'The Gulf Stream is an intense, warm Atlantic Ocean current originating in the Gulf of Mexico. It carries tropical warmth across the North Atlantic toward Western Europe, playing a critical role in global climate regulation.',
  );

  static List<ClimatePhenomenon> get all => [
        indianMonsoon,
        kuroshioCurrent,
        elNino,
        laNina,
        gulfStream,
      ];

  static String getFallbackSummary(String query) {
    final lower = query.toLowerCase();
    for (final phenomenon in all) {
      if (lower.contains(phenomenon.name.toLowerCase()) ||
          lower.contains(phenomenon.id.toLowerCase())) {
        return phenomenon.fallbackSummary;
      }
    }
    if (lower.contains('monsoon')) return indianMonsoon.fallbackSummary;
    if (lower.contains('kuroshio')) return kuroshioCurrent.fallbackSummary;
    if (lower.contains('nino') || lower.contains('niño')) return elNino.fallbackSummary;
    if (lower.contains('nina') || lower.contains('niña')) return laNina.fallbackSummary;
    if (lower.contains('gulf') || lower.contains('stream')) return gulfStream.fallbackSummary;

    return 'Climate phenomenon exploration providing real-time oceanic and atmospheric system insights for Liquid Galaxy.';
  }
}
