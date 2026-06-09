import 'dart:async';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SSH {
  // Singleton pattern
  static final SSH _instance = SSH._internal();
  factory SSH() => _instance;
  SSH._internal();

  String? _host;
  String? _port;
  String? _username;
  String? _passwordOrKey;
  String? _numberOfRigs;
  SSHClient? _client;

  Future<void> initConnectionDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('ipAddress') ?? 'default_host';
    _port = prefs.getString('sshPort') ?? '22';
    _username = prefs.getString('username') ?? 'lg';
    _passwordOrKey = prefs.getString('password') ?? 'lg';
    _numberOfRigs = prefs.getString('numberOfRigs') ?? '3';
  }

  Future<bool?> connectToLG() async {
    await initConnectionDetails();
    try {
      final socket = await SSHSocket.connect(
        _host!, 
        int.parse(_port!),
        timeout: const Duration(seconds: 5),
      );

      _client = SSHClient(
        socket,
        username: _username!,
        onPasswordRequest: () => _passwordOrKey!,
      );

      return true;
    } catch (e) {
      print('SSH Connection Error: $e');
      return false;
    }
  }

  Future<SSHSession?> executeCommand(String command) async {
    try {
      if (_client == null || _client!.isClosed) {
        bool? connected = await connectToLG();
        if (connected != true) return null;
      }
      return await _client!.execute(command);
    } catch (e) {
      print('Execution Error: $e');
      return null;
    }
  }

  Future<void> sendLogo() async {
    String logoKML = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
  <ScreenOverlay>
    <name>Logo</name>
    <Icon><href>https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjzI4JzY6oUy-dQaiW-HLmn5NQ7qiw7NUOoK-2cDU9cI6JwhPrNv0EkCacuKWFViEgXYrCFzlbCtHZQffY6a73j6_ATFjfeU7r6OxXxN5K8sGjfOlp3vvd6eCXZrozlu34fUG5_cKHmzZWa4axb-vJRKjLr2tryz0Zw30gTv3S0ET57xsCiD25WMPn3wA/s800/LIQUIDGALAXYLOGO.png</href></Icon>
    <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
    <screenXY x="0.02" y="0.95" xunits="fraction" yunits="fraction"/>
    <size x="0.3" y="0" xunits="fraction" yunits="fraction"/>
  </ScreenOverlay>
</Document>
</kml>''';
    
    await _sendKMLToSlaves(logoKML, 'slave_1.kml');
    await executeCommand("echo 'refreshkml' > /tmp/query.txt");
  }

  Future<void> _sendKMLToSlaves(String kml, String fileName) async {
    await executeCommand("mkdir -p /var/www/html/kml/ && cat <<'EOF' > /var/www/html/kml/$fileName\n$kml\nEOF");
  }

  Future<void> clearKML() async {
    await executeCommand("rm -f /var/www/html/kml/master.kml");
    await executeCommand("echo 'refreshkml' > /tmp/query.txt");
  }

  Future<void> clearLogo() async {
    String emptyKML = '<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2"><Document></Document></kml>';
    await _sendKMLToSlaves(emptyKML, 'slave_1.kml');
    await executeCommand("echo 'refreshkml' > /tmp/query.txt");
  }

  Future<void> rebootLG() async {
    int rigs = int.parse(_numberOfRigs ?? '3');
    for (var i = 1; i <= rigs; i++) {
      await executeCommand('sshpass -p $_passwordOrKey ssh -t lg@lg$i "sudo reboot"');
    }
  }

  Future<void> shutdownLG() async {
    int rigs = int.parse(_numberOfRigs ?? '3');
    for (var i = 1; i <= rigs; i++) {
      await executeCommand('sshpass -p $_passwordOrKey ssh -t lg@lg$i "sudo poweroff"');
    }
  }
}
