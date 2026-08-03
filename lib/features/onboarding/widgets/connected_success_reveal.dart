import 'package:flutter/material.dart';

/// One-shot animated success reveal for Stage 3 (Start Exploring).
/// Cleaned up to use M3 ColorScheme (secondary color for success). Replaced Cupertino icon.
class ConnectedSuccessReveal extends StatefulWidget {
  const ConnectedSuccessReveal({super.key});

  @override
  State<ConnectedSuccessReveal> createState() => _ConnectedSuccessRevealState();
}

class _ConnectedSuccessRevealState extends State<ConnectedSuccessReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.5, end: 1.08), weight: 65),
      TweenSequenceItem(tween: Tween<double>(begin: 1.08, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
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
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: colorScheme.onSecondaryContainer,
              size: 48,
            ),
          ),
        );
      },
    );
  }
}
