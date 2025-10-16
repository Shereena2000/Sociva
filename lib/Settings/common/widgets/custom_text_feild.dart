
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/text_styles.dart';
import '../../utils/p_colors.dart';

class CustomTextFeild extends StatefulWidget {
  final String? textHead;
  final String hintText;
  final Color? filColor;
  final Color? hintColor;
  final Color? textColor;
  final Color? borderColor;
  final int? maxLine;
  final int? maxLength;
  final Widget? suffixIcon;
  final double? suffixIconSize;
  final double? prefixIconSize;
  final Widget? prefixIcon;
  final double? borderRadius;
  final double? contentPadVertical;
  final double? height;
  final FocusNode? focusNode;
  final Function()? sufixfn;
  final Function()? prefixfn;
  final Function()? onTap;
  final Function(String? val)? onSaved;
  final Function(String? val)? onSubmitted;
  final Function(String? val)? onChanged;
  final Iterable<String>? autofillHints;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String? val)? validation;
  final TextInputType? keyboardType;
  final bool readOnly;

  /// 🔑 New property
  final bool obscureText;

  const CustomTextFeild({
    super.key,
    this.onTap,
    this.textHead,
    required this.hintText,
    this.suffixIconSize,
    this.suffixIcon,
    this.sufixfn,
    this.onSaved,
    this.onSubmitted,
    this.onChanged,
    this.validation,
    this.keyboardType,
    this.hintColor,
    this.autofillHints,
    this.controller,
    this.filColor,
    this.prefixIcon,
    this.prefixfn,
    this.textColor,
    this.focusNode,
    this.maxLine,
    this.maxLength,
    this.contentPadVertical,
    this.inputFormatters,
    this.borderRadius,
    this.borderColor,
    this.readOnly = false,
    this.height,
    this.prefixIconSize,

    /// default = false
    this.obscureText = false,
  });

  @override
  State<CustomTextFeild> createState() => _CustomTextFeildState();
}

class _CustomTextFeildState extends State<CustomTextFeild> {
  InputDecoration inputDecoration() {
    return InputDecoration(
      prefixIcon: widget.prefixIcon != null
          ? GestureDetector(
              onTap: widget.prefixfn,
              child: Container(
                width: widget.prefixIconSize ?? 24,
                height: widget.prefixIconSize ?? 24,
                alignment: Alignment.center,
                child: IconTheme(
                  data: const IconThemeData(color: Colors.black),
                  child: widget.prefixIcon!,
                ),
              ),
            )
          : null,
      suffixIcon: widget.suffixIcon != null
          ? GestureDetector(
              onTap: widget.sufixfn,
              child: Container(
                width: widget.suffixIconSize ?? 24,
                height: widget.suffixIconSize ?? 24,
                alignment: Alignment.center,
                child: widget.suffixIcon!,
              ),
            )
          : null,
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(
        vertical: widget.contentPadVertical ?? 11,
        horizontal: 12,
      ),
      filled: true,
      fillColor: widget.filColor ?? PColors.white,
      counterText: '',
      hintText: widget.hintText,
      hintStyle: getTextStyle(
        fontSize: 13,
        color: widget.hintColor,
        fontWeight: FontWeight.w400,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          width: 1.5,
          color: widget.borderColor ?? PColors.color000000,
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          width: 1.5,
          color: widget.borderColor ?? PColors.primaryColor,
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1),
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1),
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
      ),
    );
  }

  Widget customTextFeild() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.textHead != null) textHead(),
        if (widget.textHead != null) const SizedBox(height: 7),
        Container(
          height: widget.maxLine == 1 ? (widget.height ?? 48) : null,
          child: TextFormField(
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            onFieldSubmitted: widget.onSubmitted,
            focusNode: widget.focusNode,
            autofillHints: widget.autofillHints,
            controller: widget.controller,
            validator: widget.validation,
            onChanged: widget.onChanged,
            onSaved: widget.onSaved,
            keyboardType: widget.keyboardType,
            cursorColor: Theme.of(context).colorScheme.primary,
            maxLines: widget.maxLine ?? 1,
            maxLength: widget.maxLength,

            /// 👇 add obscure here
            obscureText: widget.obscureText,

            style: getTextStyle(
              color: widget.textColor ?? PColors.color000000,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.30,
            ),
            inputFormatters: widget.inputFormatters ?? [],
            autocorrect: true,
            decoration: inputDecoration(),
          ),
        ),
      ],
    );
  }

  Widget textHead() {
    return Text(
      widget.textHead!,
      style: getTextStyle(
        fontSize: 14,
        color: PColors.color000000,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return customTextFeild();
  }
}
