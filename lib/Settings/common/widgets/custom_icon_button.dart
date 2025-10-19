
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIconButton extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final Color color;
  final Color bgColor;
  final Color borderColor;
  final double iconSize;
  final VoidCallback onTap;
  final double leftPadding;

  const CustomIconButton({
    super.key,
    this.icon,
    this.svgPath,
    this.color = Colors.black,
    this.bgColor = const Color(0x1AF8A913),
    this.borderColor = const Color(0x1AF8A913),
    this.iconSize = 24,
    required this.onTap,
    this.leftPadding=4
  });

  @override
  Widget build(BuildContext context) {
    assert(
      icon != null || svgPath != null,
      'Either icon or svgPath must be provided',
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
  //         border: Border.all(color: borderColor, width: 1),
        ),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: bgColor,
          child: Padding(
            padding:  EdgeInsets.only(left: leftPadding),
            child: svgPath != null
                ? SvgPicture.asset(svgPath!, width: iconSize, height: iconSize)
                : Icon(icon, color: color, size: iconSize),
          ),
        ),
      ),
    );
  }
}
