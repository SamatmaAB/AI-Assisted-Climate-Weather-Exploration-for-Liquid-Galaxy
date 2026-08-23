import 'package:flutter/material.dart';
import 'package:lg_connection/features/onboarding/widgets/mascot_animation.dart';

class ConnectedSuccessReveal extends StatelessWidget {
  const ConnectedSuccessReveal({super.key});

  @override
  Widget build(BuildContext context) {
    return const MascotAnimation(
      assetPath: 'assets/spriteanimations/celebrations.webp',
      width: 220,
      height: 220,
      fit: BoxFit.contain,
    );
  }
}
