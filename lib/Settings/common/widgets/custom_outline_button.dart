import 'package:flutter/material.dart';

import '../../constants/text_styles.dart';
import '../../utils/p_colors.dart';

class CustomOutlineButton extends StatelessWidget {
  final String text;
  final double? width;
  final double? heigth;
  final double? borderRaduis; final double? fontSize;
  final Color? bordercolor;
  final Color? textcolor;
  final Color? forgcolor;
  final double? padverticle;
  final double? padhorizondal;
    final IconData? prefixIcon;
  final Function() onPressed;

  const CustomOutlineButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.heigth,
    this.bordercolor,
    this.forgcolor,
    this.borderRaduis,
    this.padverticle,
    this.padhorizondal, this.fontSize,
    this.prefixIcon, this.textcolor,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return ElevatedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: forgcolor ?? PColors.white,
        foregroundColor: forgcolor ?? PColors.white,
        // padding: EdgeInsets.symmetric(
        //     vertical: padverticle ?? 8, horizontal: padhorizondal ?? 16),
        fixedSize: Size(width ?? size.width - 32, heigth ?? 50),
        minimumSize: Size(width ?? size.width - 32, heigth ?? 50),
        maximumSize: Size(width ?? size.width - 32, heigth ?? 50),
        side: BorderSide(
          width: 1,
          color: bordercolor ?? PColors.primaryColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRaduis ?? 8),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (prefixIcon != null) ...[
            Icon(
              prefixIcon,
              size:  20,
              color:  PColors.black,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: getTextStyle(
              fontSize: fontSize ?? 16,
              color:textcolor?? PColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
