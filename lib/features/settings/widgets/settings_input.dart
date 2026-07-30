import 'package:flutter/material.dart';

/// A styled text input for settings forms.
///
/// Uses the global InputDecorationTheme. Do NOT redefine border or fill inline.
class SettingsInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType? keyboardType;

  const SettingsInput({
    super.key,
    required this.label,
    required this.controller,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
      ),
    );
  }
}
