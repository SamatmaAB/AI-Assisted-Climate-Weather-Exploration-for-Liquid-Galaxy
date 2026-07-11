import 'package:google_generative_ai/google_generative_ai.dart';

/// Service to interact with Google Gemini AI for generating climate explanations.
///
/// The API key is injected at **build time** via `--dart-define=GEMINI_API_KEY=your_key`.
/// It is never stored in source code, SharedPreferences, or any runtime storage.
///
/// Build command:
///   flutter build apk --dart-define=GEMINI_API_KEY=your_key_here
///   flutter run --dart-define=GEMINI_API_KEY=your_key_here
class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // Key is baked in at build time — not visible in source, not stored on device.
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  // Model is created once; the key never changes at runtime.
  late final GenerativeModel _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: _apiKey,
  );

  /// Returns true if a key was provided at build time.
  static bool get isConfigured => _apiKey.isNotEmpty;

  /// Sends a prompt to Gemini and returns a climate explanation.
  Future<String> getExplanation(String phenomenon) async {
    if (!isConfigured) {
      return 'AI explanation unavailable: the app was built without a Gemini API key.';
    }

    try {
      final prompt = '''
You are an Earth Systems Observatory assistant.

Explain the following phenomenon:

$phenomenon

Include:
• What it is
• How it works
• Why it is important
• Its impact on weather and climate.

Keep the explanation under 200 words and easy to understand.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No explanation available at this time.';
    } catch (e) {
      return 'Error generating explanation: $e';
    }
  }

  /// Generic method for custom prompts (used by the chatbot).
  Future<String> ask(String prompt) async {
    if (!isConfigured) {
      return 'AI unavailable: the app was built without a Gemini API key.';
    }

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No response';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
