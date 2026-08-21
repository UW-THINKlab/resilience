import 'package:flutter/material.dart';

/// Color constants used in the app
abstract class ColorConstants {
  static const Color seed = Color.fromARGB(255, 14, 54, 70);
  static const Color transparent = Color.fromARGB(0, 0, 0, 0);
  static const Color confirmGreen = Color(0xFFC8E6C9);
  static const Color tentativeLime = Color(0xFFF0F4C3); // Colors.lime[100]
  static const Color cancelGray = Color(0xFFE0E0E0); // grey[300]
  static const Color rejectedGray = Color(0xFFBDBDBD); // grey[400]
  static const Color dangerRed = Color(0xFFD32F2F);
  static const Color warningRed = Color(0xFFFFEBEE); // Colors.red[50]

  // Okabe-Ito palette — stays distinguishable under deuteranopia/protanopia/tritanopia
  static const Color cbOrange = Color(0xFFE69F00);
  static const Color cbSkyBlue = Color(0xFF56B4E9);
  static const Color cbBluishGreen = Color(0xFF009E73);
  static const Color cbYellow = Color(0xFFF0E442);
  static const Color cbBlue = Color(0xFF0072B2);
  static const Color cbVermillion = Color(0xFFD55E00);
  static const Color cbReddishPurple = Color(0xFFCC79A7);
  static const Color cbBlack = Color(0xFF000000);
}
