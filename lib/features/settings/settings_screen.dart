import 'package:flutter/material.dart';
import 'package:lg_connection/core/common_widgets/status_badge.dart';
import 'package:lg_connection/features/settings/settings_viewmodel.dart';
import 'package:lg_connection/features/settings/widgets/about_card.dart';
import 'package:lg_connection/features/settings/widgets/ai_settings_card.dart';
import 'package:lg_connection/features/settings/widgets/appearance_card.dart';
import 'package:lg_connection/features/settings/widgets/connection_settings_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SettingsViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _showFeedback(String message, bool isSuccess) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess
            ? Theme.of(context).colorScheme.secondaryContainer
            : Theme.of(context).colorScheme.errorContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Settings',
                      style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _viewModel.isConnected,
                      builder: (context, connected, _) => StatusBadge(isConnected: connected),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                _buildSectionLabel(context, 'Liquid Galaxy Connection'),
                const SizedBox(height: 12),
                ConnectionSettingsCard(
                  ipController: _viewModel.ipController,
                  portController: _viewModel.portController,
                  usernameController: _viewModel.usernameController,
                  passwordController: _viewModel.passwordController,
                  rigsController: _viewModel.rigsController,
                  isConnecting: _viewModel.isConnecting,
                  onSave: () async {
                    await _viewModel.saveSettings();
                    _showFeedback('Settings saved successfully', true);
                  },
                  onConnect: () async {
                    final success = await _viewModel.connect();
                    _showFeedback(
                      success
                          ? 'Successfully connected to Liquid Galaxy!'
                          : 'Connection failed. Verify IP and credentials.',
                      success,
                    );
                  },
                ),
                const SizedBox(height: 28),

                _buildSectionLabel(context, 'AI Assistant'),
                const SizedBox(height: 12),
                AiSettingsCard(
                  apiKeyController: _viewModel.apiKeyController,
                  isObscured: _viewModel.isApiKeyObscured,
                  onToggleVisibility: _viewModel.toggleApiKeyVisibility,
                  onSave: () async {
                    await _viewModel.saveApiKey();
                    _showFeedback('Gemini API key saved successfully', true);
                  },
                  onRemove: () async {
                    await _viewModel.deleteApiKey();
                    _showFeedback('Gemini API key removed successfully', true);
                  },
                ),
                const SizedBox(height: 28),

                _buildSectionLabel(context, 'Appearance'),
                const SizedBox(height: 12),
                AppearanceCard(
                  isDarkMode: _viewModel.isDarkMode,
                  isColorblindMode: _viewModel.isColorblindMode,
                  onDarkModeChanged: _viewModel.toggleDarkMode,
                  onColorblindModeChanged: _viewModel.toggleColorblindMode,
                ),
                const SizedBox(height: 28),

                _buildSectionLabel(context, 'About'),
                const SizedBox(height: 12),
                const AboutCard(),
                const SizedBox(height: 28),

                Center(
                  child: Column(
                    children: [
                      Text(
                        'Earth Science Visualization App',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                      Text(
                        'Liquid Galaxy Project 2026',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.55),
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
