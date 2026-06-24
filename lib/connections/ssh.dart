import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
      final socket = await SSHSocket.connect(_host, int.parse(_port),
          timeout: const Duration(seconds: 5));

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

  Future<void> _sendKML(String kml, String fileName) async {
    // Robustly write multi-line KML content using a heredoc.
    await executeCommand("cat <<'EOF' > /var/www/html/kml/$fileName\n$kml\nEOF");
  }

  Future<void> sendKMLAsset(String assetPath, String targetFileName) async {
    final kml = await rootBundle.loadString(assetPath);
    await _sendKML(kml, targetFileName);
  }

  Future<void> sendKMLFromFile(String path, String targetFileName) async {
    final kml = await File(path).readAsString();
    await _sendKML(kml, targetFileName);
  }

  Future<void> flyTo(String lookAt) async {
    await executeCommand('echo "flytoview=$lookAt" > /tmp/query.txt');
  }

  Future<void> flyToCoordinates(double latitude, double longitude, double zoom,
      double tilt, double bearing) async {
    double range = 591657550.5 / pow(2, zoom - 1);
    String lookAt =
        '<LookAt><longitude>$longitude</longitude><latitude>$latitude</latitude><range>$range</range><tilt>$tilt</tilt><heading>$bearing</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>';
    await flyTo(lookAt);
  }

  Future<void> flyToMysorePalace() async {
    // Home City: Mysore, India.
    String lookAt = '<LookAt><longitude>76.6551</longitude><latitude>12.3051</latitude><altitude>0</altitude><heading>0</heading><tilt>45</tilt><range>1200</range><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt>';
    await flyTo(lookAt);
  }

  Future<void> clearKML() async {
    String emptyKML =
        '<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2"><Document></Document></kml>';
    await _sendKML(emptyKML, 'master.kml');
    await refreshKML();
  }

  Future<void> clearLogo() async {
    String emptyKML = '<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2"><Document></Document></kml>';
    // Clearing logos from potential slave screens
    int rigs = int.tryParse(_numberOfRigs) ?? 3;
    for (var i = 1; i <= rigs; i++) {
      await _sendKML(emptyKML, 'slave_$i.kml');
    }
  }

  Future<void> sendLogo() async {
    // Send logo to the left screen (slave_1.kml in a standard 3-rig system)
    String logoKML = '''<?xml version="1.0" encoding="UTF-8"?>
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
    await _sendKML(logoKML, 'slave_1.kml');
    await refreshKML();
  }

  Future<void> shutdownLG() async {
    await initConnectionDetails();
    await executeCommand('echo "$_passwordOrKey" | sudo -S poweroff');
  }

  Future<void> rebootLG() async {
    await initConnectionDetails();
    int rigs = int.tryParse(_numberOfRigs) ?? 3;
    for (var i = 1; i <= rigs; i++) {
      await executeCommand(
          'sshpass -p $_passwordOrKey ssh -t lg@lg$i "sudo reboot"');
    }
  }

  Future<void> refreshKML() async {
    await executeCommand(
      "echo 'refreshkml=true' > /tmp/query.txt",
    );
  }

  Future<void> stopTour() async {
    await executeCommand(
      'echo "exittour=true" > /tmp/query.txt',
    );
  }

  Future<void> buildOrbit() async {
    await executeCommand("echo 'search=orbit' > /tmp/query.txt");
  }

  Future<bool> cleanVisualization() async {
    return await executeCommand('> /var/www/html/kmls.txt');
  }

  Future<void> cleanSlaves() async {
    await clearLogo();
  }

  Future<void> visualizeIndianMonsoon() async {
    await stopTour();
    await cleanVisualization();
    await cleanSlaves();
    await clearKML();

    await sendKMLAsset(
      'assets/kml/indian_monsoon.kml',
      'master.kml',
    );

    String lookAt =
        '<LookAt><longitude>78.9629</longitude><latitude>20.5937</latitude><altitude>0</altitude><heading>0</heading><tilt>45</tilt><range>5000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>';

    await flyTo(lookAt);

    await refreshKML();
  }

  Future<void> visualizeKuroshioCurrent() async {
    await stopTour();
    await cleanVisualization();
    await cleanSlaves();
    await clearKML();

    await sendKMLAsset(
      'assets/kml/kuroshio_current.kml',
      'master.kml',
    );

    String lookAt =
        '<LookAt><longitude>135.0</longitude><latitude>35.0</latitude><altitude>0</altitude><heading>0</heading><tilt>30</tilt><range>4000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>';

    await flyTo(lookAt);

    await refreshKML();
  }
}
