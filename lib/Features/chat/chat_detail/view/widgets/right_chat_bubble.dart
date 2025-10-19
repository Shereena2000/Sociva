import 'package:flutter/material.dart';

import '../../../../../Settings/utils/p_colors.dart';

class RightChatBubble extends StatelessWidget {
  final String message;
  final String time;

  const RightChatBubble({
    super.key,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 100),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
               Color(0xFF1A1B4B),
                Color(0xFF4A148C), 
                Color(0xFF6A1B9A), 
               Color(0xFF3949AB), // Blue

             
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.zero, // Sharp corner
            ),
        
          ),
          child: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              time,
                        style: TextStyle(color: PColors.lightGray, fontSize: 11),
            ),
            const SizedBox(width: 4),
            Icon(Icons.done_all, size: 16, color:PColors.primaryColor),
          ],
        ),
      ],
    );
  }
}
