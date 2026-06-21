import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/dataset.dart';
import '../state/app_state.dart';
import '../services/ssh_service.dart';
import '../services/kml_service.dart';
import '../widgets/glass_card.dart';

class PatternDetailView extends StatelessWidget {
  final DatasetModel phenomenon;

  const PatternDetailView({super.key, required this.phenomenon});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final sshService = context.read<SSHService>();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: appState.clearDatasetSelection,
                  icon: const Icon(LucideIcons.arrowLeft),
                  style: IconButton.styleFrom(
                    backgroundColor: appState.cardColor,
                  ),
                ).animate().fadeIn().slideX(begin: -0.5, end: 0),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: phenomenon.accentColor.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        phenomenon.icon,
                        color: phenomenon.accentColor,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phenomenon.region,
                            style: TextStyle(
                              color: appState.textSecondaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            phenomenon.title,
                            style: TextStyle(
                              color: appState.textColor,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 18),
                Text(
                  phenomenon.description,
                  style: TextStyle(
                    color: appState.textSecondaryColor,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ).animate().fadeIn(delay: 180.ms),
                const SizedBox(height: 24),
                _PreviewPanel(
                  phenomenon: phenomenon,
                ).animate().fadeIn(delay: 260.ms).scale(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _InfoBlock(
                title: 'Tour Focus',
                icon: LucideIcons.gitBranch,
                text: phenomenon.tourFocus,
                color: phenomenon.accentColor,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 14),
              _InfoBlock(
                title: 'Regional Impact',
                icon: LucideIcons.mapPin,
                text: phenomenon.impact,
                color: Colors.orangeAccent,
              ).animate().fadeIn(delay: 350.ms),
              const SizedBox(height: 14),
              _InfoBlock(
                title: 'Narration Brief',
                icon: LucideIcons.volume2,
                text: phenomenon.narrative,
                color: Colors.purpleAccent,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 22),
              _ActionCard(
                title: 'Project KML Layer',
                subtitle:
                    'Generate Bezier-arrow KML and send it to Liquid Galaxy',
                icon: LucideIcons.cast,
                color: Colors.blueAccent,
                onTap: () => _projectLayer(context, sshService, appState),
              ).animate().fadeIn(delay: 450.ms),
              const SizedBox(height: 14),
              _ActionCard(
                title: 'Fly To Region',
                subtitle: 'Move the rig camera to the tour viewpoint',
                icon: LucideIcons.navigation,
                color: Colors.greenAccent,
                onTap: () => _flyToRegion(context, sshService, appState),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 14),
              _ActionCard(
                title: 'Clear Rig Layers',
                subtitle: 'Remove the active KML visualization',
                icon: LucideIcons.trash2,
                color: Colors.redAccent,
                onTap: () async {
                  if (!_requireConnection(context, appState)) return;
                  await sshService.clearKmls();
                },
              ).animate().fadeIn(delay: 550.ms),
              const SizedBox(height: 120),
            ]),
          ),
        ),
      ],
    );
  }

  Future<void> _projectLayer(
    BuildContext context,
    SSHService sshService,
    AppState appState,
  ) async {
    if (!_requireConnection(context, appState)) return;

    final kml = KmlService.generatePhenomenonKml(phenomenon);
    final filename = '${phenomenon.id}.kml';
    await sshService.sendKml(kml, filename: filename);
    await sshService.flyTo(
      phenomenon.latitude,
      phenomenon.longitude,
      phenomenon.range,
      phenomenon.tilt,
      phenomenon.bearing,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${phenomenon.title} layer projected')),
      );
    }
  }

  Future<void> _flyToRegion(
    BuildContext context,
    SSHService sshService,
    AppState appState,
  ) async {
    if (!_requireConnection(context, appState)) return;

    await sshService.flyTo(
      phenomenon.latitude,
      phenomenon.longitude,
      phenomenon.range,
      phenomenon.tilt,
      phenomenon.bearing,
    );
  }

  bool _requireConnection(BuildContext context, AppState appState) {
    if (appState.isConnected) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please connect to Liquid Galaxy first')),
    );
    return false;
  }
}

class _PreviewPanel extends StatelessWidget {
  final DatasetModel phenomenon;

  const _PreviewPanel({required this.phenomenon});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Container(
      height: 120, // Reduced height since arrows are gone
      width: double.infinity,
      decoration: BoxDecoration(
        color: appState.isDarkMode
            ? Colors.black.withOpacity(0.28)
            : Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: appState.borderColor),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(phenomenon.icon, color: phenomenon.accentColor, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'KML Output Preview: This will project high-fidelity Bezier arrows and climate markers onto the Liquid Galaxy rig.',
                  style: TextStyle(
                    color: appState.textSecondaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final String text;
  final Color color;

  const _InfoBlock({
    required this.title,
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      blur: 0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: appState.textSecondaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: TextStyle(
                    color: appState.textColor,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return GlassCard(
      borderRadius: 18,
      padding: EdgeInsets.zero,
      blur: 0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 23),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: appState.textColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: appState.textSecondaryColor,
                          fontSize: 12,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  color: appState.textSecondaryColor,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
