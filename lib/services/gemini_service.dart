import 'package:google_generative_ai/google_generative_ai.dart';
import 'api_key_service.dart';

class GeminiService {
  GenerativeModel? _model;

  Future<void> init() async {
    final apiKey = await ApiKeyService.getApiKey();

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
  }

  Future<String> ask(String prompt) async {
    try {
      _model ??= GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: await ApiKeyService.getApiKey(),
      );

      final response = await _model!.generateContent([
        Content.text(prompt),
      ]);

      return response.text ?? 'No response';
    } catch (e) {
      return 'Error: $e';
    }
  }
}