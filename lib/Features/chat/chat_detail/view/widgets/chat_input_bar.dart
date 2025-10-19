import 'package:flutter/material.dart';

import '../../../../../Settings/utils/p_colors.dart';
import 'voice_record.dart';

class ChatInputBar extends StatelessWidget {
  final VoidCallback onMicTap;
  final ValueChanged<String>? onTextChanged;
  final TextEditingController? controller;

  const ChatInputBar({
    super.key,
    required this.onMicTap,
    this.onTextChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: PColors.darkGray,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: controller,
                onChanged: onTextChanged,
                decoration: InputDecoration(
                  hintText: "Your message",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  hintStyle: TextStyle(color: PColors.white),
                  suffixIcon: Icon(
                    Icons.camera_alt_outlined,
                    color: PColors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          VoiceRecord(
            iconSize: 25,
            color: PColors.primaryColor,
         
            onTap: onMicTap,
            borderColor: PColors.lightGray,
          ),
        ],
      ),
    );
  }
}
