import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ViewModel for managing app configuration and Liquid Galaxy connection settings.
class SettingsViewModel extends ChangeNotifier {
  final LGSSHClient _sshClient = LGSSHClient();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController ipController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rigsController = TextEditingController();

  bool get isDarkMode => ThemeController.instance.isDarkMode;
  bool get isColorblindMode => ThemeController.instance.isColorblindMode;
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
    // isDarkMode and isColorblindMode are owned by ThemeController;
    // they are already loaded at startup via ThemeController.loadFromPrefs().
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
    // Theme preferences are persisted by ThemeController directly.
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
    ThemeController.instance.setDarkMode(value);
    notifyListeners(); // update AppearanceCard switch immediately
  }

  void toggleColorblindMode(bool value) {
    ThemeController.instance.setColorblindMode(value);
    notifyListeners(); // update AppearanceCard switch immediately
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
