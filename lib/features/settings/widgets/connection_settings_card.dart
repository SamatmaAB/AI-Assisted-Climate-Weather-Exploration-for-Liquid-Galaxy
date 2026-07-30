import 'package:flutter/material.dart';
import 'settings_input.dart';

/// Card containing the Liquid Galaxy SSH connection form fields and action buttons.
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsInput(
              label: 'IP Address',
              controller: ipController,
              prefixIcon: Icons.device_hub_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            SettingsInput(
              label: 'SSH Port',
              controller: portController,
              prefixIcon: Icons.tag_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SettingsInput(
              label: 'Username',
              controller: usernameController,
              prefixIcon: Icons.person_outlined,
            ),
            const SizedBox(height: 16),
            SettingsInput(
              label: 'Password',
              controller: passwordController,
              prefixIcon: Icons.lock_outlined,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            SettingsInput(
              label: 'Number of Rigs',
              controller: rigsController,
              prefixIcon: Icons.monitor_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSave,
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: isConnecting ? null : onConnect,
                    child: isConnecting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Connect'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
