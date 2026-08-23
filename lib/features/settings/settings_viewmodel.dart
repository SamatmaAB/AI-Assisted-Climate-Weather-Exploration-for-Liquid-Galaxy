import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/core/theme/theme_controller.dart';
import 'package:lg_connection/services/ai/api_key_storage.dart';
import 'package:lg_connection/services/ai/gemini_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// True when the key currently stored matches the one baked in at build
  /// time via --dart-define-from-file=dart_defines.json.
  static const _buildApiKey = String.fromEnvironment('GEMINI_API_KEY');
  bool get isBuildConfigured =>
      _buildApiKey.isNotEmpty &&
      apiKeyController.text.trim() == _buildApiKey.trim();
  bool get isDarkMode => ThemeController.instance.isDarkMode;
  bool get isColorblindMode => ThemeController.instance.isColorblindMode;
  bool isConnecting = false;
  bool isSendingLogo = false;

  ValueListenable<bool> get isConnected => _sshClient.isConnected;

  SettingsViewModel() {
    loadSettings();
  }

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

  Future<void> saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', usernameController.text);
    await prefs.setString('ipAddress', ipController.text);
    await prefs.setString('sshPort', portController.text);
    await prefs.setString('password', passwordController.text);
    await prefs.setString('numberOfRigs', rigsController.text);
  }

  Future<void> saveApiKey() async {
    final key = apiKeyController.text.trim();
    await _apiKeyStorage.saveGeminiApiKey(key);
    notifyListeners();
  }

  Future<void> deleteApiKey() async {
    await _apiKeyStorage.deleteGeminiApiKey();
    apiKeyController.clear();
    notifyListeners();
  }

  Future<void> updateSelectedModel(String model) async {
    selectedModel = model;
    await _apiKeyStorage.saveSelectedModel(model);
    notifyListeners();
  }

  void toggleApiKeyVisibility() {
    isApiKeyObscured = !isApiKeyObscured;
    notifyListeners();
  }

  Future<bool> connect({
    void Function(String message, bool isSuccess)? onFeedback,
  }) async {
    if (ipController.text.isEmpty) return false;

    isConnecting = true;
    notifyListeners();

    await saveSettings();
    final success = await _sshClient.connect();

    isConnecting = false;
    notifyListeners();

    if (success) {
      onFeedback?.call('Successfully connected! Uploading logo to Liquid Galaxy...', true);
      isSendingLogo = true;
      notifyListeners();

      final logoSent = await _sshClient.sendLogo();

      isSendingLogo = false;
      notifyListeners();

      if (logoSent) {
        onFeedback?.call('Logo uploaded & sent successfully!', true);
      } else {
        onFeedback?.call('Connected to Liquid Galaxy, but logo upload failed.', false);
      }
    } else {
      onFeedback?.call('Connection failed. Verify IP and credentials.', false);
    }

    return success;
  }

  Future<bool> sendLogo() async {
    isSendingLogo = true;
    notifyListeners();

    final success = await _sshClient.sendLogo();

    isSendingLogo = false;
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
