import 'package:flutter/material.dart';
import 'package:lg_connection/features/onboarding/widgets/mascot_animation.dart';

/// Success animation widget for Stage 3 (Connection successful).
/// Displays celebrations.webp mascot continuously until the user proceeds.
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
