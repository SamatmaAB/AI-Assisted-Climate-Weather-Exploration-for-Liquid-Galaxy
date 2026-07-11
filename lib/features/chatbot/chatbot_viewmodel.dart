import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lg_connection/shared/services/ai_service.dart';

/// Manages the state and business logic for the Climate AI Chatbot.
class ChatbotViewModel extends ChangeNotifier {
  final AIService _aiService = AIService();
  final ScrollController scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! I am your Earth Systems assistant. I can help you visualize climate patterns on your Liquid Galaxy rig. How can I assist you today?',
      'isUser': false,
    },
  ];

  List<Map<String, dynamic>> get messages => List.unmodifiable(_messages);

  /// Sends a message, triggers AI response, and handles UI auto-scrolling.
  Future<void> sendMessage({String? text}) async {
    final messageText = text ?? messageController.text.trim();
    if (messageText.isEmpty) return;

    _messages.add({
      'text': messageText,
      'isUser': true,
    });
    
    if (text == null) messageController.clear();
    notifyListeners();
    _scrollToBottom();

    // Trigger AI response
    await _generateAiResponse(messageText);
  }

  Future<void> _generateAiResponse(String userMessage) async {
    // Note: In a real app, we'd add a "typing..." indicator here.
    final response = await _aiService.ask(userMessage);

    _messages.add({
      'text': response,
      'isUser': false,
    });
    notifyListeners();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }
}
