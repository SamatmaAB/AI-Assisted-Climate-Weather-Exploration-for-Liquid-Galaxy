import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_connection/services/ai/api_key_storage.dart';
import 'package:lg_connection/services/ai/gemini_models.dart';
import 'package:lg_connection/services/ai/providers/gemini_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiKeyStorage & GeminiProvider BYOK Tests', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('ApiKeyStorage saves, retrieves, checks, and deletes key', () async {
      const storage = ApiKeyStorage();

      expect(await storage.hasGeminiApiKey(), isFalse);
      expect(await storage.getGeminiApiKey(), isNull);

      await storage.saveGeminiApiKey('test_key_12345');

      expect(await storage.hasGeminiApiKey(), isTrue);
      expect(await storage.getGeminiApiKey(), equals('test_key_12345'));

      await storage.deleteGeminiApiKey();

      expect(await storage.hasGeminiApiKey(), isFalse);
      expect(await storage.getGeminiApiKey(), isNull);
    });

    test('ApiKeyStorage defaults to GeminiModels.defaultModel (gemini-3.6-flash)', () async {
      const storage = ApiKeyStorage();

      expect(await storage.getSelectedModel(), equals(GeminiModels.defaultModel));
      expect(GeminiModels.defaultModel, equals('gemini-3.6-flash'));
    });

    test('GeminiProvider returns unconfigured message when key is missing', () async {
      const storage = ApiKeyStorage();
      await storage.deleteGeminiApiKey();

      final provider = GeminiProvider();

      final askResponse = await provider.ask('What is climate change?');
      expect(
        askResponse,
        equals('Gemini API key is not configured. Add your API key from Settings.'),
      );

      final explanationResponse = await provider.getExplanation('El Nino');
      expect(
        explanationResponse,
        equals('Gemini API key is not configured. Add your API key from Settings.'),
      );
    });
  });
}
