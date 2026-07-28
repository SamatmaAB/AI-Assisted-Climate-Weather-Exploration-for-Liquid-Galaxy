import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lg_connection/core/theme/app_colors.dart';

/// Ambient animated Earth Hero widget for Stage 1 (Get Started).
/// Features vertical floating, atmospheric glow pulsation, slow continuous rotation,
/// and a deterministic starfield background using GPU-friendly Flutter transforms.
class AnimatedEarthHero extends StatefulWidget {
  const AnimatedEarthHero({super.key});

  @override
  State<AnimatedEarthHero> createState() => _AnimatedEarthHeroState();
}

class _AnimatedEarthHeroState extends State<AnimatedEarthHero> with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _glowController;
  late final AnimationController _rotationController;

  late final Animation<double> _floatAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // 4-second float loop (0 -> -6px -> 0)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _floatAnimation = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // 3.5-second atmospheric glow pulse loop
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _glowAnimation = Tween<double>(begin: 0.25, end: 0.45).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // 25-second continuous slow rotation loop
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
      _glowController.stop();
      _rotationController.stop();
    } else {
      if (!_floatController.isAnimating) _floatController.repeat(reverse: true);
      if (!_glowController.isAnimating) _glowController.repeat(reverse: true);
      if (!_rotationController.isAnimating) _rotationController.repeat();
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _glowController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatAnimation, _glowAnimation, _rotationController]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Atmospheric Background Glow
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricBlue.withOpacity(_glowAnimation.value),
                          blurRadius: 45,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: AppColors.refreshCyan.withOpacity(_glowAnimation.value * 0.5),
                          blurRadius: 65,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                  ),

                  // Background Starfield & Atmosphere Painter
                  CustomPaint(
                    size: const Size(220, 220),
                    painter: _AtmosphereStarfieldPainter(
                      glowOpacity: _glowAnimation.value,
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
                          center: const Alignment(-0.3, -0.3),
                          radius: 0.8,
                          colors: [
                            const Color(0xFF60A5FA),
                            AppColors.electricBlue,
                            const Color(0xFF1E3A8A),
                            AppColors.slate950,
                          ],
                          stops: const [0.0, 0.4, 0.8, 1.0],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.electricBlue.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: CustomPaint(
                          size: const Size(120, 120),
                          painter: _GlobeGridPainter(),
                        ),
                      ),
                    ),
                  ),

                  // Center Earth Icon Overlay
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.slate950.withOpacity(0.4),
                    ),
                    child: const Icon(
                      CupertinoIcons.globe,
                      color: AppColors.cyanWhite,
                      size: 34,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// CustomPainter that renders a deterministic starfield and soft atmospheric ring.
class _AtmosphereStarfieldPainter extends CustomPainter {
  final double glowOpacity;

  static const List<Offset> _starOffsets = [
    Offset(-90, -70),
    Offset(85, -60),
    Offset(-80, 75),
    Offset(95, 65),
    Offset(-100, -10),
    Offset(105, -15),
    Offset(-45, -95),
    Offset(55, -90),
    Offset(-50, 95),
    Offset(60, 90),
    Offset(-110, 40),
    Offset(110, -45),
  ];

  _AtmosphereStarfieldPainter({required this.glowOpacity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Render faint deterministic stars
    final starPaint = Paint()
      ..color = Colors.white.withOpacity(0.35 * (glowOpacity / 0.45))
      ..style = PaintingStyle.fill;

    for (int i = 0; i < _starOffsets.length; i++) {
      final pos = center + _starOffsets[i];
      final radius = (i % 2 == 0) ? 1.2 : 1.8;
      canvas.drawCircle(pos, radius, starPaint);
    }

    // Soft atmospheric ring
    final ringPaint = Paint()
      ..color = AppColors.refreshCyan.withOpacity(glowOpacity * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, 72, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _AtmosphereStarfieldPainter oldDelegate) {
    return oldDelegate.glowOpacity != glowOpacity;
  }
}

/// CustomPainter rendering abstract latitude/longitude grid lines on the globe.
class _GlobeGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Equator & latitude arcs
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.width * 0.9, height: size.height * 0.4),
      paint,
    );

    // Longitude meridian arcs
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.width * 0.4, height: size.height * 0.9),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
