import 'package:flutter/material.dart';
import 'package:lg_connection/services/tts/tts_service.dart';

class TtsPlaybackBar extends StatelessWidget {
  final String text;
  final bool compact;

  const TtsPlaybackBar({
    super.key,
    required this.text,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: TtsService.instance,
      builder: (context, _) {
        final tts = TtsService.instance;
        final isSpeaking = tts.isSpeakingText(text);
        final isPaused = tts.isPausedText(text);
        final isActive = tts.isTextActive(text);
        final currentWord = tts.currentWord;

        if (compact) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: text.trim().isEmpty ? null : () => tts.togglePlayPause(text),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSpeaking
                            ? Icons.pause_circle_filled
                            : (isPaused ? Icons.play_circle_fill : Icons.volume_up_outlined),
                        size: 16,
                        color: isActive
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isSpeaking ? 'Pause' : (isPaused ? 'Resume' : 'Read aloud'),
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: isActive
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => tts.stop(),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Icon(
                      Icons.stop_circle_outlined,
                      size: 16,
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ],
              if (isSpeaking && currentWord.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    currentWord,
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ],
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? colorScheme.primary.withValues(alpha: 0.4)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  isSpeaking
                      ? Icons.pause_circle_filled
                      : (isPaused ? Icons.play_circle_fill : Icons.volume_up_rounded),
                ),
                color: isActive ? colorScheme.primary : colorScheme.onSurface,
                iconSize: 22,
                tooltip: isSpeaking ? 'Pause' : (isPaused ? 'Resume' : 'Read Aloud'),
                onPressed: text.trim().isEmpty ? null : () => tts.togglePlayPause(text),
              ),
              if (isActive)
                IconButton(
                  icon: const Icon(Icons.stop_circle),
                  color: colorScheme.error,
                  iconSize: 22,
                  tooltip: 'Stop',
                  onPressed: () => tts.stop(),
                ),
              const SizedBox(width: 4),
              Text(
                isSpeaking ? 'Speaking...' : (isPaused ? 'Paused' : 'Read Aloud'),
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
              if (isSpeaking && currentWord.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    currentWord,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
