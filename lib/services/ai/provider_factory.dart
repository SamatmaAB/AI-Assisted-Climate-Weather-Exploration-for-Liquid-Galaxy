import 'package:lg_connection/services/ai/contract/ai_provider.dart';
import 'package:lg_connection/services/ai/providers/gemini_provider.dart';

class ProviderFactory {
  static AIProvider create() {
    return GeminiProvider();
  }
}
