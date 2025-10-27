import 'package:flutter/material.dart';

import '../constants/text_styles.dart';
import 'p_colors.dart';

class PTextStyles {
  static TextStyle get bodyMedium => getTextStyle(
    color: PColors.white,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );
   static TextStyle get bodySmall => getTextStyle(
    color: PColors.white,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  
  static TextStyle get displayMedium => getTextisLandMonents(
    color: PColors.white,
    fontSize: 30,
    fontWeight: FontWeight.w600,
  );
  static TextStyle get displaySmall => getTextisLandMonents(
    color: PColors.white,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );
  //   static TextStyle get displaylite => getTextisLandMonents(
  //   color: PColors.white,
  //   fontSize: 16,
  //   fontWeight: FontWeight.w700,
  // );
    static TextStyle get headlineLarge => getTextStyle(
    color: PColors.white,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );
    static TextStyle get headlineMedium => getTextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: PColors.white,
  );
     static TextStyle get labelMedium => getTextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: PColors.white,
  );
      static TextStyle get labelSmall => getTextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 13,
    color: PColors.black,
  );
    static TextStyle get headlineSmall => getTextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: PColors.black,
  );
     static TextStyle get labelLarge => getTextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 12,
    color: PColors.white,
  );

  // static TextStyle get displaySmall =>
  //     getTextComfortaa(fontSize: 18, fontWeight: FontWeight.bold);
  
  // static TextStyle get labelMedium => getTextStyle(
  //   fontSize: 16,
  //   fontWeight: FontWeight.w500,
  //   color: PColors.black,
  // );

  // static TextStyle get labelSmall =>
  //     getTextComfortaa(fontSize: 16, fontWeight: FontWeight.w500);

  //  static TextStyle get bodyLarge => getTextStyle(
  //   fontSize: 14,
  //   color: PColors.white,
  //   fontWeight: FontWeight.bold,
  // );

  // static TextStyle get headlineMedium => getTextStyle(
  //   fontWeight: FontWeight.w500,
  //   fontSize: 16,
  //   color: PColors.white,
  // );

  // static TextStyle get headlineSmall => getTextStyle(
  //   fontWeight: FontWeight.w500,
  //   fontSize: 15,
  //   color: PColors.white,
  // );

  //   static TextStyle get bodySmall => getTextComfortaa(
  //   fontSize: 13,
  //   color: PColors.white,
  //   fontWeight: FontWeight.w400,
  // );

}
