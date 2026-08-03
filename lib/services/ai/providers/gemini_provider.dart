import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lg_connection/services/ai/api_key_storage.dart';
import 'package:lg_connection/services/ai/contract/ai_provider.dart';
import 'package:lg_connection/services/ai/prompts/ai_prompts.dart';

/// Google Gemini implementation of [AIProvider].
///
/// Reads the API key and selected model dynamically from [ApiKeyStorage]
/// and uses system instructions from [AIPrompts].
class GeminiProvider implements AIProvider {
  static final GeminiProvider _instance = GeminiProvider._internal();
  factory GeminiProvider() => _instance;
  GeminiProvider._internal();

  final ApiKeyStorage _apiKeyStorage = const ApiKeyStorage();

  static const String missingKeyMessage =
      'Gemini API key is not configured. Add your API key from Settings.';

  /// Generates a structured explanation for the given climate [phenomenon].
  @override
  Future<String> getExplanation(String phenomenon) async {
    final apiKey = await _apiKeyStorage.getGeminiApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return missingKeyMessage;
    }

    try {
      final selectedModel = await _apiKeyStorage.getSelectedModel();
      final model = GenerativeModel(
        model: selectedModel,
        apiKey: apiKey,
        systemInstruction: Content.system(AIPrompts.explanation),
      );

      final response = await model.generateContent([
        Content.text('Phenomenon: $phenomenon'),
      ]);
      return response.text ?? 'No explanation available at this time.';
    } catch (e) {
      return 'Error generating explanation: $e';
    }
  }

  /// Generic method for custom prompts (used by the chatbot).
  @override
  Future<String> ask(String prompt) async {
    final apiKey = await _apiKeyStorage.getGeminiApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return missingKeyMessage;
    }

    try {
      final selectedModel = await _apiKeyStorage.getSelectedModel();
      final model = GenerativeModel(
        model: selectedModel,
        apiKey: apiKey,
        systemInstruction: Content.system(AIPrompts.chatbot),
      );

      final response = await model.generateContent([
        Content.text(prompt),
      ]);
      return response.text ?? 'No response';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
