import 'package:flutter/material.dart';
import 'package:giftginnie_ui/models/sign_up_model.dart';
import 'package:giftginnie_ui/services/Auth/auth_service.dart';

class SignUpController extends ChangeNotifier {
  final SignUpModel _model = SignUpModel();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isPhoneVerified = false;

  SignUpController() {
    // Add listeners to controllers
    _phoneController.addListener(_onPhoneChanged);
    _otpController.addListener(_onOtpChanged);
  }

  // Getters
  SignUpModel get model => _model;
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

  void _onPhoneChanged() {
    notifyListeners();
  }

  void _onOtpChanged() {
    notifyListeners();
  }

  Future<void> verifyPhone() async {
    if (_phoneController.text.isEmpty) return;
    
    isLoading = true;
    try {
      // Simulated API call
      await Future.delayed(const Duration(seconds: 2));
      isPhoneVerified = true;
    } finally {
      isLoading = false;
    }
  }

  Future<void> handlePhoneLogin() async {
    if (_otpController.text.isEmpty) return;
    
    isLoading = true;
    try {
      // Simulated API call
      await Future.delayed(const Duration(seconds: 2));
      // Handle successful login
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
    // Implement OTP resend logic
  }

  void backToPhoneInput() {
    isPhoneVerified = false;
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _otpController.removeListener(_onOtpChanged);
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}