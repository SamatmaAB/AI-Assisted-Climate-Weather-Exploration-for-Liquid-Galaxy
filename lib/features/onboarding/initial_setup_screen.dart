import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/core/common_widgets/glass_card.dart';
import 'package:lg_connection/core/theme/app_colors.dart';
import 'package:lg_connection/features/onboarding/initial_setup_viewmodel.dart';
import 'package:lg_connection/features/onboarding/widgets/animated_earth_hero.dart';
import 'package:lg_connection/features/onboarding/widgets/connected_success_reveal.dart';

/// First-run 3-stage onboarding screen for Liquid Galaxy setup with lightweight motion effects.
class InitialSetupScreen extends StatefulWidget {
  final VoidCallback onSetupComplete;

  const InitialSetupScreen({
    super.key,
    required this.onSetupComplete,
  });

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> with TickerProviderStateMixin {
  late final InitialSetupViewModel _viewModel;

  // Stage 1 Entrance Animation Controller & Animations
  late final AnimationController _stage1EntranceController;
  late final Animation<double> _s1HeroFade;
  late final Animation<Offset> _s1TitleSlide;
  late final Animation<Offset> _s1DescSlide;
  late final Animation<Offset> _s1ButtonSlide;

  // Stage 3 Entrance Animation Controller & Animations
  late final AnimationController _stage3EntranceController;
  late final Animation<Offset> _s3CardSlide;
  late final Animation<Offset> _s3ButtonSlide;

  // Exit Animation Controller
  late final AnimationController _exitController;
  late final Animation<double> _exitScaleAnimation;
  late final Animation<double> _exitFadeAnimation;

  @override
  void initState() {
    super.initState();
    _viewModel = InitialSetupViewModel();

    // Stage 1 Staged Entrance Sequence (750ms)
    _stage1EntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _s1HeroFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _stage1EntranceController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

    _s1TitleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _stage1EntranceController, curve: const Interval(0.25, 0.65, curve: Curves.easeOutCubic)),
    );

