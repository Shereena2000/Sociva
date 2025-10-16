import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle getTextStyle({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
  TextDecoration? decoration,
}) {
  return GoogleFonts.getFont(
    'Poppins',
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    height: height,
    decoration: decoration,
  );
}

TextStyle getTextisLandMonents({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
  TextDecoration? decoration,
}) {
  return GoogleFonts.getFont(
    'Island Moments',
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    height: height,
    decoration: decoration,
  );
}
