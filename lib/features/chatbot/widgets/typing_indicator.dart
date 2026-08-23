import 'package:flutter/material.dart';
import 'package:lg_connection/features/onboarding/widgets/mascot_animation.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          const MascotAnimation(
            assetPath: 'assets/spriteanimations/thinking.webp',
            width: 110,
            height: 110,
          ),
          const SizedBox(width: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF262A34),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final delay = i * 0.28;
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    final raw = (_controller.value - delay).clamp(0.0, 1.0);
                    final bounce = (raw < 0.5)
                        ? Curves.easeOut.transform(raw * 2)
                        : 1.0 - Curves.easeIn.transform((raw - 0.5) * 2);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 7,
                      height: 7 + bounce * 6,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.7 + bounce * 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
