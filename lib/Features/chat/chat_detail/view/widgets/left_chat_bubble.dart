import 'package:flutter/material.dart';

import '../../../../../Settings/utils/p_colors.dart';

class LeftChatBubble extends StatelessWidget {
  final String message;
  final String time;

  const LeftChatBubble({super.key, required this.message, required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.of(context).size.width *
                  0.75, // Max 75% of screen width
            ),
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
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              time,
              style: TextStyle(color: PColors.lightGray, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
