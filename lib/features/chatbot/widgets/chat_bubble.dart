import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:lg_connection/services/tts/tts_service.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final bg = isUser ? colorScheme.primaryContainer : const Color(0xFF262A34);
    final fg = isUser ? colorScheme.onPrimaryContainer : colorScheme.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: isUser
                  ? Text(
                      text,
                      style: textTheme.bodyMedium?.copyWith(
                        color: fg,
                        height: 1.45,
                      ),
                    )
                  : MarkdownBody(
                      data: text,
                      styleSheet:
                          MarkdownStyleSheet.fromTheme(Theme.of(context))
                              .copyWith(
                        p: textTheme.bodyMedium?.copyWith(
                          color: fg,
                          height: 1.5,
                        ),
                        h3: textTheme.titleSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        h2: textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        listBullet: textTheme.bodyMedium?.copyWith(
                          color: fg,
                          height: 1.45,
                        ),
                        blockSpacing: 6,
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment:
                  isUser ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isUser ? 'You' : 'Climate AI',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                if (!isUser)
                  ListenableBuilder(
                    listenable: TtsService.instance,
                    builder: (context, _) {
                      final isSpeakingThis =
                          TtsService.instance.isSpeakingText(text);
                      return InkWell(
                        onTap: () {
                          if (isSpeakingThis) {
                            TtsService.instance.stop();
                          } else {
                            TtsService.instance.speak(text);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSpeakingThis
                                    ? Icons.volume_up
                                    : Icons.volume_up_outlined,
                                size: 14,
                                color: isSpeakingThis
                                    ? colorScheme.primary
                                    : colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isSpeakingThis ? 'Stop' : 'Read aloud',
                                style: textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  color: isSpeakingThis
                                      ? colorScheme.primary
                                      : colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                  fontWeight: isSpeakingThis
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
