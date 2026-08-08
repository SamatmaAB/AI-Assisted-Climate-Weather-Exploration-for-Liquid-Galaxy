import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lg_connection/services/ai/ai_repository.dart';

class ChatbotViewModel extends ChangeNotifier {
  final AIRepository _aiRepository;
  final ScrollController scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();

  ChatbotViewModel(this._aiRepository);

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! I am your Earth Systems assistant. I can help you visualize climate patterns on your Liquid Galaxy rig. How can I assist you today?',
      'isUser': false,
    },
  ];

  List<Map<String, dynamic>> get messages => List.unmodifiable(_messages);

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

    await _generateAiResponse(messageText);
  }

  Future<void> _generateAiResponse(String userMessage) async {
    _isTyping = true;
    notifyListeners();
    _scrollToBottom();

    final response = await _aiRepository.ask(userMessage);

    _isTyping = false;
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
