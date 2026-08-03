import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lg_connection/core/theme/app_theme.dart';
import 'package:lg_connection/core/theme/theme_controller.dart';
import 'package:lg_connection/features/startup/startup_gate.dart';
import 'package:lg_connection/services/ai/ai_repository.dart';
import 'package:lg_connection/services/ai/provider_factory.dart';
import 'package:lg_connection/shared/services/cache_service.dart';

/// Single [AIRepository] instance created once at the composition root.
/// Every ViewModel and screen accesses AI capabilities through this instance.
late final AIRepository aiRepository;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Initialize unified Cache Service (Hive)
  await CacheService.init();

  // Restore persisted theme preferences before first frame
  await ThemeController.instance.loadFromPrefs();

  // Create the single AI repository at the composition root
  final provider = ProviderFactory.create();
  aiRepository = AIRepository(provider);

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
          // themeMode is implicit because we always pass a fully resolved
          // ThemeData. Setting it to ThemeMode.light ensures MaterialApp does
          // not apply its own dark-override on top of our resolved theme.
          themeMode: ThemeMode.light,
          home: const StartupGate(),
        );
      },
    );
  }
}
