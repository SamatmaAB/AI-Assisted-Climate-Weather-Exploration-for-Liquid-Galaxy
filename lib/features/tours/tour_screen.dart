import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/core/common_widgets/glass_card.dart';
import 'package:lg_connection/core/theme/app_colors.dart';
import 'package:lg_connection/features/tours/tour_viewmodel.dart';

/// A screen for managing and playing planetary tours/simulations.
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
    _viewModel = TourViewModel();
    _viewModel.loadExplanation(widget.phenomenon);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate950,
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          return Container(
            color: AppColors.slate950,
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          const SizedBox(height: 32),
                          _buildTitleSection(),
                          const SizedBox(height: 32),
                          _buildStatusCard(),
                          const SizedBox(height: 32),
                          _buildSectionHeader('SIMULATION METRICS'),
                          const SizedBox(height: 16),
                          _buildMetricsGrid(),
                          const SizedBox(height: 32),
                          _buildSectionHeader('MECHANISM ANALYSIS'),
                          const SizedBox(height: 16),
                          _buildExplanatorySection(),
                          const SizedBox(height: 140),
                        ],
                      ),
                    ),
                  ],
                ),
                _buildControlBar(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Row(
          children: [
            _buildCircleButton(
              icon: CupertinoIcons.chevron_left,
              onTap: () => Navigator.of(context).pop(),
            ),
            const Spacer(),
            _buildSyncToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.phenomenon,
          style: GoogleFonts.outfit(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -1.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'PLANETARY SIMULATION',
          style: GoogleFonts.outfit(
            color: AppColors.electricBlue,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  Widget _buildSyncToggle() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonGreen.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: -2,
          ),
        ],
      ),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        borderRadius: 20,
        borderColor: AppColors.neonGreen.withOpacity(0.2),
        backgroundColor: AppColors.neonGreen.withOpacity(0.05),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'RIG SYNC',
              style: GoogleFonts.outfit(
                color: AppColors.neonGreen,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(width: 8),
            Transform.scale(
              scale: 0.7,
              child: CupertinoSwitch(
                value: _viewModel.isSynced,
                activeColor: AppColors.neonGreen,
                onChanged: _viewModel.toggleSync,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final activeColor = _viewModel.isPlaying ? AppColors.neonGreen : AppColors.electricBlue;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: activeColor.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        borderColor: AppColors.cyanWhite.withOpacity(0.1),
        backgroundColor: Colors.white.withOpacity(0.04),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: activeColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: activeColor.withOpacity(0.2)),
              ),
              child: Icon(
                _viewModel.isPlaying ? CupertinoIcons.waveform_path : CupertinoIcons.globe,
                color: activeColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _viewModel.isPlaying ? 'Tour Active' : 'System Standby',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _viewModel.isPlaying
                        ? 'Synchronizing multi-display rig...'
                        : 'Ready for planetary visualization.',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricItem(CupertinoIcons.thermometer, 'TEMP', '24.2°C'),
        _buildMetricItem(CupertinoIcons.wind, 'VELOCITY', '12m/s'),
        _buildMetricItem(CupertinoIcons.drop_fill, 'HUMIDITY', '68%'),
      ],
    );
  }

  Widget _buildMetricItem(IconData icon, String label, String value) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 20,
      borderColor: AppColors.cyanWhite.withOpacity(0.05),
      backgroundColor: Colors.white.withOpacity(0.03),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.electricBlue.withOpacity(0.6), size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.3),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanatorySection() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      borderColor: AppColors.cyanWhite.withOpacity(0.05),
      backgroundColor: Colors.white.withOpacity(0.02),
      child: _viewModel.isLoadingExplanation
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CupertinoActivityIndicator(
                  color: AppColors.electricBlue,
                  radius: 14,
                ),
              ),
            )
          : Text(
              _viewModel.explanation.isNotEmpty
                  ? _viewModel.explanation
                  : 'No explanation available.',
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.7),
                fontSize: 15,
                height: 1.6,
                fontWeight: FontWeight.w300,
              ),
            ),
    );
  }

  Widget _buildControlBar() {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.electricBlue.withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: -10,
            ),
          ],
        ),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          borderRadius: 32,
          blur: 25,
          borderColor: AppColors.cyanWhite.withOpacity(0.1),
          backgroundColor: Colors.white.withOpacity(0.05),
          child: Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  'KML LAYER',
                  CupertinoIcons.layers_fill,
                  AppColors.electricBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _buildPrimaryButton(
                  _viewModel.isPlaying ? 'TERMINATE TOUR' : 'INITIATE TOUR',
                  _viewModel.isPlaying ? CupertinoIcons.stop_fill : CupertinoIcons.play_fill,
                  _viewModel.isPlaying ? AppColors.criticalRed : AppColors.electricBlue,
                  () => _viewModel.isPlaying ? _viewModel.stopTour() : _viewModel.startTour(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
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


}
