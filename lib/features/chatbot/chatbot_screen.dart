import 'package:flutter/material.dart';
import 'package:lg_connection/core/theme/app_colors.dart';
import 'package:lg_connection/features/chatbot/chatbot_viewmodel.dart';
import 'package:lg_connection/features/chatbot/widgets/chat_bubble.dart';
import 'package:lg_connection/features/chatbot/widgets/chat_header.dart';
import 'package:lg_connection/features/chatbot/widgets/chat_input_bar.dart';
import 'package:lg_connection/features/chatbot/widgets/chat_suggestions.dart';

/// The screen providing an AI-powered climate assistant interface.
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
    _viewModel = ChatbotViewModel();
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
          return Stack(
            children: [
              _buildBackgroundGlow(),
              Column(
                children: [
                  const ChatHeader(),
                  Expanded(
                    child: ListView.builder(
                      controller: _viewModel.scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _viewModel.messages.length,
                      itemBuilder: (context, index) {
                        final message = _viewModel.messages[index];
                        return ChatBubble(
                          text: message['text'],
                          isUser: message['isUser'],
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
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.electricBlue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
