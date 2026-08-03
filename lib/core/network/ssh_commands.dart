import 'dart:math';

/// Holds all SSH command templates and KML generation logic for Liquid Galaxy.
class SSHCommands {

  // ── Screen Helpers ───────────────────────────────────────────────────────────

  /// Returns the leftmost screen index for a given total screen count.
  ///
  /// LG lays out screens as:  [left … center … right]
  /// Slave indices (for a 5-screen rig): 4 | 2 | 1 | 3 | 5
  /// The leftmost slave for N screens = floor(N/2) + 2  (N > 1).
  static int calculateLeftMostScreen(int screens) {
    if (screens == 1) return 1;
    return (screens / 2).floor() + 2;
  }

  /// Returns the rightmost screen index for a given total screen count.
  static int calculateRightMostScreen(int screens) {
    if (screens == 1) return 1;
    return (screens / 2).floor() + 1;
  }

  // ── Navigation ───────────────────────────────────────────────────────────────

  static String buildOrbit() {
    return 'echo "search=orbit" > /tmp/query.txt';
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

  // ── KML Management (kmls.txt-based overlays) ─────────────────────────────────

  /// Clears the main KML list file. Does NOT clear slave screen overlays.
  static String clearKML() {
    return 'echo "" > /var/www/html/kmls.txt';
  }

  /// Tells Google Earth to re-read kmls.txt. Does NOT affect slave_N.kml files.
  static String refreshKML() {
    return "echo 'refreshkml=true' > /tmp/query.txt";
  }

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

  // ── Slave Screen Overlays (slave_N.kml) ──────────────────────────────────────

  /// Writes an empty KML to a slave screen, clearing any overlay displayed there.
  /// Target path is /var/www/html/kml/slave_N.kml (the correct LG directory).
  static String clearScreen(int screen) {
    return "echo '${emptyKML()}' > /var/www/html/kml/slave_$screen.kml";
  }

  /// Sends the LG logo directly to the specified slave screen via SSH echo.
  /// Uses the correct path (/var/www/html/kml/) and avoids SFTP overhead.
  static String sendLogoToScreen(int screen) {
    final kml = buildLogoKML();
    return "echo '$kml' > /var/www/html/kml/slave_$screen.kml";
  }

  // ── Slave Screen Force-Refresh (myplaces.kml sed method) ────────────────────
  //
  // Google Earth on slave rigs only re-reads slave_N.kml when the LG
  // myplaces.kml entry has a refreshMode. The two-step add→remove approach
  // (from the reference LgService) triggers one reload without leaving a
  // permanent poll interval.

  /// Step 1: Temporarily adds onInterval refresh to a slave's myplaces entry.
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

  /// Step 2: Removes the temporary refreshInterval so polling doesn't persist.
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

  // ── System Commands ──────────────────────────────────────────────────────────

  static String powerOff(String password) {
    return 'echo "$password" | sudo -S poweroff';
  }

  /// Shuts down a single rig by index using the user's configured password.
  static String shutdownRig(String password, int rigIndex) {
    return 'sshpass -p $password ssh -t lg$rigIndex '
        '"echo $password | sudo -S shutdown now"';
  }

  /// Reboots a single rig by index using the user's configured password.
  static String rebootRig(String password, int rigIndex) {
    return 'sshpass -p $password ssh -t lg$rigIndex '
        '"echo $password | sudo -S reboot"';
  }

  static String restartLGService() {
    return 'sudo systemctl restart lg';
  }

  // ── KML Builders ─────────────────────────────────────────────────────────────

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
