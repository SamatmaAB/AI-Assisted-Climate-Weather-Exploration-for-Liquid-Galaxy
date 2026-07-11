import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pulse_indicator.dart';

/// A badge that displays the connection status (ONLINE/OFFLINE).
class StatusBadge extends StatelessWidget {
  final bool isConnected;
  final Color connectedColor;
  final Color disconnectedColor;

  const StatusBadge({
    super.key,
    required this.isConnected,
    this.connectedColor = const Color(0xFF22C55E),
    this.disconnectedColor = const Color(0xFFEF4444),
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isConnected ? connectedColor : disconnectedColor;
    final label = isConnected ? 'RIG CONNECTED' : 'OFFLINE';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PulseIndicator(color: statusColor),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: statusColor,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.7,
          ),
        ),
      ],
    );
  }
}
