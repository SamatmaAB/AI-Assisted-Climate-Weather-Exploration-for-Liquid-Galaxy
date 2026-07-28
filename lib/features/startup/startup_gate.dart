import 'package:flutter/material.dart';
import 'package:lg_connection/core/theme/app_colors.dart';
import 'package:lg_connection/features/main/main_container.dart';
import 'package:lg_connection/features/onboarding/initial_setup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Startup Gate determines whether the application should enter initial setup
/// or launch directly into the existing application.
class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  /// Centrally defined current setup version.
  static const int currentSetupVersion = 1;
  static const String setupVersionKey = 'setupVersion';

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  bool _isLoading = true;
  bool _isSetupCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkSetupState();
  }

  Future<void> _checkSetupState() async {
    final prefs = await SharedPreferences.getInstance();
    final int? setupVersion = prefs.getInt(StartupGate.setupVersionKey);

    if (setupVersion != null) {
      // Setup state explicitly recorded
      _isSetupCompleted = setupVersion >= StartupGate.currentSetupVersion;
    } else {
      // Legacy user check: if setupVersion missing but valid legacy config exists
      final String? existingIp = prefs.getString('ipAddress');
      if (existingIp != null && existingIp.trim().isNotEmpty) {
        // Migrate legacy user as completed setup
        await prefs.setInt(StartupGate.setupVersionKey, StartupGate.currentSetupVersion);
        _isSetupCompleted = true;
      } else {
        _isSetupCompleted = false;
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.slate950,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.electricBlue,
          ),
        ),
      );
    }

    if (_isSetupCompleted) {
      return const MainContainer();
    }

    return InitialSetupScreen(
      onSetupComplete: () {
        setState(() {
          _isSetupCompleted = true;
        });
      },
    );
  }
}
