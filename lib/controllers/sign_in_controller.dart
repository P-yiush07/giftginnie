import 'package:flutter/material.dart';
import '../models/sign_in_model.dart';

class SignInController extends ChangeNotifier {
  final SignInModel model = SignInModel();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  bool isPhoneVerified = false;

  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  Future<void> verifyPhone() async {
    if (phoneController.text.isEmpty) return;
    
    isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement phone verification logic
      await Future.delayed(const Duration(seconds: 2)); // Simulated delay
      isPhoneVerified = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handlePhoneLogin() async {
    if (otpController.text.isEmpty) return;
    
    isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement OTP verification logic
      await Future.delayed(const Duration(seconds: 2)); // Simulated delay
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleFacebookLogin() async {
    // TODO: Implement Facebook login
  }

  Future<void> handleGoogleLogin() async {
    // TODO: Implement Google login
  }

  Future<void> resendOTP() async {
    // TODO: Implement OTP resend logic
  }

  void backToPhoneInput() {
    isPhoneVerified = false;
    notifyListeners();
  }

  String get formattedPhone {
    if (phoneController.text.isEmpty) return '';
    return '+91 ${phoneController.text}';
  }
}