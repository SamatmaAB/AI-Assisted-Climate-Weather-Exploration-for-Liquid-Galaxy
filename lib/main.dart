import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lg_connection/core/theme/app_theme.dart';
import 'package:lg_connection/core/theme/theme_controller.dart';
import 'package:lg_connection/features/startup/startup_gate.dart';
import 'package:lg_connection/shared/services/cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Initialize unified Cache Service (Hive)
  await CacheService.init();

  // Restore persisted theme preferences before first frame
  await ThemeController.instance.loadFromPrefs();

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