    _s1DescSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _stage1EntranceController, curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic)),
    );

    _s1ButtonSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(parent: _stage1EntranceController, curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic)),
    );

    // Stage 3 Staged Entrance Sequence (650ms)
    _stage3EntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _s3CardSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _stage3EntranceController, curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic)),
    );

    _s3ButtonSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _stage3EntranceController, curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic)),
    );

    // Exit Animation Sequence (250ms)
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _exitScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInQuad),
    );

    _exitFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInQuad),
    );

    _stage1EntranceController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations) {
      _stage1EntranceController.value = 1.0;
      _stage3EntranceController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _stage1EntranceController.dispose();
    _stage3EntranceController.dispose();
    _exitController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _triggerStage3Entrance() {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations) {
      _stage3EntranceController.value = 1.0;
    } else {
      _stage3EntranceController.forward(from: 0.0);
    }
  }

  Future<void> _handleCompleteSetup() async {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (!disableAnimations) {
      await _exitController.forward();
    }
    await _viewModel.completeSetup();
    widget.onSetupComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate950,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _exitController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _exitFadeAnimation,
              child: ScaleTransition(
                scale: _exitScaleAnimation,
                child: ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, _) {
                    return Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildProgressIndicator(),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 320),
                            transitionBuilder: (child, animation) {
                              final isTargetReady = child.key == const ValueKey('stage_ready');
                              if (isTargetReady) {
                                _triggerStage3Entrance();
                              }

                              final inAnimation = Tween<Offset>(
                                begin: const Offset(0.2, 0.0),
                                end: Offset.zero,
                              ).animate(animation);

                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: inAnimation,
                                  child: child,
                                ),
                              );
                            },
                            child: _buildStageContent(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final stageIndex = _viewModel.stage.index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepDot(0, 'GET STARTED', stageIndex >= 0),
          _buildStepLine(stageIndex >= 1),
          _buildStepDot(1, 'CONNECT', stageIndex >= 1),
          _buildStepLine(stageIndex >= 2),
          _buildStepDot(2, 'READY', stageIndex >= 2),
        ],
      ),
    );
  }

  Widget _buildStepDot(int index, String label, bool isActive) {
    final Color activeColor = _viewModel.stage == OnboardingStage.ready
        ? AppColors.neonGreen
        : AppColors.electricBlue;

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? activeColor : Colors.white.withOpacity(0.15),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: activeColor.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    final Color activeColor = _viewModel.stage == OnboardingStage.ready
        ? AppColors.neonGreen
        : AppColors.electricBlue;

    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isActive ? activeColor.withOpacity(0.6) : Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildStageContent() {
    switch (_viewModel.stage) {
      case OnboardingStage.welcome:
        return _buildWelcomeStage();
      case OnboardingStage.connection:
        return _buildConnectionStage();
      case OnboardingStage.ready:
        return _buildReadyStage();
    }
  }

  // ── Stage 1: Welcome / Get Started ──────────────────────────────────────────

  Widget _buildWelcomeStage() {
    return Center(
      key: const ValueKey('stage_welcome'),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Earth Hero Visual Component
            FadeTransition(
              opacity: _s1HeroFade,
              child: const AnimatedEarthHero(),
            ),
            const SizedBox(height: 32),

            // Title Reveal
            SlideTransition(
              position: _s1TitleSlide,
              child: Column(
                children: [
                  Text(
                    'EARTH SYSTEMS EXPLORER',
                    style: GoogleFonts.outfit(
                      color: AppColors.electricBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Explore Earth\'s climate systems\nthrough immersive visualization',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description Reveal
            SlideTransition(
              position: _s1DescSlide,
              child: Text(
                'Discover ocean currents, atmospheric circulation, climate oscillations, and their influence on weather using Liquid Galaxy.',
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 44),

            // CTA Button Reveal with Micro-Animation
            SlideTransition(
              position: _s1ButtonSlide,
              child: _InteractiveCtaButton(
                label: 'Get Started',
                icon: CupertinoIcons.arrow_right,
                gradient: const LinearGradient(
                  colors: [AppColors.electricBlue, Color(0xFF2563EB)],
                ),
                boxShadowColor: AppColors.electricBlue.withOpacity(0.35),
                textColor: Colors.white,
                onTap: () => _viewModel.goToConnection(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'LIQUID GALAXY',
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.25),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stage 2: Connection Setup (Mostly Static) ────────────────────────────────

  Widget _buildConnectionStage() {
    final isConnecting = _viewModel.connectionState == ConnectionOpState.connecting;

    return Center(
      key: const ValueKey('stage_connection'),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: isConnecting ? null : () => _viewModel.goBack(),
                  icon: const Icon(CupertinoIcons.arrow_left, color: Colors.white70),
                  tooltip: 'Back',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Connect to Liquid Galaxy',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: Text(
                'Configure the Liquid Galaxy master that Earth Systems Explorer will control.',
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_viewModel.connectionState == ConnectionOpState.failure) ...[
              _buildConnectionFailureCard(),
              const SizedBox(height: 20),
            ],
            _buildFormCard(isConnecting),
            const SizedBox(height: 24),
            _buildConnectButton(isConnecting),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(bool isConnecting) {
    return GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(24),
      borderColor: Colors.white.withOpacity(0.08),
      backgroundColor: Colors.white.withOpacity(0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputField(
            label: 'Master IP / Host',
            controller: _viewModel.ipController,
            icon: CupertinoIcons.flowchart,
            hint: '192.168.1.10',
            errorText: _viewModel.ipError,
            enabled: !isConnecting,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            label: 'Username',
            controller: _viewModel.usernameController,
            icon: CupertinoIcons.person,
            hint: 'lg',
            errorText: _viewModel.usernameError,
            enabled: !isConnecting,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            label: 'Password',
            controller: _viewModel.passwordController,
            icon: CupertinoIcons.lock,
            hint: '••••••••',
            isPassword: true,
            enabled: !isConnecting,
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'Port',
                  controller: _viewModel.portController,
                  icon: CupertinoIcons.number,
                  hint: '22',
                  errorText: _viewModel.portError,
                  keyboardType: TextInputType.number,
                  enabled: !isConnecting,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField(
                  label: 'Screens',
                  controller: _viewModel.rigsController,
                  icon: CupertinoIcons.layers,
                  hint: '3',
                  errorText: _viewModel.rigsError,
                  keyboardType: TextInputType.number,
                  enabled: !isConnecting,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    String? errorText,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: errorText != null ? AppColors.criticalRed : Colors.white.withOpacity(0.5),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: errorText != null
                  ? AppColors.criticalRed.withOpacity(0.7)
                  : Colors.white.withOpacity(0.1),
              width: errorText != null ? 1.2 : 0.8,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: errorText != null
                    ? AppColors.criticalRed
                    : Colors.white.withOpacity(0.4),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  obscureText: isPassword,
                  keyboardType: keyboardType,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                  cursorColor: AppColors.electricBlue,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.outfit(
                      color: Colors.white.withOpacity(0.2),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText,
              style: GoogleFonts.outfit(
                color: AppColors.criticalRed,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConnectButton(bool isConnecting) {
    return GestureDetector(
      onTap: isConnecting ? null : () => _viewModel.connect(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isConnecting
                ? [AppColors.electricBlue.withOpacity(0.5), AppColors.electricBlue.withOpacity(0.5)]
                : [AppColors.electricBlue, const Color(0xFF2563EB)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.electricBlue.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Center(
          child: isConnecting
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Connecting...',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : Text(
                  'Connect to Liquid Galaxy',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildConnectionFailureCard() {
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      borderColor: AppColors.criticalRed.withOpacity(0.4),
      backgroundColor: AppColors.criticalRed.withOpacity(0.08),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.criticalRed.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  color: AppColors.criticalRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unable to Connect',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _viewModel.errorMessage ??
                          'Could not connect to Liquid Galaxy. Check the connection details and make sure the master is running and reachable.',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _viewModel.resetConnectionState(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.criticalRed,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              icon: const Icon(CupertinoIcons.refresh, size: 16),
              label: Text(
                'Try Again',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stage 3: Start Exploring & Optional Send Logo (Animated Reveal) ──────────

  Widget _buildReadyStage() {
    final String masterIp = _viewModel.ipController.text.trim();
    final String screens = _viewModel.rigsController.text.trim();
    final isSendingLogo = _viewModel.logoState == LogoOpState.sending;

    return Center(
      key: const ValueKey('stage_ready'),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            // One-Shot Animated Success Checkmark Reveal with Pulse Rings
            const ConnectedSuccessReveal(),
            const SizedBox(height: 20),
            Text(
              'Liquid Galaxy Connected',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Earth Systems Explorer is\nready to explore.',
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.7),
                fontSize: 15,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Staged Rig Summary Card Reveal
            SlideTransition(
              position: _s3CardSlide,
              child: GlassCard(
                borderRadius: 24,
                padding: const EdgeInsets.all(20),
                borderColor: Colors.white.withOpacity(0.08),
                backgroundColor: Colors.white.withOpacity(0.03),
                child: Column(
                  children: [
                    _buildSummaryRow('Master', masterIp),
                    const Divider(height: 24, color: Colors.white10),
                    _buildSummaryRow('Screens', screens),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Primary Action: Start Exploring (with Entrance & Press Micro-Animation)
            SlideTransition(
              position: _s3ButtonSlide,
              child: Column(
                children: [
                  _InteractiveCtaButton(
                    label: 'Start Exploring',
                    icon: CupertinoIcons.arrow_right,
                    gradient: const LinearGradient(
                      colors: [AppColors.neonGreen, Color(0xFF16A34A)],
                    ),
                    boxShadowColor: AppColors.neonGreen.withOpacity(0.35),
                    textColor: Colors.black,
                    onTap: _handleCompleteSetup,
                  ),
                  const SizedBox(height: 18),

                  // Secondary / Optional Action: Send Logo
                  GestureDetector(
                    onTap: isSendingLogo ? null : () => _viewModel.sendLogo(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: Center(
                        child: isSendingLogo
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Sending Logo...',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Send Logo',
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Display the Earth Systems Explorer logo on the rig.',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_viewModel.logoFeedback != null) ...[
                    const SizedBox(height: 12),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: _viewModel.logoFeedback != null ? 1.0 : 0.0,
                      child: Text(
                        _viewModel.logoFeedback!,
                        style: GoogleFonts.outfit(
                          color: _viewModel.logoState == LogoOpState.success
                              ? AppColors.neonGreen
                              : AppColors.criticalRed,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Interactive CTA Button with subtle tap scale-down and arrow translation.
class _InteractiveCtaButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final Color boxShadowColor;
  final Color textColor;
  final VoidCallback onTap;

  const _InteractiveCtaButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.boxShadowColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_InteractiveCtaButton> createState() => _InteractiveCtaButtonState();
}

class _InteractiveCtaButtonState extends State<_InteractiveCtaButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) => _pressController.reverse(),
      onTapCancel: () => _pressController.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.boxShadowColor,
                blurRadius: 20,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.outfit(
                  color: widget.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                widget.icon,
                color: widget.textColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
