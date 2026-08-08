import 'package:flutter/material.dart';
import 'package:lg_connection/features/onboarding/initial_setup_viewmodel.dart';
import 'package:lg_connection/features/onboarding/widgets/connected_success_reveal.dart';
import 'package:lg_connection/features/onboarding/widgets/mascot_animation.dart';

/// First-run 3-stage onboarding screen for Liquid Galaxy setup.
class InitialSetupScreen extends StatefulWidget {
  final VoidCallback onSetupComplete;

  const InitialSetupScreen({
    super.key,
    required this.onSetupComplete,
  });

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  late final InitialSetupViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = InitialSetupViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleCompleteSetup() async {
    await _viewModel.completeSetup();
    widget.onSetupComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return Column(
              children: [
                const SizedBox(height: 16),
                _buildProgressIndicator(context),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildStageContent(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final stageIndex = _viewModel.stage.index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepDot(context, stageIndex >= 0),
          _buildStepLine(context, stageIndex >= 1),
          _buildStepDot(context, stageIndex >= 1),
          _buildStepLine(context, stageIndex >= 2),
          _buildStepDot(context, stageIndex >= 2),
        ],
      ),
    );
  }

  Widget _buildStepDot(BuildContext context, bool isActive) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildStepLine(BuildContext context, bool isActive) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isActive ? colorScheme.primary : colorScheme.outlineVariant,
    );
  }

  Widget _buildStageContent(BuildContext context) {
    switch (_viewModel.stage) {
      case OnboardingStage.welcome:
        return _buildWelcomeStage(context);
      case OnboardingStage.connection:
        return _buildConnectionStage(context);
      case OnboardingStage.ready:
        return _buildReadyStage(context);
    }
  }

  Widget _buildWelcomeStage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      key: const ValueKey('stage_welcome'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            const MascotAnimation(
              assetPath: 'assets/spriteanimations/wave.webp',
              width: 240,
              height: 240,
            ),
            const SizedBox(height: 32),
            Text(
              'EARTH SYSTEMS EXPLORER',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Explore Earth\'s climate systems\nthrough immersive visualization',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Discover ocean currents, atmospheric circulation, climate oscillations, and their influence on weather using Liquid Galaxy.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.65),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: () => _viewModel.goToConnection(),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Get Started'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStage(BuildContext context) {
    final isConnecting = _viewModel.connectionState == ConnectionOpState.connecting;
    final isIdle = _viewModel.connectionState == ConnectionOpState.idle;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      key: const ValueKey('stage_connection'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: isConnecting ? null : () => _viewModel.goBack(),
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Connect to Liquid Galaxy',
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Configure the Liquid Galaxy master that Earth Systems Explorer will control.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            // Show waving mascot while the user is filling in the form (idle)
            if (isIdle) ...[
              const Center(
                child: MascotAnimation(
                  assetPath: 'assets/spriteanimations/wave.webp',
                  width: 160,
                  height: 160,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (isConnecting) ...[
              const Center(
                child: MascotAnimation(
                  assetPath: 'assets/spriteanimations/thinking.webp',
                  width: 160,
                  height: 160,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_viewModel.connectionState == ConnectionOpState.failure) ...[
              const Center(
                child: MascotAnimation(
                  assetPath: 'assets/spriteanimations/sad.webp',
                  width: 160,
                  height: 160,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: colorScheme.onErrorContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _viewModel.errorMessage ?? 'Could not connect to Liquid Galaxy.',
                          style: textTheme.bodySmall?.copyWith(color: colorScheme.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: _viewModel.ipController,
                      enabled: !isConnecting,
                      decoration: InputDecoration(
                        labelText: 'Master IP / Host',
                        prefixIcon: const Icon(Icons.dns_outlined),
                        errorText: _viewModel.ipError,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _viewModel.usernameController,
                      enabled: !isConnecting,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: const Icon(Icons.person_outlined),
                        errorText: _viewModel.usernameError,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _viewModel.passwordController,
                      enabled: !isConnecting,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _viewModel.portController,
                            enabled: !isConnecting,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Port',
                              prefixIcon: const Icon(Icons.tag_outlined),
                              errorText: _viewModel.portError,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _viewModel.rigsController,
                            enabled: !isConnecting,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Screens',
                              prefixIcon: const Icon(Icons.monitor_outlined),
                              errorText: _viewModel.rigsError,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _viewModel.apiKeyController,
                      enabled: !isConnecting,
                      obscureText: _viewModel.isApiKeyObscured,
                      decoration: InputDecoration(
                        labelText: 'Google Gemini API Key',
                        prefixIcon: const Icon(Icons.key_outlined),
                        helperText: 'Optional. Add your Google Gemini API key now or later from Settings.',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _viewModel.isApiKeyObscured
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => _viewModel.toggleApiKeyVisibility(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isConnecting ? null : () => _viewModel.connect(),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
              child: isConnecting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Connect to Liquid Galaxy'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: isConnecting ? null : _handleCompleteSetup,
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Explore App'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyStage(BuildContext context) {
    final String masterIp = _viewModel.ipController.text.trim();
    final String screens = _viewModel.rigsController.text.trim();
    final isSendingLogo = _viewModel.logoState == LogoOpState.sending;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      key: const ValueKey('stage_ready'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            const ConnectedSuccessReveal(),
            const SizedBox(height: 20),
            Text(
              'Liquid Galaxy Connected',
              style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Earth Systems Explorer is ready to explore.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSummaryRow(context, 'Master IP', masterIp),
                    const Divider(height: 24),
                    _buildSummaryRow(context, 'Screens', screens),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _handleCompleteSetup,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Start Exploring'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: isSendingLogo ? null : () => _viewModel.sendLogo(),
              icon: isSendingLogo
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.image_outlined),
              label: Text(isSendingLogo ? 'Sending Logo...' : 'Send Logo to Slave Rig'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6))),
        Text(value, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
