import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ViewModel for managing app configuration and Liquid Galaxy connection settings.
class SettingsViewModel extends ChangeNotifier {
  final LGSSHClient _sshClient = LGSSHClient();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController ipController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rigsController = TextEditingController();

  bool isDarkMode = true;
  bool isColorblindMode = false;
  bool isConnecting = false;

  ValueListenable<bool> get isConnected => _sshClient.isConnected;

  SettingsViewModel() {
    loadSettings();
  }

  /// Loads settings from SharedPreferences into controllers and state.
  Future<void> loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    usernameController.text = prefs.getString('username') ?? 'lg';
    ipController.text = prefs.getString('ipAddress') ?? '';
    portController.text = prefs.getString('sshPort') ?? '22';
    passwordController.text = prefs.getString('password') ?? 'lg';
    rigsController.text = prefs.getString('numberOfRigs') ?? '3';
    isDarkMode = prefs.getBool('isDarkMode') ?? true;
    isColorblindMode = prefs.getBool('isColorblindMode') ?? false;
    notifyListeners();
  }

  /// Saves current settings to SharedPreferences.
  Future<void> saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', usernameController.text);
    await prefs.setString('ipAddress', ipController.text);
    await prefs.setString('sshPort', portController.text);
    await prefs.setString('password', passwordController.text);
    await prefs.setString('numberOfRigs', rigsController.text);
    await prefs.setBool('isDarkMode', isDarkMode);
    await prefs.setBool('isColorblindMode', isColorblindMode);
  }

  /// Triggers a connection attempt to the Liquid Galaxy rig.
  Future<bool> connect() async {
    if (ipController.text.isEmpty) return false;

    isConnecting = true;
    notifyListeners();

    await saveSettings();
    final success = await _sshClient.connect();

    isConnecting = false;
    notifyListeners();
    return success;
  }

  void toggleDarkMode(bool value) {
    isDarkMode = value;
    saveSettings();
    notifyListeners();
  }

  void toggleColorblindMode(bool value) {
    isColorblindMode = value;
    saveSettings();
    notifyListeners();
  }

  @override
  void dispose() {
    usernameController.dispose();
    ipController.dispose();
    portController.dispose();
    passwordController.dispose();
    rigsController.dispose();
    super.dispose();
  }
}
