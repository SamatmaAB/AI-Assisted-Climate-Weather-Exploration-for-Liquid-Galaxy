import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A low-level SSH client that handles connection and command execution for Liquid Galaxy.
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

  /// Initializes connection details from SharedPreferences.
  Future<void> initConnectionDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('ipAddress') ?? '';
    _port = prefs.getString('sshPort') ?? '22';
    _username = prefs.getString('username') ?? 'lg';
    _passwordOrKey = prefs.getString('password') ?? 'lg';
  }

  /// Establishes an SSH connection to the Liquid Galaxy master rig.
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
      );

      await _client!.authenticated;
      isConnected.value = true;

      _client!.done.then((_) {
        isConnected.value = false;
        _client = null;
      });

      return true;
    } catch (e) {
      debugPrint('SSH Connection failed: $e');
      isConnected.value = false;
      return false;
    }
  }

  /// Executes a single SSH command on the master rig.
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

  /// Simple command execution that waits for completion.
  Future<bool> runCommand(String command) async {
    final session = await execute(command);
    if (session == null) return false;
    await session.done;
    return true;
  }

  /// Uploads a file to the Liquid Galaxy rig via SFTP.
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
        mode: SftpFileOpenMode.truncate | SftpFileOpenMode.create | SftpFileOpenMode.write,
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

  /// Closes the current SSH connection.
  void disconnect() {
    _client?.close();
    _client = null;
    isConnected.value = false;
  }
}
