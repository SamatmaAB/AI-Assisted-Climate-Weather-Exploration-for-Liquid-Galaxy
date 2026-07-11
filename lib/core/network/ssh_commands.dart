import 'dart:math';

/// Holds all SSH command templates and KML generation logic for Liquid Galaxy.
class SSHCommands {
  static String buildOrbit() {
    return 'echo "search=orbit" > /tmp/query.txt';
  }

  static String flyTo(String lookAt) {
    return 'echo "flytoview=$lookAt" > /tmp/query.txt';
  }

  static String flyToCoordinates(double latitude, double longitude, double zoom, double tilt, double bearing) {
    double range = 591657550.5 / pow(2, zoom - 1);
    String lookAt =
        '<LookAt><longitude>$longitude</longitude><latitude>$latitude</latitude><range>$range</range><tilt>$tilt</tilt><heading>$bearing</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>';
    return flyTo(lookAt);
  }

  static String refreshKML() {
    return "echo 'refreshkml=true' > /tmp/query.txt";
  }

  static String stopTour() {
    return 'echo "exittour=true" > /tmp/query.txt';
  }

  static String clearKML() {
    return 'echo "" > /var/www/html/kmls.txt';
  }

  static String setKML(String fileName) {
    return 'echo "http://lg1:81/$fileName" > /var/www/html/kmls.txt';
  }

  static String setKMLWithHost(String host, String fileName) {
    return 'echo "http://$host:81/$fileName" > /var/www/html/kmls.txt';
  }

  static String powerOff(String password) {
    return 'echo "$password" | sudo -S poweroff';
  }

  static String rebootRig(String password, int rigIndex) {
    return 'sshpass -p $password ssh -t lg@lg$rigIndex "sudo reboot"';
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
        <href>https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjzI4JzY6oUy-dQaiW-HLmn5NQ7qiw7NUOoK-2cDU9cI6JwhPrNv0EkCacuKWFViEgXYrCFzlbCtHZQffY6a73j6_ATFjfeU7r6OxXxN5K8sGjfOlp3vvd6eCXZrozlu34fUG5_cKHmzZWa4axb-vJRKjLr2tryz0Zw30gTv3S0ET57xsCiD25WMPn3wA/s800/LIQUIDGALAXYLOGO.png</href>
      </Icon>
      <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
      <screenXY x="0.05" y="0.95" xunits="fraction" yunits="fraction"/>
      <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
      <size x="0.4" y="0.2" xunits="fraction" yunits="fraction"/>
    </ScreenOverlay>
</Document>
</kml>''';
  }

  static String emptyKML() {
    return '<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2"><Document></Document></kml>';
  }
}
