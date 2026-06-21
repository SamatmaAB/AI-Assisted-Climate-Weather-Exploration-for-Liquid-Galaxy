import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SSH {
  static final SSH _instance = SSH._internal();
  factory SSH() => _instance;
  SSH._internal();

  late String _host;
  late String _port;
  late String _username;
  late String _passwordOrKey;
  late String _numberOfRigs;
  SSHClient? _client;

  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);

  Future<void> initConnectionDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('ipAddress') ?? 'default_host';
    _port = prefs.getString('sshPort') ?? '22';
    _username = prefs.getString('username') ?? 'lg';
    _passwordOrKey = prefs.getString('password') ?? 'lg';
    _numberOfRigs = prefs.getString('numberOfRigs') ?? '3';
  }

  Future<bool> connectToLG() async {
    await initConnectionDetails();

    if (_host == 'default_host' || _host.isEmpty) {
      isConnected.value = false;
      return false;
    }

    try {
      final socket = await SSHSocket.connect(_host, int.parse(_port), timeout: const Duration(seconds: 5));

      _client = SSHClient(
        socket,
        username: _username,
        onPasswordRequest: () => _passwordOrKey,
      );

      await _client!.authenticated;
      isConnected.value = true;

      _client!.done.then((_) {
        isConnected.value = false;
        _client = null;
      });

      return true;
    } on SocketException catch (e) {
      debugPrint('Failed to connect: $e');
      isConnected.value = false;
      return false;
    } catch (e) {
      debugPrint('An error occurred during connection: $e');
      isConnected.value = false;
      return false;
    }
  }

  Future<SSHSession?> _execute(String command) async {
    try {
      if (_client == null || isConnected.value == false) {
        bool connected = await connectToLG();
        if (!connected) return null;
      }
      return await _client!.execute(command);
    } on SSHStateError {
      debugPrint('Connection lost, reconnecting...');
      bool connected = await connectToLG();
      if (!connected) return null;
      try {
        return await _client!.execute(command);
      } catch (e) {
        debugPrint('Command failed on second attempt: $e');
        return null;
      }
    } catch (e) {
      debugPrint('An error occurred during execution: $e');
      return null;
    }
  }

  Future<bool> executeCommand(String command) async {
    final session = await _execute(command);
    if (session == null) return false;
    await session.done;
    return true;
  }

  Future<void> shutdownLG() async {
    await initConnectionDetails();
    await executeCommand('echo "$_passwordOrKey" | sudo -S poweroff');
  }

  Future<void> rebootLG() async {
    await initConnectionDetails();
    int rigs = int.tryParse(_numberOfRigs) ?? 3;
    for (var i = 1; i <= rigs; i++) {
      await executeCommand('sshpass -p $_passwordOrKey ssh -t lg@lg$i "sudo reboot"');
    }
  }

  Future<void> _sendKML(String kml, String fileName) async {
    await _execute("cat <<'EOF' > /var/www/html/kml/$fileName\n$kml\nEOF");
  }

  Future<void> _sendVisualizationKML(String kml, String fileName) async {
    await _execute("cat <<'EOF' > /var/www/html/$fileName\n$kml\nEOF");
  }

  Future<void> _loadNetworkLink(String fileName) async {
    String networkLinkKml = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
  <NetworkLink>
    <name>Earth Systems Layer</name>
    <Link>
      <href>http://$_host:81/$fileName</href>
      <refreshMode>onInterval</refreshMode>
      <refreshInterval>1</refreshInterval>
    </Link>
  </NetworkLink>
</Document>
</kml>
''';

    await _sendKML(networkLinkKml, 'master.kml');
  }

  Future<void> flyTo(String lookAt) async {
    await _execute('echo "flytoview=$lookAt" > /tmp/query.txt');
  }

  Future<void> flyToCoordinates(double latitude, double longitude, double zoom, double tilt, double bearing) async {
    double range = 591657550.5 / pow(2, zoom - 1);
    String lookAt = '<LookAt><longitude>$longitude</longitude><latitude>$latitude</latitude><range>$range</range><tilt>$tilt</tilt><heading>$bearing</heading><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt>';
    await flyTo(lookAt);
  }

  Future<void> clearKML() async {
    String emptyKML = '<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2"><Document></Document></kml>';
    await _sendKML(emptyKML, 'master.kml');
    await executeCommand("echo 'refreshkml' > /tmp/query.txt");
  }

  Future<void> sendLogo() async {
    String logoKML = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
    <ScreenOverlay>
      <name>Logo</name>
      <Icon>
        <href>https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjzI4JzY6oUy-dQaiW-HLmn5NQ7qiw7NUOoK-2cDU9cI6JwhPrNv0EkCacuKWFViEgXYrCFzlbCtHZQffY6a73j6_ATFjfeU7r6OxXxN5K8sGjfOlp3vvd6eCXZrozlu34fUG5_cKHmzZWa4axb-vJRKjLr2tryz0Zw30gTv3S0ET57xsCiD25WMPn3wA/s800/LIQUIDGALAXYLOGO.png</href>
      </Icon>
      <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
      <screenXY x="0.02" y="0.95" xunits="fraction" yunits="fraction"/>
      <size x="0.3" y="0" xunits="fraction" yunits="fraction"/>
    </ScreenOverlay>
</Document>
</kml>''';
    await _sendKML(logoKML, 'slave_1.kml');
    await executeCommand("echo 'refreshkml' > /tmp/query.txt");
  }

  Future<void> visualizeIndianMonsoon() async {
    String kmlContent = _getIndianMonsoonKML();

    await _sendVisualizationKML(
      kmlContent,
      'monsoon.kml',
    );

    await _loadNetworkLink('monsoon.kml');

    String lookAt =
        '<LookAt><longitude>78.9629</longitude><latitude>20.5937</latitude><altitude>0</altitude><heading>0</heading><tilt>45</tilt><range>5000000</range><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt>';

    await flyTo(lookAt);

    await executeCommand("echo 'refreshkml' > /tmp/query.txt");
  }

  Future<void> visualizeKuroshioCurrent() async {
    String kmlContent = _getKuroshioCurrentKML();

    await _sendVisualizationKML(
      kmlContent,
      'kuroshio.kml',
    );

    await _loadNetworkLink('kuroshio.kml');

    String lookAt =
        '<LookAt><longitude>135.0</longitude><latitude>35.0</latitude><altitude>0</altitude><heading>0</heading><tilt>30</tilt><range>4000000</range><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt>';

    await flyTo(lookAt);

    await executeCommand("echo 'refreshkml' > /tmp/query.txt");
  }

  Future<void> buildOrbit() async {
    await executeCommand("echo 'search=orbit' > /tmp/query.txt");
  }

  // --- KML Construction Logic (Ported from Python) ---

  String _getIndianMonsoonKML() {
    StringBuffer kml = StringBuffer();
    kml.write('<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2"><Document><name>Indian Monsoon</name>');
    const String RAIN = "https://i.imgur.com/qoXQjzD.png";
    const String LOW = "https://i.imgur.com/VJIrVJN.png";

    kml.write(_genArrow([63.0, 15.0], [70.0, 22.0], 2.0));
    kml.write(_genArrow([64.0, 10.0], [72.8, 18.8], 2.5));
    kml.write(_genArrow([66.0, 6.0], [75.0, 13.0], 2.5));
    kml.write(_genArrow([69.0, 3.0], [76.2, 9.9], 2.0));
    kml.write(_genArrow([86.0, 12.0], [91.5, 22.5], 2.5));
    kml.write(_genArrow([84.0, 10.0], [88.3, 21.5], 2.5));
    kml.write(_genArrow([81.0, 7.0], [84.5, 18.0], 2.0));
    kml.write(_genArrow([87.0, 23.0], [78.0, 27.0], -2.0));
    kml.write(_icon(73.0, 27.0, LOW, 5.0));
    for (var p in [[76.2, 10.5], [75.5, 13.5], [73.5, 19.2], [79.0, 21.0], [85.5, 18.5], [92.5, 25.2], [85.0, 24.5], [77.0, 28.5]]) {
      kml.write(_icon(p[0].toDouble(), p[1].toDouble(), RAIN, 3.5));
    }
    kml.write('</Document></kml>');
    return kml.toString();
  }

  String _getKuroshioCurrentKML() {
    StringBuffer kml = StringBuffer();
    kml.write('<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2"><Document><name>Kuroshio Current</name>');
    kml.write(_genArrowGrad([120.0, 18.0], [122.5, 24.0], [126.8, 25.8], [220, 30, 30], [255, 120, 0]));
    kml.write(_genArrowGrad([129.0, 27.5], [131.0, 33.0], [135.0, 32.5], [255, 120, 0], [255, 220, 0]));
    kml.write(_genArrowGrad([137.0, 33.0], [138.5, 37.5], [140.0, 36.0], [255, 220, 0], [0, 220, 255]));
    kml.write(_genArrowGrad([142.0, 37.5], [150.0, 44.0], [165.0, 49.0], [0, 220, 255], [0, 100, 255]));
    kml.write(_icon(121.56, 25.03, "https://i.imgur.com/CNAwh6Z.png", 2.0));
    kml.write(_icon(127.68, 26.21, "https://i.imgur.com/CNAwh6Z.png", 2.0));
    kml.write(_icon(139.76, 35.68, "https://i.imgur.com/CNAwh6Z.png", 2.0));
    kml.write(_icon(140.87, 38.27, "https://i.imgur.com/CNAwh6Z.png", 2.0));
    kml.write('</Document></kml>');
    return kml.toString();
  }

  String _genArrow(List<double> s, List<double> e, double c) {
    double cx = (s[0] + e[0]) / 2; double cy = (s[1] + e[1]) / 2 + c;
    List<List<double>> pts = _bezier(s, [cx, cy], e, 120);
    String r = "";
    for (int i = 0; i < pts.length - 1; i++) {
      int g = (255 * (i / (pts.length - 1))).toInt();
      r += _poly(pts[i], pts[i+1], "b3ff${g.toRadixString(16).padLeft(2, '0')}00", 0.35);
    }
    return r;
  }

  String _genArrowGrad(List<double> s, List<double> ct, List<double> e, List<int> sr, List<int> er) {
    List<List<double>> pts = _bezier(s, ct, e, 80);
    String r = "";
    for (int i = 0; i < pts.length - 1; i++) {
      double t = i / (pts.length - 1);
      int red = (sr[0] + (er[0] - sr[0]) * t).toInt();
      int gre = (sr[1] + (er[1] - sr[1]) * t).toInt();
      int blu = (sr[2] + (er[2] - sr[2]) * t).toInt();
      String col = "ff${blu.toRadixString(16).padLeft(2, '0')}${gre.toRadixString(16).padLeft(2, '0')}${red.toRadixString(16).padLeft(2, '0')}";
      r += _poly(pts[i], pts[i+1], col, 0.28);
    }
    return r;
  }

  List<List<double>> _bezier(List<double> s, List<double> c, List<double> e, int steps) {
    List<List<double>> r = [];
    for (int i = 0; i <= steps; i++) {
      double t = i / steps;
      double x = pow(1 - t, 2) * s[0] + 2 * (1 - t) * t * c[0] + pow(t, 2) * e[0];
      double y = pow(1 - t, 2) * s[1] + 2 * (1 - t) * t * c[1] + pow(t, 2) * e[1];
      r.add([x, y]);
    }
    return r;
  }

  String _poly(List<double> p1, List<double> p2, String color, double width) {
    double dx = p2[0] - p1[0]; double dy = p2[1] - p1[1]; double len = sqrt(dx * dx + dy * dy);
    if (len == 0) return "";
    double nx = -dy / len; double ny = dx / len;
    List<double> a = [p1[0] + nx * width, p1[1] + ny * width];
    List<double> b = [p2[0] + nx * width, p2[1] + ny * width];
    List<double> c = [p2[0] - nx * width, p2[1] - ny * width];
    List<double> d = [p1[0] - nx * width, p1[1] - ny * width];
    return '<Placemark><Style><PolyStyle><color>$color</color><outline>0</outline></PolyStyle></Style><Polygon><tessellate>1</tessellate><outerBoundaryIs><LinearRing><coordinates>${a[0]},${a[1]},0 ${b[0]},${b[1]},0 ${c[0]},${c[1]},0 ${d[0]},${d[1]},0 ${a[0]},${a[1]},0</coordinates></LinearRing></outerBoundaryIs></Polygon></Placemark>';
  }

  String _icon(double lon, double lat, String href, double scale) {
    return '<Placemark><Style><IconStyle><scale>$scale</scale><Icon><href>$href</href></Icon></IconStyle></Style><Point><coordinates>$lon,$lat,0</coordinates></Point></Placemark>';
  }
}
