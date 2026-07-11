import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/core/common_widgets/glass_card.dart';
import 'package:lg_connection/core/theme/app_colors.dart';

/// A single message bubble in the chatbot conversation.
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
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: 22,
              borderColor: isUser 
                  ? AppColors.electricBlue.withOpacity(0.4) 
                  : Colors.white.withOpacity(0.08),
              backgroundColor: isUser 
                  ? AppColors.electricBlue.withOpacity(0.15) 
                  : Colors.white.withOpacity(0.04),
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
              style: GoogleFonts.outfit(
                color: Colors.white30,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
