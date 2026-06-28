class QAService {
  final GeminiService _gemini = GeminiService();

  Future<List<String>> generateQuestions() async {
    final response = await _gemini.ask('''
Generate exactly 10 unique educational questions.

Categories:
- Ocean currents
- Monsoons
- ENSO
- Jet streams
- Climate systems

Return ONLY a JSON array of strings.
''');

    // parse JSON and return List<String>
  }
}