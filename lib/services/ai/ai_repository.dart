import 'package:lg_connection/services/ai/contract/ai_provider.dart';

class AIRepository {
  final AIProvider provider;

  AIRepository(this.provider);

  Future<String> ask(String prompt) {
    return provider.ask(prompt);
  }

  Future<String> getExplanation(String phenomenon) {
    return provider.getExplanation(phenomenon);
  }
}
