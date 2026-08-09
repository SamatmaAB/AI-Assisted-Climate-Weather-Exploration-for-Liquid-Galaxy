import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:lg_connection/core/common_widgets/status_badge.dart';
import 'package:lg_connection/features/home/home_viewmodel.dart';
import 'package:lg_connection/features/home/widgets/chatbot_entry_button.dart';
import 'package:lg_connection/features/home/widgets/explore_card.dart';
import 'package:lg_connection/features/home/widgets/map_sync_panel.dart';
import 'package:lg_connection/features/home/widgets/quick_action_card.dart';
import 'package:lg_connection/features/home/widgets/visualization_action_card.dart';
import 'package:lg_connection/main.dart';
import 'package:lg_connection/services/tts/tts_service.dart';
import 'package:lg_connection/services/tts/widgets/tts_playback_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(aiRepository);
  }

  @override
  void dispose() {
    TtsService.instance.stop();
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

  void _showAiLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(
              child: Text('Generating climate explanation...'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showClimatePopup(String title, String text) async {
    if (!mounted) return;

    if (TtsService.instance.autoNarrate && text.trim().isNotEmpty) {
      TtsService.instance.speak(text);
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          maxChildSize: 0.85,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                TtsPlaybackBar(text: text),
                const SizedBox(height: 16),
                MarkdownBody(
                  data: text,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                      .copyWith(
                    h3: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.85),
                          height: 1.65,
                        ),
                    listBullet: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.85),
                        ),
                    blockSpacing: 8,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    await TtsService.instance.stop();
  }

  Future<void> _handleVisualization(
      String title, Future<void> Function() action) async {
    try {
      await TtsService.instance.stop();
      await action();
      _showFeedback('$title sent to Liquid Galaxy', true);

      _showAiLoading();
      final text = await _viewModel.getClimateExplanation(title);
      if (mounted) Navigator.of(context).pop();

      await _showClimatePopup(title, text);
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.of(context).pop();
      _showFeedback('Could not send $title KML', false);
    }
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
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ValueListenableBuilder<bool>(
                            valueListenable: _viewModel.isConnected,
                            builder: (context, connected, _) =>
                                StatusBadge(isConnected: connected),
                          ),
                          const ChatbotEntryButton(),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Liquid Galaxy',
                        style: textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        'Climate View',
                        style: textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose a visualization and project it directly to the rig.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                      const SizedBox(height: 24),

                      VisualizationActionCard(
                        title: 'Indian Monsoon',
                        description: 'Loads the pre-generated KML and overwrites master.kml on Liquid Galaxy.',
                        icon: Icons.water_drop_outlined,
                        climateName: 'Indian Monsoon',
                        isLoading: _viewModel.isVisualisingMonsoon,
                        isEnabled: !_viewModel.isAnyVisualising || _viewModel.isVisualisingMonsoon,
                        onTap: () => _handleVisualization('Indian Monsoon', _viewModel.visualizeIndianMonsoon),
                      ),
                      const SizedBox(height: 12),
                      VisualizationActionCard(
                        title: 'Kuroshio Current',
                        description: 'Loads the pre-generated Kuroshio KML and overwrites master.kml.',
                        icon: Icons.waves_outlined,
                        climateName: 'Kuroshio Current',
                        isLoading: _viewModel.isVisualisingKuroshio,
                        isEnabled: !_viewModel.isAnyVisualising || _viewModel.isVisualisingKuroshio,
                        onTap: () => _handleVisualization('Kuroshio Current', _viewModel.visualizeKuroshioCurrent),
                      ),
                      const SizedBox(height: 12),
                      VisualizationActionCard(
                        title: 'Gulf Stream',
                        description: 'Loads the pre-generated Gulf Stream KML and overwrites master.kml.',
                        icon: Icons.air_outlined,
                        climateName: 'Gulf Stream',
                        isLoading: _viewModel.isVisualisingGulfStream,
                        isEnabled: !_viewModel.isAnyVisualising || _viewModel.isVisualisingGulfStream,
                        onTap: () => _handleVisualization('Gulf Stream', _viewModel.visualizeGulfStream),
                      ),
                      const SizedBox(height: 12),
                      VisualizationActionCard(
                        title: 'El Niño',
                        description: 'Loads the pre-generated El Niño KML and overwrites master.kml.',
                        icon: Icons.wb_sunny_outlined,
                        climateName: 'El Niño',
                        isLoading: _viewModel.isVisualisingElNino,
                        isEnabled: !_viewModel.isAnyVisualising || _viewModel.isVisualisingElNino,
                        onTap: () => _handleVisualization('El Niño', _viewModel.visualizeElNino),
                      ),
                      const SizedBox(height: 12),
                      VisualizationActionCard(
                        title: 'La Niña',
                        description: 'Loads the pre-generated La Niña KML and overwrites master.kml.',
                        icon: Icons.cloud_outlined,
                        climateName: 'La Niña',
                        isLoading: _viewModel.isVisualisingLaNina,
                        isEnabled: !_viewModel.isAnyVisualising || _viewModel.isVisualisingLaNina,
                        onTap: () => _handleVisualization('La Niña', _viewModel.visualizeLaNina),
                      ),
                      const SizedBox(height: 12),
                      VisualizationActionCard(
                        title: 'Mumbai Monsoon',
                        description: 'Loads the pre-generated Mumbai Monsoon KML and flies to Gateway of India.',
                        icon: Icons.grain_outlined,
                        climateName: 'Mumbai Monsoon',
                        isLoading: _viewModel.isVisualisingMumbaiMonsoon,
                        isEnabled: !_viewModel.isAnyVisualising || _viewModel.isVisualisingMumbaiMonsoon,
                        onTap: () => _handleVisualization('Mumbai Monsoon', _viewModel.visualizeMumbaiMonsoon),
                      ),
                      const SizedBox(height: 12),

                      QuickActionCard(
                        label: 'Clear All Layers',
                        icon: Icons.layers_clear_outlined,
                        isDestructive: true,
                        onTap: () async {
                          await _viewModel.clearKML();
                          _showFeedback('KML cleared from Liquid Galaxy', true);
                        },
                      ),
                      const SizedBox(height: 28),

                      _buildSectionLabel(context, 'Map Sync', Icons.map_outlined),
                      const SizedBox(height: 12),
                      MapSyncPanel(
                        initialTarget: _viewModel.lastTarget,
                        initialZoom: _viewModel.lastZoom,
                      ),
                      const SizedBox(height: 12),

                      FilledButton.icon(
                        onPressed: () async {
                          await _viewModel.orbit();
                          _showFeedback('Orbit command sent', true);
                        },
                        icon: const Icon(Icons.rotate_90_degrees_ccw_outlined),
                        label: const Text('Orbit Current View'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                        ),
                      ),
                      const SizedBox(height: 28),

                      _buildSectionLabel(context, 'More Patterns', Icons.grid_view_outlined),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Expanded(
                            child: ExploreCard(
                              title: 'Winds',
                              icon: Icons.air,
                              climateName: 'Global Wind Systems',
                              categoryName: 'Global Wind Systems',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ExploreCard(
                              title: 'Currents',
                              icon: Icons.waves,
                              climateName: 'Ocean Currents',
                              categoryName: 'Ocean Currents',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurface.withValues(alpha: 0.6)),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
