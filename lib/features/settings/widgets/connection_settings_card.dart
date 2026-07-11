import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lg_connection/core/common_widgets/glass_card.dart';
import 'package:lg_connection/core/theme/app_colors.dart';
import 'package:lg_connection/features/settings/widgets/settings_input.dart';

class ConnectionSettingsCard extends StatelessWidget {
  final TextEditingController ipController;
  final TextEditingController portController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController rigsController;
  final bool isConnecting;
  final VoidCallback onSave;
  final VoidCallback onConnect;

  const ConnectionSettingsCard({
    super.key,
    required this.ipController,
    required this.portController,
    required this.usernameController,
    required this.passwordController,
    required this.rigsController,
    required this.isConnecting,
    required this.onSave,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 28,
      borderColor: Colors.white.withOpacity(0.05),
      backgroundColor: Colors.white.withOpacity(0.02),
      child: Column(
        children: [
          SettingsInput(label: 'IP Address', controller: ipController, icon: CupertinoIcons.flowchart),
          const SizedBox(height: 24),
          SettingsInput(label: 'SSH Port', controller: portController, icon: CupertinoIcons.number),
          const SizedBox(height: 24),
          SettingsInput(label: 'Username', controller: usernameController, icon: CupertinoIcons.person),
          const SizedBox(height: 24),
          SettingsInput(label: 'Password', controller: passwordController, icon: CupertinoIcons.lock, isPassword: true),
          const SizedBox(height: 24),
          SettingsInput(label: 'Number of Rigs', controller: rigsController, icon: CupertinoIcons.layers),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildSmallButton(
                  'Save',
                  AppColors.neonGreen.withOpacity(0.08),
                  AppColors.neonGreen,
                  onSave,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSmallButton(
                  isConnecting ? 'Connecting...' : 'Connect',
                  AppColors.electricBlue.withOpacity(0.08),
                  AppColors.electricBlue,
                  isConnecting ? () {} : onConnect,
                  isLoading: isConnecting,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton(String label, Color bgColor, Color textColor, VoidCallback onTap, {bool isLoading = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: textColor.withOpacity(0.1)),
        ),
        child: Center(
          child: isLoading 
            ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(textColor)))
            : Text(label, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
