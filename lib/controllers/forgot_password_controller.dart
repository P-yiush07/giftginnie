import 'package:flutter/material.dart';
import '../models/forgot_password_model.dart';
import '../services/Auth/auth_service.dart';

class ForgotPasswordController extends ChangeNotifier {
  final ForgotPasswordModel _model = ForgotPasswordModel();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  bool _isSuccess = false;
  String _otp = '';

  // Getters
  ForgotPasswordModel get model => _model;
  TextEditingController get emailController => _emailController;
  TextEditingController get otpController => _otpController;
  TextEditingController get newPasswordController => _newPasswordController;
  TextEditingController get confirmPasswordController => _confirmPasswordController;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSuccess => _isSuccess;

  // Setters
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void setSuccess(bool value) {
    _isSuccess = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setError('Email is required');
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setError('Please enter a valid email address');
      return false;
    }

    return true;
  }

  Future<void> sendOtp() async {
    if (!_validateEmail()) {
      return;
    }

    setError(null);
    isLoading = true;

    try {
      await _authService.forgotPasswordSendOtp(email: _emailController.text.trim());
      setSuccess(true);
    } catch (e) {
      setError('Failed to send OTP. Please try again.');
    } finally {
      isLoading = false;
    }
  }

  Future<void> verifyOtp() async {
    setError(null);
    isLoading = true;

    try {
      await _authService.verifyOtpResetPassword(
        email: _emailController.text.trim(),
        otp: _otpController.text.trim(),
      );
      _otp = _otpController.text.trim();
      setSuccess(true);
    } catch (e) {
      setError('Failed to verify OTP. Please try again.');
    } finally {
      isLoading = false;
    }
  }

  Future<void> resetPassword() async {
    setError(null);
    isLoading = true;

    try {
      await _authService.resetPassword(
        email: _emailController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
        otp: _otp,
      );
      setSuccess(true);
    } catch (e) {
      setError('Failed to reset password. Please try again.');
    } finally {
      isLoading = false;
    }
  }
}