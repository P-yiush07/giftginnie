import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';

class CustomSnackbar extends SnackBar {
  CustomSnackbar({
    super.key,
    required String message,
    Color backgroundColor = AppColors.primaryRed,
    Duration duration = const Duration(seconds: 3),
  }) : super(
    content: Text(
      message,
      style: AppFonts.paragraph.copyWith(
        color: Colors.white,
        fontSize: 14,
      ),
    ),
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    duration: duration,
    action: SnackBarAction(
      label: 'Dismiss',
      textColor: Colors.white,
      onPressed: () {
        ScaffoldMessenger.of(
          // Using the most recent context from the navigator
          Navigator.of(
            // Getting the current context using the key
            GlobalKey<NavigatorState>().currentContext!,
          ).context,
        ).hideCurrentSnackBar();
      },
    ),
  );

  // Helper method to show the snackbar
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackbar(message: message),
    );
  }
}