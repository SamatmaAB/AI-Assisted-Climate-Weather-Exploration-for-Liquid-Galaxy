import 'package:lg_connection/services/ai/contract/ai_provider.dart';

/// Thin repository that delegates all AI calls to the active [AIProvider].
///
/// This is the **only** entry point the rest of the application should use
/// for AI features.  It allows swapping the underlying provider without
/// touching any ViewModel or UI code.
class AIRepository {
  final AIProvider provider;

  AIRepository(this.provider);

  /// Sends a free-form [prompt] and returns the provider's text response.
  Future<String> ask(String prompt) {
    return provider.ask(prompt);
  }

  /// Generates a structured explanation for the given climate [phenomenon].
  Future<String> getExplanation(String phenomenon) {
    return provider.getExplanation(phenomenon);
  }
}
