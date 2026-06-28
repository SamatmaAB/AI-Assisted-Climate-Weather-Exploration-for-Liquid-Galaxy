import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/components/glass_card.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! I am your Earth Systems assistant. I can help you visualize climate patterns on your Liquid Galaxy rig. How can I assist you today?',
      'isUser': false,
    },
  ];

  static const _slate950 = Color(0xFF020617);
  static const _electricBlue = Color(0xFF3B82F6);
  static const _neonGreen = Color(0xFF22C55E);
  static const _deepBlue = Color(0xFF1E3A8A);

  void _sendMessage({String? text}) {
    final messageText = text ?? _messageController.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      _messages.add({
        'text': messageText,
        'isUser': true,
      });
      if (text == null) _messageController.clear();
      
      // Auto-scroll to bottom
      _scrollToBottom();
      
      // Mock response logic
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        String response = 'I am processing your request. ';
        if (messageText.toLowerCase().contains('monsoon')) {
          response = 'The Indian Monsoon is a critical weather system. I can help you project its KML visualization to the Liquid Galaxy.';
        } else if (messageText.toLowerCase().contains('current')) {
          response = 'Ocean currents like the Kuroshio Current regulate global temperatures. Would you like to see its path?';
        } else {
          response = 'I can help you explore atmospheric and oceanic data. Try asking about the Monsoon or Kuroshio Current.';
        }

        setState(() {
          _messages.add({
            'text': response,
            'isUser': false,
          });
        });
        _scrollToBottom();
      });
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _slate950,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: _electricBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container()),
            ),
          ),
          
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildChatBubble(message['text'], message['isUser']);
                  },
                ),
              ),
              _buildSuggestions(),
              _buildMessageInput(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 15, left: 10, right: 20),
          color: Colors.white.withOpacity(0.02),
          child: Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 5),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_electricBlue, _neonGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: _electricBlue.withOpacity(0.3), blurRadius: 10, spreadRadius: 2),
                  ],
                ),
                child: const Icon(CupertinoIcons.sparkles, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Climate AI',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: _neonGreen, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Live Analysis Active',
                        style: GoogleFonts.outfit(fontSize: 12, color: _neonGreen.withOpacity(0.8), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = ['Indian Monsoon', 'Kuroshio Current', 'Clear Rig', 'Help'];
    return Container(
      height: 45,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => _sendMessage(text: 'Tell me about ${suggestions[index]}'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Center(
                  child: Text(
                    suggestions[index],
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: 22,
              borderColor: isUser ? _electricBlue.withOpacity(0.4) : Colors.white.withOpacity(0.08),
              backgroundColor: isUser ? _electricBlue.withOpacity(0.15) : Colors.white.withOpacity(0.04),
              child: Text(
                text,
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isUser ? 'You' : 'AI Assistant',
              style: GoogleFonts.outfit(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).padding.bottom + 15),
      decoration: BoxDecoration(
        color: _slate950,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _messageController,
                style: GoogleFonts.outfit(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ask your climate assistant...',
                  hintStyle: GoogleFonts.outfit(color: Colors.white24, fontSize: 14),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _sendMessage(),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _electricBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: _electricBlue.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(CupertinoIcons.paperplane_fill, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
