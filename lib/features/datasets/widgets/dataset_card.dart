import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/core/common_widgets/glass_card.dart';
import 'package:lg_connection/features/datasets/models/dataset_model.dart';
import 'package:lg_connection/features/datasets/dataset_detail_screen.dart';

/// A card displaying summary information for a climate dataset.
class DatasetCard extends StatelessWidget {
  final Dataset dataset;

  const DatasetCard({super.key, required this.dataset});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: dataset.statusColor.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        borderColor: Colors.white.withOpacity(0.05),
        backgroundColor: Colors.white.withOpacity(0.03),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => DatasetDetailScreen(dataset: dataset),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    dataset.title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 16),
            _buildTagsRow(),
            const SizedBox(height: 20),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: dataset.statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        dataset.status,
        style: GoogleFonts.outfit(
          color: dataset.statusColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildTagsRow() {
    return Row(
      children: dataset.tags.map((tag) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(dataset.icon, color: Colors.white.withOpacity(0.4), size: 14),
              const SizedBox(width: 6),
              Text(
                tag,
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Last updated: Reference',
          style: GoogleFonts.outfit(
            color: Colors.white.withOpacity(0.3),
            fontSize: 13,
          ),
        ),
        Icon(
          CupertinoIcons.chevron_right,
          color: Colors.white.withOpacity(0.3),
          size: 16,
        ),
      ],
    );
  }
}
