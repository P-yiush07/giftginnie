import 'package:flutter/material.dart';
import '../models/sign_in_model.dart';
import '../services/services.dart';

class SignInController extends ChangeNotifier {
  final SignInModel _model = SignInModel();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isPhoneVerified = false;
  String? _error;

  SignInController() {
    // Add listeners to controllers
    _phoneController.addListener(_onPhoneChanged);
    _otpController.addListener(_onOtpChanged);
  }

  void _onPhoneChanged() {
    // Trigger UI update when phone number changes
    notifyListeners();
  }

  void _onOtpChanged() {
    // Trigger UI update when OTP changes
    notifyListeners();
  }

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

  String? get error => _error;

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
    _phoneController.removeListener(_onPhoneChanged);
    _otpController.removeListener(_onOtpChanged);
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> verifyPhone() async {
    if (_phoneController.text.isEmpty) return;
    
    _error = null;
    isLoading = true;

    try {
      // await _authService.sendOTP(_phoneController.text);
      isPhoneVerified = true;
    } catch (e) {
      _error = e.toString();
      isPhoneVerified = false;
    } finally {
      isLoading = false;
    }
  }

  Future<bool> handlePhoneLogin() async {
    if (_otpController.text.isEmpty) return false;
    
    _error = null;
    isLoading = true;

    try {
      // await _authService.verifyOTP(
      //   _phoneController.text, 
      //   _otpController.text
      // );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
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