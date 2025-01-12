import 'package:flutter/material.dart';
import '../models/sign_in_model.dart';
import '../services/auth_service.dart';
import 'package:get_it/get_it.dart';

final GetIt serviceLocator = GetIt.instance;

class SignInController extends ChangeNotifier {
  final SignInModel _model = SignInModel();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = serviceLocator<AuthService>();
  
  bool _isLoading = false;
  bool _isPhoneVerified = false;
  String? _error;

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
      // final token = await _authService.verifyOTP(
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