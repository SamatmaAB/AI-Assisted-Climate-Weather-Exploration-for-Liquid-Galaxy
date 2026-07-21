import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/core/common_widgets/glass_card.dart';
import 'package:lg_connection/core/common_widgets/status_badge.dart';
import 'package:lg_connection/core/theme/app_colors.dart';
import 'package:lg_connection/features/home/home_viewmodel.dart';
import 'package:lg_connection/features/home/widgets/chatbot_entry_button.dart';
import 'package:lg_connection/features/home/widgets/explore_card.dart';
import 'package:lg_connection/features/home/widgets/map_sync_panel.dart';
import 'package:lg_connection/features/home/widgets/quick_action_card.dart';
import 'package:lg_connection/features/home/widgets/visualization_action_card.dart';

/// The main landing screen for Earth Systems Explorer.
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
    _viewModel = HomeViewModel();
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
        backgroundColor: isSuccess ? AppColors.electricBlue : AppColors.criticalRed,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 110, left: 20, right: 20),
      ),
    );
  }

  void _showAiLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: AppColors.slate950,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const CupertinoActivityIndicator(color: AppColors.electricBlue),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  'Generating climate explanation...',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showClimatePopup(String title, String text) async {
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate950,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          maxChildSize: 0.85,
          builder: (context, controller) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(18),
                      borderRadius: 22,
                      borderColor: Colors.white.withOpacity(0.08),
                      backgroundColor: Colors.white.withOpacity(0.03),
                      child: SingleChildScrollView(
                        controller: controller,
                        child: Text(
                          text,
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.7,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleVisualization(String title, Future<void> Function() action) async {
    try {
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
    return Scaffold(
      backgroundColor: AppColors.slate950,
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: _viewModel.isConnected,
                      builder: (context, connected, _) => StatusBadge(isConnected: connected),
                    ),
                    const ChatbotEntryButton(),
                  ],
                ),
                const SizedBox(height: 18),
                _buildHeader(),
                const SizedBox(height: 28),
                VisualizationActionCard(
                  title: 'Visualise Indian Monsoon',
                  description: 'Loads the pre-generated KML and overwrites master.kml on Liquid Galaxy.',
                  icon: CupertinoIcons.cloud_rain,
                  color: AppColors.electricBlue,
                  isLoading: _viewModel.isVisualisingMonsoon,
                  onTap: () => _handleVisualization('Indian Monsoon', _viewModel.visualizeIndianMonsoon),
                ),
                const SizedBox(height: 16),
                VisualizationActionCard(
                  title: 'Visualise Kuroshio Current',
                  description: 'Loads the pre-generated Kuroshio KML and overwrites master.kml on Liquid Galaxy.',
                  icon: CupertinoIcons.waveform,
                  color: AppColors.goldAccent,
                  isLoading: _viewModel.isVisualisingKuroshio,
                  onTap: () => _handleVisualization('Kuroshio Current', _viewModel.visualizeKuroshioCurrent),
                ),
                const SizedBox(height: 16),
                VisualizationActionCard(
                  title: 'Visualise Gulf Stream',
                  description: 'Loads the pre-generated Gulf Stream KML and overwrites master.kml on Liquid Galaxy.',
                  icon: CupertinoIcons.arrow_2_circlepath,
                  color: Colors.orange,
                  isLoading: _viewModel.isVisualisingGulfStream,
                  onTap: () => _handleVisualization('Gulf Stream', _viewModel.visualizeGulfStream),
                ),
                const SizedBox(height: 16),
                VisualizationActionCard(
                  title: 'Visualise El Niño',
                  description: 'Loads the pre-generated El Niño KML and overwrites master.kml on Liquid Galaxy.',
                  icon: CupertinoIcons.sun_max,
                  color: AppColors.goldAccent,
                  isLoading: _viewModel.isVisualisingElNino,
                  onTap: () => _handleVisualization('El Niño', _viewModel.visualizeElNino),
                ),
                const SizedBox(height: 16),
                VisualizationActionCard(
                  title: 'Visualise La Niña',
                  description: 'Loads the pre-generated La Niña KML and overwrites master.kml on Liquid Galaxy.',
                  icon: CupertinoIcons.wind,
                  color: AppColors.cyanWhite,
                  isLoading: _viewModel.isVisualisingLaNina,
                  onTap: () => _handleVisualization('La Niña', _viewModel.visualizeLaNina),
                ),
                const SizedBox(height: 16),
                VisualizationActionCard(
                  title: 'Visualise Mumbai Monsoon',
                  description: 'Loads the pre-generated Mumbai Monsoon KML and flies to Gateway of India.',
                  icon: CupertinoIcons.cloud_heavyrain,
                  color: AppColors.neonGreen,
                  isLoading: _viewModel.isVisualisingMumbaiMonsoon,
                  onTap: () => _handleVisualization('Mumbai Monsoon', _viewModel.visualizeMumbaiMonsoon),
                ),
                const SizedBox(height: 16),
                QuickActionCard(
                  label: 'Clear All Layers',
                  icon: CupertinoIcons.trash,
                  color: AppColors.criticalRed,
                  onTap: () async {
                    await _viewModel.clearKML();
                    _showFeedback('KML cleared from Liquid Galaxy', true);
                  },
                ),
                const SizedBox(height: 30),
                _buildSectionHeader('Map Sync', CupertinoIcons.map),
                const SizedBox(height: 14),
                MapSyncPanel(
                  initialTarget: _viewModel.lastTarget,
                  initialZoom: _viewModel.lastZoom,
                ),
                const SizedBox(height: 16),
                _buildOrbitButton(),
                const SizedBox(height: 30),
                _buildSectionHeader('More Patterns', CupertinoIcons.square_grid_2x2),
                const SizedBox(height: 14),
                _buildExploreRow(),
                const SizedBox(height: 140),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Liquid Galaxy',
          style: GoogleFonts.outfit(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        Text(
          'Climate View',
          style: GoogleFonts.outfit(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            color: AppColors.electricBlue,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Choose a visualization and project it directly to the rig.',
          style: GoogleFonts.outfit(
            color: Colors.white.withOpacity(0.62),
            fontSize: 15,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: 16),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.outfit(
            color: Colors.white.withOpacity(0.62),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildOrbitButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.electricBlue, AppColors.neonGreen],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricBlue.withOpacity(0.24),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 15),
        onPressed: () async {
          await _viewModel.orbit();
          _showFeedback('Orbit command sent', true);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.arrow_2_circlepath, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'Orbit Current View',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreRow() {
    return Row(
      children: const [
        Expanded(
          child: ExploreCard(
            title: 'Winds',
            icon: CupertinoIcons.wind,
            color: AppColors.electricBlue,
            categoryName: 'Global Wind Systems',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ExploreCard(
            title: 'Currents',
            icon: CupertinoIcons.waveform,
            color: AppColors.goldAccent,
            categoryName: 'Ocean Currents',
          ),
        ),
      ],
    );
  }
}
