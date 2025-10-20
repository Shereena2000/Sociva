import 'package:flutter/material.dart';

import '../../../../../Settings/utils/p_colors.dart';

class ChatInputBar extends StatelessWidget {
  final VoidCallback onMicTap;
  final VoidCallback? onSendTap;
  final ValueChanged<String>? onTextChanged;
  final TextEditingController? controller;

  const ChatInputBar({
    super.key,
    required this.onMicTap,
    this.onSendTap,
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
                onSubmitted: (value) {
                  if (onSendTap != null && value.trim().isNotEmpty) {
                    onSendTap!();
                  }
                },
                style: TextStyle(color: PColors.white),
                decoration: InputDecoration(
                  hintText: "Your message",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  hintStyle: TextStyle(color: Colors.grey[600]),
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
          GestureDetector(
            onTap: onSendTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: PColors.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: PColors.lightGray, width: 1),
              ),
              child: Icon(Icons.send, color: PColors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
