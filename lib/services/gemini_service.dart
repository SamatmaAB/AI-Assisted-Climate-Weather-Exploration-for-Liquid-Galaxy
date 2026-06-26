// import 'package:google_generative_ai/google_generative_ai.dart';
//
// class GeminiService {
//   static const String _apiKey = 'YOUR_API_KEY';
//
//   final GenerativeModel _model = GenerativeModel(
//     model: 'gemini-2.5-flash',
//     apiKey: _apiKey,
//   );
//
//   Future<String> ask(String prompt) async {
//     try {
//       final response = await _model.generateContent(
//         [Content.text(prompt)],
//       );
//
//       return response.text ?? 'No response.';
//     } catch (e) {
//       return 'Error: $e';
//     }
//   }
// }