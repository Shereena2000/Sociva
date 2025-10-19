import 'package:flutter/material.dart';

import '../../../../../Settings/utils/p_colors.dart';

class LeftChatBubble extends StatelessWidget {
  final String message;
  final String time;

  const LeftChatBubble({
    super.key,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 100),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
           gradient: LinearGradient(
            colors: [
              Color(0xFF1A1B4B), // Deep Blue
              Color(0xFF4A148C), // Deep Purple
              Color(0xFF6A1B9A), // Purple
              Color(0xFF3949AB), // Blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.zero, // Sharp corner
            ),
          ),
          child: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(color: PColors.lightGray, fontSize: 11),
        ),
      ],
    );
  }
}
