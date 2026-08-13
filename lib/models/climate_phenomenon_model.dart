
class ClimatePhenomenon {
  final String id;
  final String name;
  final String kmlAssetPath;
  final String fileName;
  final String tourKmlPath;
  final String tourName;
  final String lookAtXml;

  const ClimatePhenomenon({
    required this.id,
    required this.name,
    required this.kmlAssetPath,
    required this.fileName,
    required this.tourKmlPath,
    required this.tourName,
    required this.lookAtXml,
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
  );

  static const ClimatePhenomenon kuroshioCurrent = ClimatePhenomenon(
    id: 'kuroshio_current',
    name: 'Kuroshio Current',
    kmlAssetPath: 'assets/kml/kuroshio_current.kml',
    fileName: 'kuroshio_current.kml',
    tourKmlPath: 'assets/kml/kuroshio_tour.kml',
    tourName: 'Kuroshio Current Guided Tour',
    lookAtXml: '<LookAt><longitude>135.0</longitude><latitude>28.0</latitude><altitude>0</altitude><heading>0</heading><tilt>45</tilt><range>6000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>',
  );

  static const ClimatePhenomenon elNino = ClimatePhenomenon(
    id: 'el_nino',
    name: 'El Niño',
    kmlAssetPath: 'assets/kml/el_nino.kml',
    fileName: 'el_nino.kml',
    tourKmlPath: 'assets/kml/el_nino_tour.kml',
    tourName: 'El Niño Guided Tour',
    lookAtXml: '<LookAt><longitude>-160.0</longitude><latitude>0.0</latitude><altitude>0</altitude><heading>0</heading><tilt>30</tilt><range>10000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>',
  );

  static const ClimatePhenomenon laNina = ClimatePhenomenon(
    id: 'la_nina',
    name: 'La Niña',
    kmlAssetPath: 'assets/kml/la_nina.kml',
    fileName: 'la_nina.kml',
    tourKmlPath: 'assets/kml/la_nina_tour.kml',
    tourName: 'La Niña Guided Tour',
    lookAtXml: '<LookAt><longitude>-160.0</longitude><latitude>0.0</latitude><altitude>0</altitude><heading>0</heading><tilt>30</tilt><range>10000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>',
  );

  static const ClimatePhenomenon gulfStream = ClimatePhenomenon(
    id: 'gulf_stream',
    name: 'Gulf Stream',
    kmlAssetPath: 'assets/kml/gulf_stream.kml',
    fileName: 'gulf_stream.kml',
    tourKmlPath: 'assets/kml/gulf_stream_tour.kml',
    tourName: 'Gulf Stream Guided Tour',
    lookAtXml: '<LookAt><longitude>-50.0</longitude><latitude>40.0</latitude><altitude>0</altitude><heading>0</heading><tilt>35</tilt><range>7000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>',
  );

  static List<ClimatePhenomenon> get all => [
    indianMonsoon,
    kuroshioCurrent,
    elNino,
    laNina,
    gulfStream,
  ];
}
