import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_connection/features/onboarding/initial_setup_viewmodel.dart';
import 'package:lg_connection/features/startup/startup_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Three-Stage Onboarding & Startup Unit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('StartupGate constants are correctly defined', () {
      expect(StartupGate.currentSetupVersion, equals(1));
      expect(StartupGate.setupVersionKey, equals('setupVersion'));
    });

    test('InitialSetupViewModel begins at Stage 1 (welcome) and advances to Stage 2 (connection)', () async {
      final viewModel = InitialSetupViewModel();
      await viewModel.loadSettings();

      expect(viewModel.stage, equals(OnboardingStage.welcome));

      viewModel.goToConnection();
      expect(viewModel.stage, equals(OnboardingStage.connection));

      viewModel.goBack();
      expect(viewModel.stage, equals(OnboardingStage.welcome));

      viewModel.dispose();
    });

    test('InitialSetupViewModel Stage 2 validation enforces field bounds', () async {
      final viewModel = InitialSetupViewModel();
      await viewModel.loadSettings();

      viewModel.goToConnection();

      viewModel.ipController.text = '';
      viewModel.usernameController.text = 'lg';
      viewModel.portController.text = '22';
      viewModel.rigsController.text = '3';
      expect(viewModel.validate(), isFalse);
      expect(viewModel.ipError, isNotNull);

      viewModel.ipController.text = '192.168.1.10';
      viewModel.portController.text = '70000';
      expect(viewModel.validate(), isFalse);
      expect(viewModel.portError, isNotNull);

      viewModel.portController.text = '22';
      viewModel.rigsController.text = '0';
      expect(viewModel.validate(), isFalse);
      expect(viewModel.rigsError, isNotNull);

      viewModel.rigsController.text = '3';
      expect(viewModel.validate(), isTrue);
      expect(viewModel.ipError, isNull);
      expect(viewModel.portError, isNull);
      expect(viewModel.rigsError, isNull);

      viewModel.dispose();
    });

    test('completeSetup persists verified configuration and setupVersion = 1', () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      final viewModel = InitialSetupViewModel();
      await viewModel.loadSettings();

      viewModel.ipController.text = '10.0.0.5';
      viewModel.usernameController.text = 'lg_user';
      viewModel.passwordController.text = 'secret';
      viewModel.portController.text = '2222';
      viewModel.rigsController.text = '5';

      await viewModel.completeSetup();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('ipAddress'), equals('10.0.0.5'));
      expect(prefs.getString('username'), equals('lg_user'));
      expect(prefs.getString('password'), equals('secret'));
      expect(prefs.getString('sshPort'), equals('2222'));
      expect(prefs.getString('numberOfRigs'), equals('5'));
      expect(prefs.getInt(StartupGate.setupVersionKey), equals(1));

      viewModel.dispose();
    });
  });
}
