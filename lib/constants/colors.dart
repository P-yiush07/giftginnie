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
  static const Color authSocialButtonText = Color(0xFF393E46);
  static const Color authSocialButtonBackground = Colors.white;
  

  static const Color backgroundGrey = Color(0xFFF9F9F9);
  static const Color searchBarGrey = Color(0xFF757575);
  static const Color primaryRed = Color(0xFFED6E61);
  static const Color successGreen = Color(0xFF4CD964);
  static const Color ratingAmber = Color(0xFFFFB300);
 
 
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey700 = Color(0xFF616161);
  static const Color textDarkGrey = Color(0xFF43464E);
  static const Color labelGrey = Color(0xFF393E46);
}