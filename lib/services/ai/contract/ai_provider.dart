
abstract class AIProvider {

  Future<String> ask(String prompt);

  Future<String> getExplanation(String phenomenon);
}
