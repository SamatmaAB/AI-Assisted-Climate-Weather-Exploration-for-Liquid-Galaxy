import 'package:flutter/material.dart';
import 'package:lg_connection/features/chatbot/chatbot_viewmodel.dart';
import 'package:lg_connection/features/chatbot/widgets/chat_bubble.dart';
import 'package:lg_connection/features/chatbot/widgets/chat_input_bar.dart';
import 'package:lg_connection/features/chatbot/widgets/chat_suggestions.dart';
import 'package:lg_connection/features/chatbot/widgets/typing_indicator.dart';
import 'package:lg_connection/features/onboarding/widgets/mascot_animation.dart';
import 'package:lg_connection/main.dart';

import 'package:lg_connection/services/tts/tts_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  late ChatbotViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ChatbotViewModel(aiRepository);
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const MascotAnimation(
              assetPath: 'assets/spriteanimations/wave.webp',
              width: 36,
              height: 36,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Climate AI'),
                Text(
                  'Earth Systems Assistant',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          final messages = _viewModel.messages;
          final isTyping = _viewModel.isTyping;

          final isEmptyConversation = messages.length <= 1 && !isTyping;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _viewModel.scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  itemCount: messages.length +
                      (isTyping ? 1 : 0) +
                      (isEmptyConversation ? 1 : 0),
                  itemBuilder: (context, index) {

                    if (isEmptyConversation && index == 0) {
                      return _buildEmptyStateHeader(context, textTheme, colorScheme);
                    }

                    final adjustedIndex =
                        isEmptyConversation ? index - 1 : index;

                    if (isTyping && adjustedIndex == messages.length) {
                      return const TypingIndicator();
                    }

                    final message = messages[adjustedIndex];
                    return ChatBubble(
                      text: message['text'] as String,
                      isUser: message['isUser'] as bool,
                    );
                  },
                ),
              ),
              ChatSuggestions(
                onSuggestionTap: (text) => _viewModel.sendMessage(text: text),
              ),
              ChatInputBar(
                controller: _viewModel.messageController,
                onSend: () => _viewModel.sendMessage(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyStateHeader(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const MascotAnimation(
            assetPath: 'assets/spriteanimations/wave.webp',
            width: 140,
            height: 140,
          ),
          const SizedBox(height: 12),
          Text(
            'Hi! Ask me anything about\nEarth\'s climate systems.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
