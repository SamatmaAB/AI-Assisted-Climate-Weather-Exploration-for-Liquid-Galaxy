import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/core/theme/app_colors.dart';
import 'package:lg_connection/features/dashboard/dashboard_viewmodel.dart';
import 'package:lg_connection/features/dashboard/data/category_metadata_provider.dart';
import 'package:lg_connection/features/dashboard/widgets/action_item_card.dart';
import 'package:lg_connection/features/dashboard/widgets/info_card.dart';
import 'package:lg_connection/features/dashboard/widgets/specs_card.dart';

/// A detailed screen for a specific climate category, providing visualizations and data info.
class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;
  final DashboardViewModel _viewModel = DashboardViewModel();

  CategoryDetailScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final metadata = CategoryMetadataProvider.getMetadata(categoryName);

    return Scaffold(
      backgroundColor: AppColors.slate950,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 32),
                  _buildHeader(metadata),
                  const SizedBox(height: 16),
                  _buildDescription(metadata.description),
                  const SizedBox(height: 36),
                  SpecsCard(accentColor: metadata.themeColor),
                  const SizedBox(height: 24),
                  InfoCard(
                    title: 'DATA FEED',
                    icon: CupertinoIcons.antenna_radiowaves_left_right,
                    color: metadata.themeColor,
                    description: 'High-fidelity telemetry sourced from global observation networks.',
                  ),
                  const SizedBox(height: 20),
                  ..._buildCategoryActions(metadata),
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          _buildCircleButton(
            icon: CupertinoIcons.chevron_left,
            onTap: () => Navigator.of(context).pop(),
            borderColor: AppColors.cyanWhite.withOpacity(0.1),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic metadata) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: metadata.themeColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: metadata.themeColor.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: metadata.themeColor.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Icon(metadata.icon, color: metadata.themeColor, size: 34),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metadata.subTitle,
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                categoryName,
                style: GoogleFonts.outfit(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(String description) {
    return Text(
      description,
      style: GoogleFonts.outfit(
        color: Colors.white.withOpacity(0.7),
        fontSize: 16,
        fontWeight: FontWeight.w300,
        height: 1.6,
      ),
    );
  }

  List<Widget> _buildCategoryActions(dynamic metadata) {
    List<Widget> actions = [];

    if (categoryName == 'Global Wind Systems') {
      actions.add(
        ActionItemCard(
          title: 'Visualize Indian Monsoon',
          subtitle: 'Load the ready KML and project it to the rig',
          icon: CupertinoIcons.wind,
          color: Colors.orange,
          onTap: () => _viewModel.visualizeIndianMonsoon(),
        ),
      );
      actions.add(const SizedBox(height: 14));
      actions.add(
        ActionItemCard(
          title: 'Visualize Mumbai Monsoon',
          subtitle: 'Project Mumbai monsoon KML & fly to Gateway of India',
          icon: CupertinoIcons.cloud_heavyrain,
          color: AppColors.neonGreen,
          onTap: () => _viewModel.visualizeMumbaiMonsoon(),
        ),
      );
      actions.add(const SizedBox(height: 14));
    }

    if (categoryName == 'Ocean Currents') {
      actions.add(
        ActionItemCard(
          title: 'Kuroshio current',
          subtitle: 'Visualize the North Pacific western boundary current',
          icon: CupertinoIcons.waveform,
          color: AppColors.goldAccent,
          onTap: () => _viewModel.visualizeKuroshioCurrent(),
        ),
      );
      actions.add(const SizedBox(height: 14));
      actions.add(
        ActionItemCard(
          title: 'El Niño Pacific Conveyor',
          subtitle: 'Visualize warm ocean current anomaly in the Pacific',
          icon: CupertinoIcons.sun_max,
          color: AppColors.goldAccent,
          onTap: () => _viewModel.visualizeElNino(),
        ),
      );
      actions.add(const SizedBox(height: 14));
      actions.add(
        ActionItemCard(
          title: 'La Niña Pacific Trade Wind',
          subtitle: 'Visualize cold upwelling anomaly in the Pacific',
          icon: CupertinoIcons.wind,
          color: AppColors.cyanWhite,
          onTap: () => _viewModel.visualizeLaNina(),
        ),
      );
      actions.add(const SizedBox(height: 14));
    }

    actions.add(
      ActionItemCard(
        title: 'Project KML Layer',
        subtitle: 'Send a prepared KML layer to Liquid Galaxy',
        icon: CupertinoIcons.device_desktop,
        color: AppColors.electricBlue,
        onTap: () {},
      ),
    );
    actions.add(const SizedBox(height: 14));

    actions.add(
      ActionItemCard(
        title: 'Fly To Region',
        subtitle: 'Move the rig camera to the tour viewpoint',
        icon: CupertinoIcons.location_north_fill,
        color: AppColors.neonGreen,
        onTap: () {
          if (categoryName == 'Global Wind Systems') {
            _viewModel.flyTo('<LookAt><longitude>78.9629</longitude><latitude>20.5937</latitude><altitude>0</altitude><heading>0</heading><tilt>45</tilt><range>5000000</range><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt>');
          } else if (categoryName == 'Ocean Currents') {
            _viewModel.flyTo('<LookAt><longitude>135.0</longitude><latitude>35.0</latitude><altitude>0</altitude><heading>0</heading><tilt>30</tilt><range>4000000</range><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt>');
          }
        },
      ),
    );
    actions.add(const SizedBox(height: 14));

    actions.add(
      ActionItemCard(
        title: 'Clear Rig Layers',
        subtitle: 'Remove the active KML visualization',
        icon: CupertinoIcons.trash,
        color: AppColors.criticalRed,
        onTap: () => _viewModel.clearKML(),
      ),
    );

    return actions;
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          shape: BoxShape.circle,
          border: Border.all(color: borderColor),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
      ),
    );
  }
}
