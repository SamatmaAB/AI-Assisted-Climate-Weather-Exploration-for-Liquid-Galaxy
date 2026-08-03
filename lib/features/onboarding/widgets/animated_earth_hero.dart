import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Ambient animated Earth Hero widget for Stage 1 (Get Started).
/// Uses Flutter canvas & transforms; replaced Cupertino globe icon with Material public icon.
class AnimatedEarthHero extends StatefulWidget {
  const AnimatedEarthHero({super.key});

  @override
  State<AnimatedEarthHero> createState() => _AnimatedEarthHeroState();
}

class _AnimatedEarthHeroState extends State<AnimatedEarthHero> with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _rotationController;

  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _floatAnimation = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations) {
      _floatController.stop();
      _rotationController.stop();
    } else {
      if (!_floatController.isAnimating) _floatController.repeat(reverse: true);
      if (!_rotationController.isAnimating) _rotationController.repeat();
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: Listenable.merge([_floatAnimation, _rotationController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Soft background ring
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                  ),
                ),

                // Rotating Globe Core
                Transform.rotate(
                  angle: _rotationController.value * 2 * math.pi,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primaryContainer,
                          colorScheme.surface,
                        ],
                      ),
                    ),
                    child: ClipOval(
                      child: CustomPaint(
                        size: const Size(120, 120),
                        painter: _GlobeGridPainter(colorScheme.onPrimaryContainer),
                      ),
                    ),
                  ),
                ),

                // Center Earth Icon
                Icon(
                  Icons.public,
                  color: colorScheme.onPrimaryContainer,
                  size: 40,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GlobeGridPainter extends CustomPainter {
  final Color color;

  _GlobeGridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.width * 0.9, height: size.height * 0.4),
      paint,
    );
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.width * 0.4, height: size.height * 0.9),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
