import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/theme/theme_controller.dart';
import 'package:lg_connection/services/ai/api_key_storage.dart';
import 'package:lg_connection/services/ai/gemini_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ViewModel for managing app configuration, Gemini model selection, and Liquid Galaxy settings.
class SettingsViewModel extends ChangeNotifier {
  final LGSSHClient _sshClient = LGSSHClient();
  final ApiKeyStorage _apiKeyStorage = const ApiKeyStorage();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController ipController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rigsController = TextEditingController();
  final TextEditingController apiKeyController = TextEditingController();

  bool isApiKeyObscured = true;
  String selectedModel = GeminiModels.defaultModel;

  bool get hasApiKey => apiKeyController.text.trim().isNotEmpty;
  bool get isDarkMode => ThemeController.instance.isDarkMode;
  bool get isColorblindMode => ThemeController.instance.isColorblindMode;
  bool isConnecting = false;

  ValueListenable<bool> get isConnected => _sshClient.isConnected;

  SettingsViewModel() {
    loadSettings();
  }

  /// Loads settings from SharedPreferences and ApiKeyStorage into controllers and state.
  Future<void> loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    usernameController.text = prefs.getString('username') ?? 'lg';
    ipController.text = prefs.getString('ipAddress') ?? '';
    portController.text = prefs.getString('sshPort') ?? '22';
    passwordController.text = prefs.getString('password') ?? 'lg';
    rigsController.text = prefs.getString('numberOfRigs') ?? '3';

    final storedApiKey = await _apiKeyStorage.getGeminiApiKey();
    apiKeyController.text = storedApiKey ?? '';

    selectedModel = await _apiKeyStorage.getSelectedModel();

    notifyListeners();
  }

  /// Saves current connection settings to SharedPreferences.
  Future<void> saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', usernameController.text);
    await prefs.setString('ipAddress', ipController.text);
    await prefs.setString('sshPort', portController.text);
    await prefs.setString('password', passwordController.text);
    await prefs.setString('numberOfRigs', rigsController.text);
  }

  /// Saves Gemini API Key securely.
  Future<void> saveApiKey() async {
    final key = apiKeyController.text.trim();
    await _apiKeyStorage.saveGeminiApiKey(key);
    notifyListeners();
  }

  /// Removes Gemini API Key securely.
  Future<void> deleteApiKey() async {
    await _apiKeyStorage.deleteGeminiApiKey();
    apiKeyController.clear();
    notifyListeners();
  }

  /// Updates selected Gemini model and persists immediately to secure storage.
  Future<void> updateSelectedModel(String model) async {
    selectedModel = model;
    await _apiKeyStorage.saveSelectedModel(model);
    notifyListeners();
  }

  /// Toggles visibility of the Gemini API Key text field.
  void toggleApiKeyVisibility() {
    isApiKeyObscured = !isApiKeyObscured;
    notifyListeners();
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
    notifyListeners();
  }

  void toggleColorblindMode(bool value) {
    ThemeController.instance.setColorblindMode(value);
    notifyListeners();
  }

  @override
  void dispose() {
    usernameController.dispose();
    ipController.dispose();
    portController.dispose();
    passwordController.dispose();
    rigsController.dispose();
    apiKeyController.dispose();
    super.dispose();
  }
}
