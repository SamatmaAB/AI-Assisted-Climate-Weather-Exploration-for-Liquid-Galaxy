import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lg_connection/core/theme/app_colors.dart';

/// One-shot animated success reveal for Stage 3 (Start Exploring).
/// Features checkmark pop, expanding connection pulse rings, and green atmospheric glow.
class ConnectedSuccessReveal extends StatefulWidget {
  const ConnectedSuccessReveal({super.key});

  @override
  State<ConnectedSuccessReveal> createState() => _ConnectedSuccessRevealState();
}

class _ConnectedSuccessRevealState extends State<ConnectedSuccessReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _ringAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Checkmark container scale pop: 0.5 -> 1.08 -> 1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.5, end: 1.08), weight: 65),
      TweenSequenceItem(tween: Tween<double>(begin: 1.08, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Expanding pulse rings: 0.0 -> 1.0
    _ringAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );

    // Initial glow burst: 0.0 -> 1.0 -> 0.4
    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.4), weight: 60),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations) {
      _controller.value = 1.0;
    } else if (!_controller.isCompleted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Expanding Connection Pulse Rings (Phone -> Rig -> Connected)
                CustomPaint(
                  size: const Size(180, 180),
                  painter: _PulseRingsPainter(
                    progress: _ringAnimation.value,
                  ),
                ),

                // Success Glow Burst
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonGreen.withOpacity(_glowAnimation.value * 0.5),
                        blurRadius: 35,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),

                // Checkmark Container Pop
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.neonGreen.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.neonGreen.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      CupertinoIcons.checkmark_alt,
                      color: AppColors.neonGreen,
                      size: 46,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// CustomPainter rendering 2 expanding concentric pulse rings.
class _PulseRingsPainter extends CustomPainter {
  final double progress;

  _PulseRingsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final center = Offset(size.width / 2, size.height / 2);

    // Ring 1 (expands first)
    final radius1 = 45.0 + (progress * 40.0);
    final opacity1 = (1.0 - progress).clamp(0.0, 1.0) * 0.7;

    final paint1 = Paint()
      ..color = AppColors.neonGreen.withOpacity(opacity1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawCircle(center, radius1, paint1);

    // Ring 2 (slightly delayed expansion)
    if (progress > 0.2) {
      final ring2Progress = (progress - 0.2) / 0.8;
      final radius2 = 45.0 + (ring2Progress * 42.0);
      final opacity2 = (1.0 - ring2Progress).clamp(0.0, 1.0) * 0.5;

      final paint2 = Paint()
        ..color = AppColors.neonGreen.withOpacity(opacity2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      canvas.drawCircle(center, radius2, paint2);
    }
  }

  @override
  bool shouldRepaint(covariant _PulseRingsPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
