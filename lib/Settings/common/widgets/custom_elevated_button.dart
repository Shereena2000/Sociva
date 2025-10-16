import 'package:flutter/material.dart';

import '../../constants/text_styles.dart';
import '../../utils/p_colors.dart';

class CustomElavatedTextButton extends StatelessWidget {
  const CustomElavatedTextButton({
    super.key,
    this.onPressed,
    required this.text,
    this.width,
    this.height,
    this.fontSize,
    this.borderRadius,
    this.textColor,
    this.icon,
    this.iconSpacing,
        this.gradientColors
  });

  final void Function()? onPressed;
  final String text;
  final double? width;
  final double? height;
  final double? fontSize;
  final double? borderRadius;
  final Color? textColor;
  final Widget? icon;
  final double? iconSpacing;
 final List<Color>? gradientColors;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);

    return Container(
      width: width ?? size.width - 40,
      height: height ?? 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ??
              [PColors.primaryColor, PColors.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        boxShadow: [
          BoxShadow(
            color: PColors.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius ?? 16),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon!,
                  SizedBox(width: iconSpacing ?? 12),
                ],
                Text(
                  text,
                  style: getTextStyle(
                    fontSize: fontSize ?? 18,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
