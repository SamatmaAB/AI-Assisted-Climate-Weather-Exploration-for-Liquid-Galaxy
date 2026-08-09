import 'package:flutter/material.dart';
import 'package:lg_connection/features/tours/tour_viewmodel.dart';
import 'package:lg_connection/main.dart';
import 'package:lg_connection/services/tts/tts_service.dart';

class TourScreen extends StatefulWidget {
  final String phenomenon;

  const TourScreen({super.key, required this.phenomenon});

  @override
  State<TourScreen> createState() => _TourScreenState();
}

class _TourScreenState extends State<TourScreen> {
  late TourViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TourViewModel(aiRepository);
    _viewModel.loadExplanation(widget.phenomenon);
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.phenomenon),
        actions: [
          Row(
            children: [
              Text(
                'SYNC',
                style: textTheme.labelSmall?.copyWith(color: colorScheme.primary),
              ),
              Switch(
                value: _viewModel.isSynced,
                onChanged: (val) => _viewModel.toggleSync(val),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'PLANETARY SIMULATION',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        _viewModel.isPlaying ? Icons.graphic_eq : Icons.public,
                        color: _viewModel.isPlaying ? colorScheme.secondary : colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _viewModel.isPlaying ? 'Tour Active' : 'System Standby',
                              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _viewModel.isPlaying
                                  ? 'Synchronizing multi-display rig...'
                                  : 'Ready for planetary visualization.',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader(context, 'SIMULATION METRICS'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildMetricCard(context, Icons.thermostat, 'TEMP', '24.2°C')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMetricCard(context, Icons.air, 'VELOCITY', '12m/s')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMetricCard(context, Icons.water_drop, 'HUMIDITY', '68%')),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader(context, 'MECHANISM ANALYSIS'),
                  if (!_viewModel.isLoadingExplanation && _viewModel.explanation.isNotEmpty)
                    ListenableBuilder(
                      listenable: TtsService.instance,
                      builder: (context, _) {
                        final isSpeakingThis =
                            TtsService.instance.isSpeakingText(_viewModel.explanation);
                        return InkWell(
                          onTap: () {
                            if (isSpeakingThis) {
                              TtsService.instance.stop();
                            } else {
                              TtsService.instance.speak(_viewModel.explanation);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSpeakingThis ? Icons.volume_up : Icons.volume_up_outlined,
                                  size: 16,
                                  color: isSpeakingThis
                                      ? colorScheme.primary
                                      : colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isSpeakingThis ? 'Stop' : 'Read aloud',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: isSpeakingThis
                                        ? colorScheme.primary
                                        : colorScheme.onSurface.withValues(alpha: 0.6),
                                    fontWeight: isSpeakingThis
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _viewModel.isLoadingExplanation
                      ? const Center(child: CircularProgressIndicator())
                      : Text(
                          _viewModel.explanation.isNotEmpty
                              ? _viewModel.explanation
                              : 'No explanation available.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.8),
                            height: 1.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.layers_outlined),
                      label: const Text('KML Layer'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: () => _viewModel.isPlaying
                          ? _viewModel.stopTour()
                          : _viewModel.startTour(),
                      icon: Icon(_viewModel.isPlaying ? Icons.stop : Icons.play_arrow),
                      label: Text(_viewModel.isPlaying ? 'TERMINATE TOUR' : 'INITIATE TOUR'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _viewModel.isPlaying
                            ? colorScheme.error
                            : colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.5),
        letterSpacing: 1.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, IconData icon, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 9,
              ),
            ),
            Text(
              value,
              style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
