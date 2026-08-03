import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lg_connection/services/ai/gemini_models.dart';

/// Handles secure local storage for API keys and AI configuration using [FlutterSecureStorage].
class ApiKeyStorage {
  final FlutterSecureStorage _storage;

  static const String _geminiApiKeyKey = 'gemini_api_key';
  static const String _geminiSelectedModelKey = 'gemini_selected_model';

  const ApiKeyStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Saves the Gemini API key securely.
  Future<void> saveGeminiApiKey(String key) async {
    await _storage.write(key: _geminiApiKeyKey, value: key.trim());
  }

  /// Retrieves the stored Gemini API key, or null if not found.
  Future<String?> getGeminiApiKey() async {
    final key = await _storage.read(key: _geminiApiKeyKey);
    if (key == null || key.trim().isEmpty) {
      return null;
    }
    return key.trim();
  }

  /// Securely deletes the Gemini API key.
  Future<void> deleteGeminiApiKey() async {
    await _storage.delete(key: _geminiApiKeyKey);
  }

  /// Returns true if a valid Gemini API key is currently stored.
  Future<bool> hasGeminiApiKey() async {
    final key = await getGeminiApiKey();
    return key != null && key.isNotEmpty;
  }

  /// Saves the selected Gemini model securely.
  Future<void> saveSelectedModel(String model) async {
    await _storage.write(key: _geminiSelectedModelKey, value: model.trim());
  }

  /// Retrieves the selected Gemini model, defaulting to [GeminiModels.defaultModel].
  Future<String> getSelectedModel() async {
    final model = await _storage.read(key: _geminiSelectedModelKey);
    if (model == null || model.trim().isEmpty) {
      return GeminiModels.defaultModel;
    }
    return model.trim();
  }
}
