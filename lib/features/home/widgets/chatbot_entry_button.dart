import 'package:flutter/material.dart';
import 'package:lg_connection/features/chatbot/chatbot_screen.dart';

class ChatbotEntryButton extends StatelessWidget {
  const ChatbotEntryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatbotScreen()),
        );
      },
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_outlined, size: 16),
          SizedBox(width: 6),
          Text('Climate AI'),
        ],
      ),
    );
  }
}
