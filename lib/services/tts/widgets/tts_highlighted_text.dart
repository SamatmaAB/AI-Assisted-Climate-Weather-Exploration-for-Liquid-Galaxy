import 'package:flutter/material.dart';
import 'package:lg_connection/services/tts/tts_service.dart';

class TtsHighlightedText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const TtsHighlightedText({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final defaultStyle = style ?? textTheme.bodyMedium ?? const TextStyle();

    return ListenableBuilder(
      listenable: TtsService.instance,
      builder: (context, _) {
        final tts = TtsService.instance;
        final isSpeaking = tts.isSpeakingText(text);
        final word = tts.currentWord.trim();

        if (!isSpeaking || word.isEmpty) {
          return Text(text, style: defaultStyle);
        }

        final lowerText = text.toLowerCase();
        final lowerWord = word.toLowerCase();
        final matchIndex = lowerText.indexOf(lowerWord);

        if (matchIndex == -1) {
          return Text(text, style: defaultStyle);
        }

        final before = text.substring(0, matchIndex);
        final matched = text.substring(matchIndex, matchIndex + word.length);
        final after = text.substring(matchIndex + word.length);

        return Text.rich(
          TextSpan(
            children: [
              TextSpan(text: before, style: defaultStyle),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    matched,
                    style: defaultStyle.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              TextSpan(text: after, style: defaultStyle),
            ],
          ),
        );
      },
    );
  }
}
