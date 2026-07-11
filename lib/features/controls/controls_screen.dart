import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/core/theme/app_colors.dart';
import 'package:lg_connection/features/controls/controls_viewmodel.dart';
import 'package:lg_connection/features/controls/widgets/availability_card.dart';
import 'package:lg_connection/features/controls/widgets/task_button.dart';

/// Screen for managing Liquid Galaxy rig services and system tasks.
class ControlsScreen extends StatefulWidget {
  const ControlsScreen({super.key});

  @override
  State<ControlsScreen> createState() => _ControlsScreenState();
}

class _ControlsScreenState extends State<ControlsScreen> {
  late ControlsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ControlsViewModel();
  }

  void _showFeedback(String message, bool isSuccess) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.electricBlue : AppColors.criticalRed,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 110, left: 20, right: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: AppColors.slate950,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 40),
              Text(
                'Liquid Galaxy\nServices',
                style: GoogleFonts.outfit(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 32),
              
              _buildSubHeader('SYSTEM TASKS'),
              const SizedBox(height: 16),
              _buildSystemTasks(),
              
              const SizedBox(height: 32),
              _buildSubHeader('VISUAL CONTROLS'),
              const SizedBox(height: 16),
              _buildVisualControls(),
              
              const SizedBox(height: 32),
              ValueListenableBuilder<bool>(
                valueListenable: _viewModel.isConnected,
                builder: (context, connected, _) {
                  return AvailabilityCard(
                    isConnected: connected,
                    statusColor: connected ? AppColors.neonGreen : AppColors.criticalRed,
                  );
                },
              ),
              
              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: Colors.white.withOpacity(0.4),
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildSystemTasks() {
    return Row(
      children: [
        Expanded(
          child: TaskButton(
            label: 'Shutdown',
            icon: CupertinoIcons.power,
            color: AppColors.criticalRed,
            onPressed: () async {
              await _viewModel.shutdown();
              _showFeedback('Shutdown command sent to all rigs', true);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TaskButton(
            label: 'Reboot',
            icon: CupertinoIcons.refresh_bold,
            color: AppColors.warningOrange,
            onPressed: () async {
              await _viewModel.reboot();
              _showFeedback('Reboot command sent to all rigs', true);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TaskButton(
            label: 'Clear KML',
            icon: CupertinoIcons.trash,
            color: AppColors.electricBlue,
            onPressed: () async {
              await _viewModel.clearKML();
              _showFeedback('KMLs cleared successfully', true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVisualControls() {
    return Row(
      children: [
        Expanded(
          child: TaskButton(
            label: 'Show Logo',
            icon: CupertinoIcons.photo,
            color: AppColors.neonGreen,
            onPressed: () async {
              await _viewModel.sendLogo();
              _showFeedback('Logo sent to slave rig', true);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TaskButton(
            label: 'Orbit',
            icon: CupertinoIcons.eye,
            color: AppColors.purpleAccent,
            onPressed: () async {
              await _viewModel.startOrbit();
              _showFeedback('Orbiting started', true);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TaskButton(
            label: 'Refresh',
            icon: CupertinoIcons.arrow_2_circlepath,
            color: AppColors.refreshCyan,
            onPressed: () async {
              await _viewModel.refreshSystem();
              _showFeedback('System services refreshed', true);
            },
          ),
        ),
      ],
    );
  }
}
