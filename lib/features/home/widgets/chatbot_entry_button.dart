import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/core/theme/app_colors.dart';
import 'package:lg_connection/features/chatbot/chatbot_screen.dart';

/// A button that navigates to the Climate AI Chatbot screen.
class ChatbotEntryButton extends StatelessWidget {
  const ChatbotEntryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => ChatbotScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.electricBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.electricBlue.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(CupertinoIcons.sparkles, color: AppColors.electricBlue, size: 16),
            const SizedBox(width: 8),
            Text(
              'Climate AI',
              style: GoogleFonts.outfit(
                color: AppColors.electricBlue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
