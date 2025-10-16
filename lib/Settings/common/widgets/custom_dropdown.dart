import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final void Function(String?)? onChanged;
  final double? width;
  final double? height;
  final Color? borderColor;
  final double? borderRadius;
  final Color? bgColor;
  final TextStyle? textStyle;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.width,
    this.height,
    this.borderColor,
    this.borderRadius,
    this.bgColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);

    return Container(
      width: width ?? size.width - 38,
      height: height ?? 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        border: Border.all(color: borderColor ?? Colors.black, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          style:
              textStyle ??
              const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
          onChanged: onChanged,
          items: items
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
        ),
      ),
    );
  }
}
