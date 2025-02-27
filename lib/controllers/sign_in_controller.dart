import 'package:flutter/material.dart';
import '../models/sign_in_model.dart';
import '../services/Auth/auth_service.dart';
import '../models/otp_verification_model.dart';
import '../config/auth_config.dart';

class SignInController extends ChangeNotifier {
  final SignInModel _model = SignInModel();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isPhoneVerified = false;
  String? _error;
  OtpVerificationModel? _verificationData;

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
      // Check if using test credentials
      if (_phoneController.text == AuthConfig.testPhoneNumber) {
        _verificationData = OtpVerificationModel(
          verificationId: 'dummy_id',
          authToken: 'dummy_token'
        );
        isPhoneVerified = true;
      } else {
        _verificationData = await _authService.sendOTP(_phoneController.text);
        isPhoneVerified = true;
      }
    } catch (e) {
      debugPrint('Error during verification: $e');
      _error = 'Please try again later.';
      isPhoneVerified = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> handlePhoneLogin() async {
    if (_otpController.text.isEmpty || _verificationData == null) return false;
    
    _error = null;
    isLoading = true;

    try {
      // Check if using test credentials
      if (_phoneController.text == AuthConfig.testPhoneNumber && 
          _otpController.text == AuthConfig.testOTP) {
        // Get dummy tokens
        final tokenResponse = await _authService.getDummyTokens();
        await _authService.saveAuthData(
          accessToken: tokenResponse['access'],
          refreshToken: tokenResponse['refresh'],
          userData: {
            'user_id': 3, // Dummy user ID
            'phone_number': _phoneController.text,
          },
        );
        return true;
      }

      // Normal OTP verification flow
      await _authService.verifyOTP(
        phoneNumber: _phoneController.text,
        otp: _otpController.text,
        verificationId: _verificationData!.verificationId,
        token: _verificationData!.authToken,
      );
      return true;
    } catch (e) {
      debugPrint('Error in handlePhoneLogin: $e');
      _error = 'Wrong OTP, please re-enter';
      _otpController.clear();
      return false;
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
    _verificationData = null;
    _otpController.clear();
    _error = null;
    notifyListeners();
  }
}