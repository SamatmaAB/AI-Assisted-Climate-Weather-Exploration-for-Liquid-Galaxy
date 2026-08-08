import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lg_connection/services/ai/gemini_models.dart';

class ApiKeyStorage {
  final FlutterSecureStorage _storage;

  static const String _geminiApiKeyKey = 'gemini_api_key';
  static const String _geminiSelectedModelKey = 'gemini_selected_model';

  const ApiKeyStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveGeminiApiKey(String key) async {
    await _storage.write(key: _geminiApiKeyKey, value: key.trim());
  }

  Future<String?> getGeminiApiKey() async {
    final key = await _storage.read(key: _geminiApiKeyKey);
    if (key == null || key.trim().isEmpty) {
      return null;
    }
    return key.trim();
  }

  Future<void> deleteGeminiApiKey() async {
    await _storage.delete(key: _geminiApiKeyKey);
  }

  Future<bool> hasGeminiApiKey() async {
    final key = await getGeminiApiKey();
    return key != null && key.isNotEmpty;
  }

  Future<void> saveSelectedModel(String model) async {
    await _storage.write(key: _geminiSelectedModelKey, value: model.trim());
  }

  Future<String> getSelectedModel() async {
    final model = await _storage.read(key: _geminiSelectedModelKey);
    if (model == null || model.trim().isEmpty) {
      return GeminiModels.defaultModel;
    }
    return model.trim();
  }
}
