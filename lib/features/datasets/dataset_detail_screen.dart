import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/core/common_widgets/glass_card.dart';
import 'package:lg_connection/core/theme/app_colors.dart';
import 'package:lg_connection/features/datasets/models/dataset_model.dart';

/// Detailed view for a specific climate dataset.
class DatasetDetailScreen extends StatelessWidget {
  final Dataset dataset;

  const DatasetDetailScreen({super.key, required this.dataset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate950,
      body: Container(
        color: AppColors.slate950,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 32),
                  _buildTitleSection(),
                  const SizedBox(height: 40),
                  _buildSectionHeader('ABSTRACT'),
                  const SizedBox(height: 16),
                  _buildAbstractCard(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('VISUALIZATION CAPABILITIES'),
                  const SizedBox(height: 16),
                  ..._buildVisualizationPoints(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('SOURCE METADATA'),
                  const SizedBox(height: 16),
                  _buildSourceCard(),
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ],
        ),
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
            _buildStatusBadge(),
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
          dataset.title,
          style: GoogleFonts.outfit(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -1.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Global Research Federation Repository',
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

  Widget _buildAbstractCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      borderColor: AppColors.cyanWhite.withOpacity(0.05),
      backgroundColor: Colors.white.withOpacity(0.02),
      child: Text(
        dataset.description,
        style: GoogleFonts.outfit(
          color: Colors.white.withOpacity(0.7),
          fontSize: 16,
          height: 1.6,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  List<Widget> _buildVisualizationPoints() {
    return dataset.visualizationPoints.map((point) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        borderRadius: 20,
        borderColor: AppColors.cyanWhite.withOpacity(0.05),
        backgroundColor: Colors.white.withOpacity(0.02),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.electricBlue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                point,
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    )).toList();
  }

  Widget _buildSourceCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricBlue.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        borderColor: AppColors.electricBlue.withOpacity(0.2),
        backgroundColor: AppColors.electricBlue.withOpacity(0.05),
        onTap: () {},
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.electricBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(CupertinoIcons.link, color: AppColors.electricBlue, size: 20),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OFFICIAL REPOSITORY',
                    style: GoogleFonts.outfit(
                      color: AppColors.electricBlue,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    dataset.url,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.arrow_up_right, color: Colors.white24, size: 18),
          ],
        ),
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

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neonGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonGreen.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: AppColors.neonGreen, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            'FEDERATED',
            style: GoogleFonts.outfit(
              color: AppColors.neonGreen,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
