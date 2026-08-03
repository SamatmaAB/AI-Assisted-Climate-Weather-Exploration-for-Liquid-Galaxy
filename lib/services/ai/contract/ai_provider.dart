/// Defines the contract for all AI provider implementations.
///
/// Every AI backend (e.g. Gemini, Groq) must implement this interface so
/// the rest of the application can consume AI capabilities without coupling
/// to a specific provider.
abstract class AIProvider {
  /// Sends a free-form [prompt] and returns the model's text response.
  Future<String> ask(String prompt);

  /// Generates a structured explanation for the given climate [phenomenon].
  Future<String> getExplanation(String phenomenon);
}
