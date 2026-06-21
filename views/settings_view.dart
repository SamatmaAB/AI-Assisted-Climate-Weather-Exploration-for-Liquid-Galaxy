import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../state/app_state.dart';
import '../services/ssh_service.dart';
import '../widgets/glass_card.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _ipController;
  late TextEditingController _portController;
  late TextEditingController _userController;
  late TextEditingController _passController;
  late TextEditingController _rigsController;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _ipController = TextEditingController(text: appState.lgIp);
    _portController = TextEditingController(text: appState.lgPort);
    _userController = TextEditingController(text: appState.lgUsername);
    _passController = TextEditingController(text: appState.lgPassword);
    _rigsController = TextEditingController(text: appState.lgRigs);
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _userController.dispose();
    _passController.dispose();
    _rigsController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    context.read<AppState>().saveLgSettings(
      ip: _ipController.text,
      port: _portController.text,
      username: _userController.text,
      password: _passController.text,
      rigs: _rigsController.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final sshService = context.read<SSHService>();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: const Text(
              'App Settings',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _SettingsSection(
                title: 'Liquid Galaxy Connection',
                children: [
                  _buildTextField('IP Address', _ipController, LucideIcons.network),
                  _buildTextField('SSH Port', _portController, LucideIcons.hash),
                  _buildTextField('Username', _userController, LucideIcons.user),
                  _buildTextField('Password', _passController, LucideIcons.lock, obscureText: true),
                  _buildTextField('Number of Rigs', _rigsController, LucideIcons.layers),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveSettings,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appState.accentGreen.withOpacity(0.2),
                              foregroundColor: appState.accentGreen,
                              elevation: 0,
                            ),
                            child: const Text('Save Credentials'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final success = await sshService.connect();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success ? 'Connected to LG' : 'Connection failed'),
                                    backgroundColor: success ? Colors.green : Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appState.isConnected ? Colors.green.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                              foregroundColor: appState.isConnected ? Colors.greenAccent : Colors.blueAccent,
                              elevation: 0,
                            ),
                            child: Text(appState.isConnected ? 'Connected' : 'Connect'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 24),

              _SettingsSection(
                title: 'Appearance',
                children: [
                  _SettingsToggle(
                    icon: LucideIcons.moon,
                    title: 'Dark Mode',
                    value: appState.isDarkMode,
                    onChanged: (_) => appState.toggleDarkMode(),
                  ),
                  _SettingsToggle(
                    icon: LucideIcons.eye,
                    title: 'Color Blind Mode',
                    value: appState.isColorBlindMode,
                    onChanged: (_) => appState.toggleColorBlindMode(),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 24),
              
              _SettingsSection(
                title: 'About',
                children: [
                  _SettingsLink(icon: LucideIcons.book, title: 'User Guide'),
                  _SettingsLink(icon: LucideIcons.info, title: 'Version 1.0.0 (Beta)'),
                  _SettingsLink(icon: LucideIcons.github, title: 'Open Source Code'),
                ],
              ).animate().fadeIn(delay: 300.ms),
              
              const SizedBox(height: 40),
              
              Center(
                child: Text(
                  'Earth Science Visualization App\nLiquid Galaxy Project 2026',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: appState.textSecondaryColor, fontSize: 12, height: 1.5),
                ),
              ).animate().fadeIn(delay: 400.ms),
              
              const SizedBox(height: 120),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool obscureText = false}) {
    final appState = context.read<AppState>();
    return ListTile(
      leading: Icon(icon, color: appState.isDarkMode ? Colors.white70 : Colors.black87),
      title: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          labelStyle: TextStyle(color: appState.textSecondaryColor, fontSize: 14),
        ),
        style: TextStyle(color: appState.textColor, fontSize: 14),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey),
          ),
        ),
        GlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.symmetric(vertical: 8),
          blur: 0, // Performance: Disable blur for settings containers
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    return ListTile(
      leading: Icon(icon, color: appState.isDarkMode ? Colors.white70 : Colors.black87),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: appState.accentGreen,
      ),
    );
  }
}

class _SettingsLink extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SettingsLink({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    return ListTile(
      leading: Icon(icon, color: appState.isDarkMode ? Colors.white70 : Colors.black87),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(LucideIcons.externalLink, size: 16, color: Colors.grey),
    );
  }
}
