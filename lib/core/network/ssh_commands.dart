import 'dart:math';

class SSHCommands {

  static int calculateLeftMostScreen(int screens) {
    if (screens == 1) return 1;
    return (screens / 2).floor() + 2;
  }

  static int calculateRightMostScreen(int screens) {
    if (screens == 1) return 1;
    return (screens / 2).floor() + 1;
  }

  static String buildOrbit() {
    return 'echo "playtour=Orbit" > /tmp/query.txt';
  }

  static String buildOrbitTourKml({
    required double latitude,
    required double longitude,
    required double range,
    required double tilt,
    required double heading,
    int rotations = 3,
    int stepDegrees = 10,
    double stepDuration = 1.0,
  }) {
    final StringBuffer playlist = StringBuffer();
    final int totalSteps = (360 ~/ stepDegrees) * rotations;

    for (int i = 0; i <= totalSteps; i++) {
      final double currentHeading = (heading + (i * stepDegrees)) % 360;
      playlist.write('''
      <gx:FlyTo>
        <gx:duration>$stepDuration</gx:duration>
        <gx:flyToMode>smooth</gx:flyToMode>
        <LookAt>
          <longitude>$longitude</longitude>
          <latitude>$latitude</latitude>
          <altitude>0</altitude>
          <heading>$currentHeading</heading>
          <tilt>$tilt</tilt>
          <range>$range</range>
          <gx:altitudeMode>relativeToGround</gx:altitudeMode>
        </LookAt>
      </gx:FlyTo>''');
    }

    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <gx:Tour>
    <name>Orbit</name>
    <gx:Playlist>
$playlist
    </gx:Playlist>
  </gx:Tour>
</kml>''';
  }

  static String flyTo(String lookAt) {
    return 'echo "flytoview=$lookAt" > /tmp/query.txt';
  }

  static String flyToCoordinates(
    double latitude,
    double longitude,
    double zoom,
    double tilt,
    double bearing,
  ) {
    double range = 591657550.5 / pow(2, zoom - 1);
    String lookAt =
        '<LookAt><longitude>$longitude</longitude><latitude>$latitude</latitude>'
        '<range>$range</range><tilt>$tilt</tilt><heading>$bearing</heading>'
        '<gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>';
    return flyTo(lookAt);
  }

  static String stopTour() {
    return 'echo "exittour=true" > /tmp/query.txt';
  }

  static String playTour(String tourName) {
    return 'echo "playtour=$tourName" > /tmp/query.txt';
  }

  static String clearKML() {
    return 'echo "" > /var/www/html/kmls.txt';
  }

  static String refreshKML() {
    return "echo 'refreshkml=true' > /tmp/query.txt";
  }

  static String clearAndRefreshKML() {
    return 'echo "" > /var/www/html/kmls.txt && echo \'refreshkml=true\' > /tmp/query.txt';
  }

  static String setKMLsAndRefresh(List<String> fileNames) {
    final urls = fileNames.map((name) => 'http://lg1:81/$name').join('\\n');
    return 'echo -e "$urls" > /var/www/html/kmls.txt && echo \'refreshkml=true\' > /tmp/query.txt';
  }

  static String masterKmlPath() => '/var/www/html/kml/master.kml';
  static String masterKmlUrl() => 'http://lg1:81/kml/master.kml';

  static String setKML(String fileName) {
    return 'echo "http://lg1:81/$fileName" > /var/www/html/kmls.txt';
  }

  static String setKMLs(List<String> fileNames) {
    final urls = fileNames.map((name) => 'http://lg1:81/$name').join('\n');
    return 'echo "$urls" > /var/www/html/kmls.txt';
  }

  static String setKMLWithHost(String host, String fileName) {
    return 'echo "http://$host:81/$fileName" > /var/www/html/kmls.txt';
  }

  static String clearScreen(int screen) {
    return "echo '${emptyKML()}' > /var/www/html/kml/slave_$screen.kml";
  }

  static String sendLogoToScreen(int screen) {
    final kml = buildLogoKML();
    return "echo '$kml' > /var/www/html/kml/slave_$screen.kml";
  }

  static String addRefreshInterval(
      int screen, int interval, String password) {
    final search =
        '<href>##LG_PHPIFACE##kml\\/slave_$screen.kml<\\/href>';
    final replace =
        '<href>##LG_PHPIFACE##kml\\/slave_$screen.kml<\\/href>'
        '<refreshMode>onInterval<\\/refreshMode>'
        '<refreshInterval>$interval<\\/refreshInterval>';
    final sedCmd =
        'echo $password | sudo -S sed -i "s|$search|$replace|" '
        '~/earth/kml/slave/myplaces.kml';
    return "sshpass -p $password ssh -t lg$screen '$sedCmd'";
  }

  static String removeRefreshInterval(int screen, String password) {
    final search =
        '<href>##LG_PHPIFACE##kml\\/slave_$screen.kml<\\/href>'
        '<refreshMode>onInterval<\\/refreshMode>'
        '<refreshInterval>[0-9]+<\\/refreshInterval>';
    final replace =
        '<href>##LG_PHPIFACE##kml\\/slave_$screen.kml<\\/href>';
    final sedCmd =
        'echo $password | sudo -S sed -i "s|$search|$replace|" '
        '~/earth/kml/slave/myplaces.kml';
    return "sshpass -p $password ssh -t lg$screen '$sedCmd'";
  }

  static String powerOff(String password) {
    return 'echo "$password" | sudo -S poweroff';
  }

  static String shutdownRig(String password, int rigIndex) {
    return 'sshpass -p $password ssh -t lg$rigIndex '
        '"echo $password | sudo -S shutdown now"';
  }

  static String rebootRig(String password, int rigIndex) {
    return 'sshpass -p $password ssh -t lg$rigIndex '
        '"echo $password | sudo -S reboot"';
  }

  static String restartLGService() {
    return 'sudo systemctl restart lg';
  }

  static String buildLogoKML() {
    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
    <ScreenOverlay>
      <name>Liquid Galaxy Logo</name>
      <Icon>
        <href>https://i.imgur.com/knApxRm.png</href>
      </Icon>
      <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
      <screenXY x="0.02" y="0.98" xunits="fraction" yunits="fraction"/>
      <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
      <size x="150" y="120" xunits="pixels" yunits="pixels"/>
    </ScreenOverlay>
</Document>
</kml>''';
  }

  static String emptyKML() {
    return '<?xml version="1.0" encoding="UTF-8"?>'
        '<kml xmlns="http://www.opengis.net/kml/2.2">'
        '<Document></Document></kml>';
  }
}
