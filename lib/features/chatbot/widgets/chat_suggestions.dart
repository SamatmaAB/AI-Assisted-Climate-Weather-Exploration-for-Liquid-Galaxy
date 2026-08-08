import 'package:flutter/material.dart';

class ChatSuggestions extends StatelessWidget {
  final Function(String) onSuggestionTap;

  const ChatSuggestions({
    super.key,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      'Indian Monsoon',
      'Kuroshio Current',
      'El Niño',
      'La Niña',
      'Mumbai Monsoon',
      'Clear Rig',
      'Help',
    ];

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(suggestion),
              onPressed: () => onSuggestionTap('Tell me about $suggestion'),
            ),
          );
        },
      ),
    );
  }
}
