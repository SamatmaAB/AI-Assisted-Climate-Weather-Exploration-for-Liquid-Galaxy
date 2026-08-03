import 'package:lg_connection/services/ai/contract/ai_provider.dart';
import 'package:lg_connection/services/ai/providers/gemini_provider.dart';

/// Factory that creates the active [AIProvider].
///
/// Currently returns only [GeminiProvider].  Future BYOK / Groq
/// support will extend this factory — no other code needs to change.
class ProviderFactory {
  static AIProvider create() {
    return GeminiProvider();
  }
}
