import 'package:flutter/material.dart';
import '../models/sign_in_model.dart';

class SignInController extends ChangeNotifier {
  final SignInModel _model = SignInModel();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isPhoneVerified = false;

  // Getters
  SignInModel get model => _model;
  TextEditingController get phoneController => _phoneController;
  TextEditingController get otpController => _otpController;
  bool get isLoading => _isLoading;
  bool get isPhoneVerified => _isPhoneVerified;
  String get formattedPhone {
    if (_phoneController.text.isEmpty) return '';
    return '+91 ${_phoneController.text}';
  }

  // Setters
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set isPhoneVerified(bool value) {
    _isPhoneVerified = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> verifyPhone() async {
    if (_phoneController.text.isEmpty) return;
    
    isLoading = true;

    try {
      // TODO: Implement phone verification logic
      await Future.delayed(const Duration(seconds: 2)); // Simulated delay
      isPhoneVerified = true;
    } finally {
      isLoading = false;
    }
  }

  Future<void> handlePhoneLogin() async {
    if (_otpController.text.isEmpty) return;
    
    isLoading = true;

    try {
      // TODO: Implement OTP verification logic
      await Future.delayed(const Duration(seconds: 2)); // Simulated delay
    } finally {
      isLoading = false;
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
  }
}