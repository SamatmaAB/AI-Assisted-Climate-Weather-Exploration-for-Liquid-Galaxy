import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lg_connection/core/theme/app_theme.dart';
import 'package:lg_connection/core/theme/theme_controller.dart';
import 'package:lg_connection/features/startup/startup_gate.dart';
import 'package:lg_connection/services/ai/ai_repository.dart';
import 'package:lg_connection/services/ai/provider_factory.dart';
import 'package:lg_connection/services/tts/tts_service.dart';
import 'package:lg_connection/shared/services/cache_service.dart';

late final AIRepository aiRepository;
late final TtsService ttsService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await CacheService.init();

  await ThemeController.instance.loadFromPrefs();

  final provider = ProviderFactory.create();
  aiRepository = AIRepository(provider);

  ttsService = TtsService.instance;
  await ttsService.initialize();

  runApp(const EarthSystemsExplorerApp());
}

class EarthSystemsExplorerApp extends StatelessWidget {
  const EarthSystemsExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        final controller = ThemeController.instance;
        return MaterialApp(
          title: 'Earth Systems Explorer',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.resolve(controller),

          themeMode: ThemeMode.light,
          home: const StartupGate(),
        );
      },
    );
  }
}
