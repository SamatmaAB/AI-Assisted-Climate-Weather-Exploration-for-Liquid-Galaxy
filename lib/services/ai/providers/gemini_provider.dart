import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lg_connection/models/climate_phenomenon_model.dart';
import 'package:lg_connection/services/ai/api_key_storage.dart';
import 'package:lg_connection/services/ai/contract/ai_provider.dart';
import 'package:lg_connection/services/ai/prompts/ai_prompts.dart';

class GeminiProvider implements AIProvider {
  static final GeminiProvider _instance = GeminiProvider._internal();
  factory GeminiProvider() => _instance;
  GeminiProvider._internal();

  final ApiKeyStorage _apiKeyStorage = const ApiKeyStorage();

  static const String missingKeyMessage =
      'Gemini API key is not configured. Add your API key from Settings.';

  @override
  Future<String> getExplanation(String phenomenon) async {
    final apiKey = await _apiKeyStorage.getGeminiApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return ClimatePhenomena.getFallbackSummary(phenomenon);
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
      ]).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          return GenerateContentResponse([
            Candidate(
              Content.model([
                TextPart(ClimatePhenomena.getFallbackSummary(phenomenon)),
              ]),
              null,
              null,
              null,
              null,
            ),
          ], null);
        },
      );
      final text = response.text?.trim();
      if (text != null && text.isNotEmpty) return text;
      return ClimatePhenomena.getFallbackSummary(phenomenon);
    } catch (e) {
      return ClimatePhenomena.getFallbackSummary(phenomenon);
    }
  }

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
