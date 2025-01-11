import 'package:flutter/material.dart';

abstract class AppColors {
  // Background colors as ints
  static const int primaryBg = 0xFFED6E61;
  static const int secondaryBg = 0xFF4CAF50;
  static const int tertiaryBg = 0xFF9DFFB3;
  
  // UI Colors
  static const Color primary = Color(primaryBg);
  static const Color secondary = Color(secondaryBg);
  static const Color tertiary = Color(tertiaryBg);
  static const Color textGrey = Colors.grey;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color dotInactive = Color(0xFFE0E0E0);
  
  // Auth Screen Colors
  static const Color authBackground = Colors.black;
  static const Color authBackgroundOverlay = Color(0xC8000000); // black with 200 alpha
  static const Color authTitleText = Colors.white;
  static const Color authDescriptionText = Colors.white70;
  static const Color authSocialButtonText = Colors.black87;
  static const Color authSocialButtonBackground = Colors.white;
}