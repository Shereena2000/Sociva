import 'package:flutter/material.dart';

class VoiceRecord extends StatelessWidget {
  final Color color;
  final Color bgColor;
  final Color borderColor;
  final double iconSize;
  final VoidCallback onTap;

  const VoiceRecord({
    super.key,
    this.color = Colors.black,
    this.bgColor = const Color(0xFF1C1E21),
    this.borderColor = const Color(0xFFE0E0E0),
    this.iconSize = 24,
    required this.onTap, 
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          Icons.mic,
          color: color,
          size: iconSize,
        ),
      ),
    );
  }
}