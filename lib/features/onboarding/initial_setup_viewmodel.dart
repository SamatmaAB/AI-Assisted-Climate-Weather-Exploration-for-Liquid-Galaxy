import 'package:flutter/material.dart';
import 'package:lg_connection/core/network/ssh_client.dart';
import 'package:lg_connection/features/startup/startup_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The 3 stages of initial first-run onboarding.
enum OnboardingStage {
  welcome,    // Stage 1: Get Started
  connection, // Stage 2: Connect to Liquid Galaxy
  ready,      // Stage 3: Start Exploring & optional Send Logo
}

/// Operation state during SSH connection verification.
enum ConnectionOpState {
  idle,
  connecting,
  connected,
  failure,
}

/// Operation state for optional Send Logo action.
enum LogoOpState {
  idle,
  sending,
  success,
  failure,
}

/// ViewModel managing the three-stage first-run onboarding flow.
class InitialSetupViewModel extends ChangeNotifier {
  final LGSSHClient _sshClient = LGSSHClient();

  final TextEditingController ipController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController rigsController = TextEditingController();

  OnboardingStage _stage = OnboardingStage.welcome;
  OnboardingStage get stage => _stage;

  ConnectionOpState _connectionState = ConnectionOpState.idle;
  ConnectionOpState get connectionState => _connectionState;

  LogoOpState _logoState = LogoOpState.idle;
  LogoOpState get logoState => _logoState;

  String? ipError;
  String? usernameError;
  String? portError;
  String? rigsError;
  String? errorMessage;
  String? logoFeedback;

  bool _isDisposed = false;

  InitialSetupViewModel() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_isDisposed) return;
    if (ipController.text.isEmpty) {
      ipController.text = prefs.getString('ipAddress') ?? '';
    }
    if (usernameController.text.isEmpty) {
      usernameController.text = prefs.getString('username') ?? 'lg';
    }
    if (passwordController.text.isEmpty) {
      passwordController.text = prefs.getString('password') ?? 'lg';
    }
    if (portController.text.isEmpty) {
      portController.text = prefs.getString('sshPort') ?? '22';
    }
    if (rigsController.text.isEmpty) {
      rigsController.text = prefs.getString('numberOfRigs') ?? '3';
    }
    if (!_isDisposed) notifyListeners();
  }

  /// Advances from Stage 1 (Welcome) to Stage 2 (Connection).
  void goToConnection() {
    _stage = OnboardingStage.connection;
    if (!_isDisposed) notifyListeners();
  }

  /// Handles linear back navigation during onboarding.
  void goBack() {
    if (_stage == OnboardingStage.ready) {
      _stage = OnboardingStage.connection;
    } else if (_stage == OnboardingStage.connection) {
      _stage = OnboardingStage.welcome;
    }
    if (!_isDisposed) notifyListeners();
  }

  /// Validates required configuration inputs.
  bool validate() {
    bool isValid = true;
    ipError = null;
    usernameError = null;
    portError = null;
    rigsError = null;
    errorMessage = null;

    final ip = ipController.text.trim();
    if (ip.isEmpty) {
      ipError = 'Master IP / Host is required';
      isValid = false;
    }

    final username = usernameController.text.trim();
    if (username.isEmpty) {
      usernameError = 'Username is required';
      isValid = false;
    }

    final port = int.tryParse(portController.text.trim());
    if (port == null || port <= 0 || port > 65535) {
      portError = 'Valid port required (1 - 65535)';
      isValid = false;
    }

    final rigs = int.tryParse(rigsController.text.trim());
    if (rigs == null || rigs <= 0) {
      rigsError = 'Valid screen count required (> 0)';
      isValid = false;
    }

    if (!_isDisposed) notifyListeners();
    return isValid;
  }

  /// Attempts SSH connection to Liquid Galaxy (Stage 2 primary action).
  Future<bool> connect() async {
    if (!validate()) return false;

    _connectionState = ConnectionOpState.connecting;
    errorMessage = null;
    if (!_isDisposed) notifyListeners();

    final String host = ipController.text.trim();
    final String port = portController.text.trim();
    final String username = usernameController.text.trim();
    final String password = passwordController.text;
    final int rigs = int.parse(rigsController.text.trim());

    final bool connected = await _sshClient.connectWithCredentials(
      host: host,
      port: port,
      username: username,
      password: password,
      numberOfRigs: rigs,
    );

    if (_isDisposed) return false;

    if (connected) {
      _connectionState = ConnectionOpState.connected;
      _stage = OnboardingStage.ready;
      notifyListeners();
      return true;
    } else {
      _connectionState = ConnectionOpState.failure;
      errorMessage = 'Could not connect to Liquid Galaxy. Check the connection details and make sure the master is running and reachable.';
      notifyListeners();
      return false;
    }
  }

  /// Optional action to send logo once connected (Stage 3 action).
  Future<bool> sendLogo() async {
    _logoState = LogoOpState.sending;
    logoFeedback = null;
    if (!_isDisposed) notifyListeners();

    final bool logoSent = await _sshClient.sendLogo();

    if (_isDisposed) return false;

    if (logoSent) {
      _logoState = LogoOpState.success;
      logoFeedback = '✓ Logo sent successfully';
    } else {
      _logoState = LogoOpState.failure;
      logoFeedback = 'Unable to send logo.';
    }

    if (!_isDisposed) notifyListeners();
    return logoSent;
  }

  /// Saves verified connection details and marks initial setup as complete.
  Future<void> completeSetup() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ipAddress', ipController.text.trim());
    await prefs.setString('username', usernameController.text.trim());
    await prefs.setString('password', passwordController.text);
    await prefs.setString('sshPort', portController.text.trim());
    await prefs.setString('numberOfRigs', rigsController.text.trim());
    await prefs.setInt(StartupGate.setupVersionKey, StartupGate.currentSetupVersion);
  }

  void resetConnectionState() {
    _connectionState = ConnectionOpState.idle;
    errorMessage = null;
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    ipController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    portController.dispose();
    rigsController.dispose();
    super.dispose();
  }
}
