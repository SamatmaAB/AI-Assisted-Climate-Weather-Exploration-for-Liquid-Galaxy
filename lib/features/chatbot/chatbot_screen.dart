import 'package:flutter/material.dart';
import 'package:lg_connection/features/chatbot/chatbot_viewmodel.dart';
import 'package:lg_connection/features/chatbot/widgets/chat_bubble.dart';
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
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Climate AI Assistant'),
            Text(
              'Ask about Earth systems and visualizations',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _viewModel.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          );
        },
      ),
    );
  }
}
