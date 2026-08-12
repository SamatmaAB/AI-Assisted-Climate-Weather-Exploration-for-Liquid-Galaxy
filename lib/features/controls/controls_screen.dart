import 'package:flutter/material.dart';
import 'package:lg_connection/features/controls/controls_viewmodel.dart';
import 'package:lg_connection/features/controls/widgets/availability_card.dart';
import 'package:lg_connection/features/controls/widgets/task_button.dart';

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

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _showFeedback(String message, bool isSuccess) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 32),
            Text(
              'Liquid Galaxy\nServices',
              style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700, height: 1.1),
            ),
            const SizedBox(height: 28),

            _buildSectionLabel(context, 'System Tasks'),
            const SizedBox(height: 12),
            _buildSystemTasks(colorScheme),

            const SizedBox(height: 28),
            _buildSectionLabel(context, 'Visual Controls'),
            const SizedBox(height: 12),
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) => _buildVisualControls(colorScheme),
            ),

            const SizedBox(height: 28),
            _buildSectionLabel(context, 'Tour'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TaskButton(
                    label: 'Exit Tour',
                    icon: Icons.exit_to_app_outlined,
                    role: TaskButtonRole.destructive,
                    onPressed: () async {
                      final ok = await _viewModel.exitTour();
                      _showFeedback(
                        ok ? 'Tour exited' : 'Exit tour failed — check connection',
                        ok,
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),
            ValueListenableBuilder<bool>(
              valueListenable: _viewModel.isConnected,
              builder: (context, connected, _) {
                return AvailabilityCard(isConnected: connected);
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
          ),
    );
  }

  Widget _buildSystemTasks(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: TaskButton(
            label: 'Shutdown',
            icon: Icons.power_settings_new_outlined,
            role: TaskButtonRole.destructive,
            onPressed: () async {
              final ok = await _viewModel.shutdown();
              _showFeedback(
                ok ? 'Shutdown command sent to all rigs' : 'Shutdown failed — check connection',
                ok,
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TaskButton(
            label: 'Reboot',
            icon: Icons.restart_alt_outlined,
            role: TaskButtonRole.warning,
            onPressed: () async {
              final ok = await _viewModel.reboot();
              _showFeedback(
                ok ? 'Reboot command sent to all rigs' : 'Reboot failed — check connection',
                ok,
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TaskButton(
            label: 'Clear KML',
            icon: Icons.layers_clear_outlined,
            role: TaskButtonRole.normal,
            onPressed: () async {
              final ok = await _viewModel.clearKML();
              _showFeedback(
                ok ? 'All KMLs cleared successfully' : 'Clear KML failed — check connection',
                ok,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVisualControls(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: TaskButton(
            label: 'Show Logo',
            icon: Icons.image_outlined,
            role: TaskButtonRole.normal,
            onPressed: () async {
              final ok = await _viewModel.sendLogo();
              _showFeedback(
                ok ? 'Logo sent to slave rig' : 'Failed to send logo — check connection',
                ok,
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TaskButton(
            label: _viewModel.isOrbiting ? 'Stop Orbit' : 'Orbit',
            icon: _viewModel.isOrbiting
                ? Icons.stop_circle_outlined
                : Icons.rotate_90_degrees_ccw_outlined,
            role: _viewModel.isOrbiting ? TaskButtonRole.destructive : TaskButtonRole.normal,
            onPressed: () async {
              final wasOrbiting = _viewModel.isOrbiting;
              await _viewModel.startOrbit();
              if (_viewModel.isOrbiting != wasOrbiting) {
                _showFeedback(
                  _viewModel.isOrbiting ? 'Orbiting started' : 'Orbiting stopped',
                  true,
                );
              } else if (!wasOrbiting) {
                _showFeedback('Failed to start orbit — check connection', false);
              }
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TaskButton(
            label: 'Refresh',
            icon: Icons.refresh_outlined,
            role: TaskButtonRole.normal,
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
