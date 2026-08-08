import 'dart:async';
import 'dart:convert';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lg_connection/core/network/ssh_commands.dart';

class LGSSHClient {
  static final LGSSHClient _instance = LGSSHClient._internal();
  factory LGSSHClient() => _instance;
  LGSSHClient._internal();

  SSHClient? _client;
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);

  late String _host;
  late String _port;
  late String _username;
  late String _passwordOrKey;
  late int _numberOfRigs;

  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 3;

  int get numberOfRigs => _numberOfRigs;

  String get password => _passwordOrKey;

  Future<void> initConnectionDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('ipAddress') ?? '';
    _port = prefs.getString('sshPort') ?? '22';
    _username = prefs.getString('username') ?? 'lg';
    _passwordOrKey = prefs.getString('password') ?? 'lg';
    _numberOfRigs =
        int.tryParse(prefs.getString('numberOfRigs') ?? '3') ?? 3;
  }

  Future<bool> connect() async {
    await initConnectionDetails();

    if (_host.isEmpty) {
      isConnected.value = false;
      return false;
    }

    try {
      final socket = await SSHSocket.connect(
        _host,
        int.parse(_port),
        timeout: const Duration(seconds: 5),
      );

      _client = SSHClient(
        socket,
        username: _username,
        onPasswordRequest: () => _passwordOrKey,

        keepAliveInterval: const Duration(seconds: 10),
      );

      await _client!.authenticated;
      isConnected.value = true;
      _reconnectAttempts = 0;

      _startHeartbeat();

      _client!.done.then((_) {
        _handleDisconnection();
      });

      return true;
    } catch (e) {
      debugPrint('SSH Connection failed: $e');
      isConnected.value = false;
      return false;
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_client == null) return;
      try {
        await _client!
            .execute('echo "ping"')
            .timeout(const Duration(seconds: 3));
      } catch (_) {
        _handleDisconnection();
      }
    });
  }

  void _handleDisconnection() {
    if (!isConnected.value) return;
    isConnected.value = false;
    _client?.close();
    _client = null;
    _heartbeatTimer?.cancel();
    debugPrint('SSH: Connection lost.');

    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      debugPrint(
        'SSH: Reconnect attempt $_reconnectAttempts of $_maxReconnectAttempts in 3 s…',
      );
      Future.delayed(const Duration(seconds: 3), () async {
        final ok = await connect();
        if (ok) _reconnectAttempts = 0;
      });
    } else {
      debugPrint('SSH: Max reconnect attempts reached. Giving up.');
      _reconnectAttempts = 0;
    }
  }

  Future<SSHSession?> execute(String command) async {
    try {
      if (_client == null || !isConnected.value) {
        bool connected = await connect();
        if (!connected) return null;
      }
      return await _client!.execute(command);
    } on SSHStateError {
      bool connected = await connect();
      if (!connected) return null;
      return await _client!.execute(command);
    } catch (e) {
      debugPrint('SSH Execution error: $e');
      return null;
    }
  }

  Future<bool> runCommand(String command) async {
    final session = await execute(command);
    if (session == null) return false;
    await session.done;
    return true;
  }

  Future<bool> uploadFile({
    required String content,
    required String targetPath,
  }) async {
    if (_client == null || !isConnected.value) {
      bool connected = await connect();
      if (!connected) return false;
    }

    try {
      final sftp = await _client!.sftp();
      final file = await sftp.open(
        targetPath,
        mode:
            SftpFileOpenMode.truncate |
            SftpFileOpenMode.create |
            SftpFileOpenMode.write,
      );

      final bytes = Uint8List.fromList(utf8.encode(content));
      await file.write(Stream.fromIterable([bytes]), offset: 0);
      await file.close();
      return true;
    } catch (e) {
      debugPrint('SFTP Upload failed: $e');
      return false;
    }
  }

  Future<bool> connectWithCredentials({
    required String host,
    required String port,
    required String username,
    required String password,
    required int numberOfRigs,
  }) async {
    _host = host;
    _port = port;
    _username = username;
    _passwordOrKey = password;
    _numberOfRigs = numberOfRigs;

    if (_host.isEmpty) {
      isConnected.value = false;
      return false;
    }

    try {
      final socket = await SSHSocket.connect(
        _host,
        int.parse(_port),
        timeout: const Duration(seconds: 5),
      );

      _client = SSHClient(
        socket,
        username: _username,
        onPasswordRequest: () => _passwordOrKey,
        keepAliveInterval: const Duration(seconds: 10),
      );

      await _client!.authenticated;
      isConnected.value = true;
      _reconnectAttempts = 0;

      _startHeartbeat();

      _client!.done.then((_) {
        _handleDisconnection();
      });

      return true;
    } catch (e) {
      debugPrint('SSH Connection failed: $e');
      isConnected.value = false;
      return false;
    }
  }

  Future<bool> sendLogo() async {
    final screens = numberOfRigs;
    final leftScreen = SSHCommands.calculateLeftMostScreen(screens);

    final ok = await runCommand(
      SSHCommands.sendLogoToScreen(leftScreen),
    );
    if (ok) await forceRefresh(leftScreen);
    return ok;
  }

  Future<void> forceRefresh(int screen) async {
    final pwd = password;
    try {
      await runCommand(
        SSHCommands.addRefreshInterval(screen, 2, pwd),
      );
      await runCommand(
        SSHCommands.removeRefreshInterval(screen, pwd),
      );
    } catch (e) {
      debugPrint('forceRefresh failed for screen $screen: $e');
    }
  }

  void disconnect() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _client?.close();
    _client = null;
    isConnected.value = false;
  }
}
