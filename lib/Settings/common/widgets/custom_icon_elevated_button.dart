import 'package:flutter/material.dart';

import '../../constants/text_styles.dart';
import '../../utils/p_colors.dart';

class CustomIconElevatedButton extends StatelessWidget {
  const CustomIconElevatedButton({
    super.key,
    this.onPressed,
    required this.text,
    required this.icon,
    this.width,
    this.height,
    this.padverticle,
    this.padhorizondal,
    this.fontSize,
    this.bgcolor,
    this.borderRadius,
    this.textColor,
    this.borderColor,
  });

  final void Function()? onPressed;
  final String text;
  final Widget icon;

  final double? width;
  final double? height;
  final double? fontSize;
  final double? padverticle;
  final double? padhorizondal;
  final Color? bgcolor;
  final double? borderRadius;
  final Color? borderColor;

  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgcolor ?? PColors.primaryColor,
          foregroundColor: PColors.colorFFFFFF,
          padding: EdgeInsets.symmetric(
            vertical: padverticle ?? 8,
            horizontal: padhorizondal ?? 16,
          ),
          fixedSize: Size(width ?? size.width - 40, height ?? 56),
          maximumSize: Size(width ?? size.width - 40, height ?? 56),
          minimumSize: Size(width ?? size.width - 40, height ?? 56),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: borderColor ?? PColors.primaryColor),
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
        ),
        onPressed: onPressed,
        label: Text(
          text,
          textAlign: TextAlign.center,
          style: getTextStyle(
            fontSize: fontSize ?? 16,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        icon: icon,
      ),
    );
  }
}
