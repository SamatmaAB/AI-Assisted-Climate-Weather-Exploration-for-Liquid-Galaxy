import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/core/theme/app_colors.dart';
import 'package:lg_connection/features/settings/settings_viewmodel.dart';
import 'package:lg_connection/features/settings/widgets/about_card.dart';
import 'package:lg_connection/features/settings/widgets/appearance_card.dart';
import 'package:lg_connection/features/settings/widgets/connection_settings_card.dart';

/// Screen for configuring application preferences and Liquid Galaxy connection details.
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
        backgroundColor: isSuccess ? AppColors.neonGreen : AppColors.criticalRed,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 110, left: 20, right: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.slate950,
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          return SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildSubHeader('LIQUID GALAXY CONNECTION'),
                const SizedBox(height: 16),
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
                const SizedBox(height: 32),
                _buildSubHeader('APPEARANCE'),
                const SizedBox(height: 16),
                AppearanceCard(
                  isDarkMode: _viewModel.isDarkMode,
                  isColorblindMode: _viewModel.isColorblindMode,
                  onDarkModeChanged: _viewModel.toggleDarkMode,
                  onColorblindModeChanged: _viewModel.toggleColorblindMode,
                  activeColor: AppColors.neonGreen,
                ),
                const SizedBox(height: 32),
                _buildSubHeader('ABOUT'),
                const SizedBox(height: 16),
                const AboutCard(),
                const SizedBox(height: 40),
                _buildFooter(),
                const SizedBox(height: 160),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Settings',
          style: GoogleFonts.outfit(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _viewModel.isConnected,
          builder: (context, connected, _) {
            return _buildStatusBadge(
              connected ? 'ONLINE' : 'OFFLINE',
              connected ? AppColors.neonGreen : AppColors.criticalRed,
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 4, spreadRadius: 1),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: Colors.white.withOpacity(0.4),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Text(
            'Earth Science Visualization App',
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.3),
              fontSize: 12,
            ),
          ),
          Text(
            'Liquid Galaxy Project 2026',
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.3),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
