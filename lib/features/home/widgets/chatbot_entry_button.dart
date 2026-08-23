import 'package:flutter/material.dart';
import 'package:lg_connection/features/chatbot/chatbot_screen.dart';

class ChatbotEntryButton extends StatelessWidget {
  const ChatbotEntryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'climate_ai_chatbot_fab',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatbotScreen()),
        );
      },
      icon: const Icon(Icons.chat_bubble_rounded),
      label: const Text(
        'Climate AI',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
