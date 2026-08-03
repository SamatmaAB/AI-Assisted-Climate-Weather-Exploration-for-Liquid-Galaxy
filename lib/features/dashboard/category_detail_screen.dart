import 'package:flutter/material.dart';
import 'package:lg_connection/core/theme/climate_colors.dart';
import 'package:lg_connection/features/dashboard/dashboard_viewmodel.dart';
import 'package:lg_connection/features/dashboard/data/category_metadata_provider.dart';
import 'package:lg_connection/features/dashboard/widgets/action_item_card.dart';
import 'package:lg_connection/features/dashboard/widgets/info_card.dart';
import 'package:lg_connection/features/dashboard/widgets/specs_card.dart';
import 'package:lg_connection/main.dart';

/// Detailed view for a specific climate category.
class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;
  late final DashboardViewModel _viewModel = DashboardViewModel(aiRepository);

  CategoryDetailScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final metadata = CategoryMetadataProvider.getMetadata(categoryName);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = ClimateColors.forPhenomenon(categoryName);

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: domainColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(metadata.icon, color: domainColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metadata.subTitle,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(
                      categoryName,
                      style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            metadata.description,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),

          SpecsCard(accentColor: domainColor),
          const SizedBox(height: 16),
          InfoCard(
            title: 'DATA FEED',
            icon: Icons.cell_tower_outlined,
            color: domainColor,
            description: 'High-fidelity telemetry sourced from global observation networks.',
          ),
          const SizedBox(height: 24),

          _buildSectionHeader(context, 'AVAILABLE VISUALIZATIONS'),
          const SizedBox(height: 12),
          ..._buildCategoryActions(context, metadata),
          const SizedBox(height: 32),
        ],
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

  List<Widget> _buildCategoryActions(BuildContext context, dynamic metadata) {
    List<Widget> actions = [];
    final colorScheme = Theme.of(context).colorScheme;

    if (categoryName == 'Global Wind Systems') {
      actions.add(
        ActionItemCard(
          title: 'Visualize Indian Monsoon',
          subtitle: 'Load the pre-generated KML and project to the rig',
          icon: Icons.air_outlined,
          color: ClimateColors.monsoon,
          onTap: () => _viewModel.visualizeIndianMonsoon(),
        ),
      );
      actions.add(const SizedBox(height: 12));
      actions.add(
        ActionItemCard(
          title: 'Visualize Mumbai Monsoon',
          subtitle: 'Project Mumbai monsoon KML & fly to Gateway of India',
          icon: Icons.grain_outlined,
          color: ClimateColors.mumbaiMonsoon,
          onTap: () => _viewModel.visualizeMumbaiMonsoon(),
        ),
      );
      actions.add(const SizedBox(height: 12));
    }

    if (categoryName == 'Ocean Currents') {
      actions.add(
        ActionItemCard(
          title: 'Kuroshio Current',
          subtitle: 'Visualize the North Pacific western boundary current',
          icon: Icons.waves_outlined,
          color: ClimateColors.kuroshio,
          onTap: () => _viewModel.visualizeKuroshioCurrent(),
        ),
      );
      actions.add(const SizedBox(height: 12));
      actions.add(
        ActionItemCard(
          title: 'El Niño Pacific Conveyor',
          subtitle: 'Visualize warm ocean current anomaly in the Pacific',
          icon: Icons.wb_sunny_outlined,
          color: ClimateColors.elNino,
          onTap: () => _viewModel.visualizeElNino(),
        ),
      );
      actions.add(const SizedBox(height: 12));
      actions.add(
        ActionItemCard(
          title: 'La Niña Pacific Trade Wind',
          subtitle: 'Visualize cold upwelling anomaly in the Pacific',
          icon: Icons.cloud_outlined,
          color: ClimateColors.laNina,
          onTap: () => _viewModel.visualizeLaNina(),
        ),
      );
      actions.add(const SizedBox(height: 12));
    }

    actions.add(
      ActionItemCard(
        title: 'Project KML Layer',
        subtitle: 'Send a prepared KML layer to Liquid Galaxy',
        icon: Icons.fit_screen_outlined,
        color: colorScheme.primary,
        onTap: () {},
      ),
    );
    actions.add(const SizedBox(height: 12));

    actions.add(
      ActionItemCard(
        title: 'Fly To Region',
        subtitle: 'Move the rig camera to the tour viewpoint',
        icon: Icons.explore_outlined,
        color: colorScheme.secondary,
        onTap: () {
          if (categoryName == 'Global Wind Systems') {
            _viewModel.flyTo('<LookAt><longitude>78.9629</longitude><latitude>20.5937</latitude><altitude>0</altitude><heading>0</heading><tilt>45</tilt><range>5000000</range><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt>');
          } else if (categoryName == 'Ocean Currents') {
            _viewModel.flyTo('<LookAt><longitude>135.0</longitude><latitude>28.0</latitude><altitude>0</altitude><heading>0</heading><tilt>45</tilt><range>6000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>');
          }
        },
      ),
    );
    actions.add(const SizedBox(height: 12));

    actions.add(
      ActionItemCard(
        title: 'Clear Rig Layers',
        subtitle: 'Remove the active KML visualization',
        icon: Icons.layers_clear_outlined,
        color: colorScheme.error,
        onTap: () => _viewModel.clearKML(),
      ),
    );

    return actions;
  }
}
