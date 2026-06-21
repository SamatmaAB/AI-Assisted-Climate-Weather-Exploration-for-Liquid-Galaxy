import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../state/app_state.dart';
import '../models/dataset.dart';
import '../widgets/dataset_card.dart';
import '../widgets/timeline_slider.dart';
import 'pattern_detail_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final selectedIndex = appState.selectedDatasetIndex;
    if (selectedIndex != null) {
      return PatternDetailView(phenomenon: datasetCards[selectedIndex]);
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: appState.isConnected
                                ? appState.accentGreen
                                : Colors.redAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (appState.isConnected
                                            ? appState.accentGreen
                                            : Colors.redAccent)
                                        .withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .scale(duration: 1000.ms, curve: Curves.easeInOut)
                        .then()
                        .scale(duration: 1000.ms, curve: Curves.easeInOut),
                    const SizedBox(width: 8),
                    Text(
                      appState.isConnected ? 'CONNECTED' : 'DISCONNECTED',
                      style: TextStyle(
                        color: appState.isConnected
                            ? appState.accentGreen
                            : Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Earth Systems',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: appState.textColor,
                    height: 1.1,
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: appState.isDarkMode
                        ? [const Color(0xFF60A5FA), const Color(0xFF34D399)]
                        : [const Color(0xFF2563EB), const Color(0xFF059669)],
                  ).createShader(bounds),
                  child: const Text(
                    'Explorer',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Guided Liquid Galaxy tours of climate systems and regional weather impacts',
                  style: TextStyle(
                    color: appState.textSecondaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),

          // Search Box (Mock)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: appState.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: appState.borderColor),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.search,
                    size: 20,
                    color: appState.textSecondaryColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Search a climate system or location...',
                    style: TextStyle(color: appState.textSecondaryColor),
                  ),
                  const Spacer(),
                  Icon(LucideIcons.mic, size: 20, color: appState.accentGreen),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

          // Dataset Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: datasetCards.length,
              itemBuilder: (context, index) {
                final card = datasetCards[index];
                return DatasetCard(
                  title: card.title,
                  icon: card.icon,
                  accentColor: card.accentColor,
                  onTap: () {
                    appState.selectDataset(index);
                  },
                ).animate().scale(
                  delay: (300 + (index * 100)).ms,
                  duration: 400.ms,
                  curve: Curves.easeOutBack,
                );
              },
            ),
          ),

          // Timeline
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: TimelineSlider(),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),

          // Start Guided Story Button
          Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: appState.isColorBlindMode
                          ? [Colors.blue[700]!, Colors.orange[700]!]
                          : [const Color(0xFF2563EB), const Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(
                          appState.isDarkMode ? 0.4 : 0.2,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (!appState.isConnected) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please connect to Liquid Galaxy first in Settings',
                              ),
                            ),
                          );
                          return;
                        }
                        appState.selectDataset(0);
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.play,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Start Guided Story',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 800.ms)
              .scale(duration: 400.ms, curve: Curves.easeOut),
        ],
      ),
    );
  }
}
