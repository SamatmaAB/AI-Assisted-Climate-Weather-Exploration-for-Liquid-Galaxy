import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isPassword;

  const SettingsInput({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.4), size: 22),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 12,
                ),
              ),
              TextField(
                controller: controller,
                obscureText: isPassword,
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
                cursorColor: Colors.white.withOpacity(0.6),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
