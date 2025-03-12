import 'package:flutter/material.dart';
import 'package:giftginnie_ui/services/Auth/auth_service.dart';
import 'package:giftginnie_ui/views/Auth%20Screen/authHome_screen.dart';

class ProfileTabController extends ChangeNotifier {
  // Pofile-specific state management here

  final AuthService _authService = AuthService();

  void handleLogout(BuildContext context) async {
    await _authService.logout();
    notifyListeners();
    
    // Navigate to auth home screen and remove all previous routes
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthHomeScreen(),
        ),
        (route) => false, // This removes all previous routes
      );
    }
  }

  void updateProfile() {
    // Implement profile update logic
  }
}
