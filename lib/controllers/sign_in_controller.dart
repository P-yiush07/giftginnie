import 'package:flutter/material.dart';
import '../models/sign_in_model.dart';
import '../services/Auth/auth_service.dart';
import '../config/auth_config.dart';

import 'package:giftginnie_ui/views/Auth%20Screen/forgot_password_screen.dart';

class SignInController extends ChangeNotifier {
  final SignInModel _model = SignInModel();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;

  SignInController() {
    // Add listeners to controllers
    _emailController.addListener(_onInputChanged);
    _passwordController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    // Trigger UI update when inputs change
    notifyListeners();
  }

  // Getters
  SignInModel get model => _model;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get obscurePassword => _obscurePassword;

  // Setters
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _emailController.removeListener(_onInputChanged);
    _passwordController.removeListener(_onInputChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setError('Email is required');
      return false;
    }
    
    // Simple email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setError('Please enter a valid email address');
      return false;
    }
    
    return true;
  }

  bool _validatePassword() {
    if (_passwordController.text.isEmpty) {
      setError('Password is required');
      return false;
    }
    
    if (_passwordController.text.length < 6) {
      setError('Password must be at least 6 characters');
      return false;
    }
    
    return true;
  }

  Future<bool> handleEmailLogin() async {
    // Validate inputs
    if (!_validateEmail() || !_validatePassword()) {
      return false;
    }
    
    setError(null);
    isLoading = true;

    try {
      // Call login API
      final loginResult = await _authService.loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // If we got here, login was successful
      debugPrint('Login successful: $loginResult');
      return true;
    } catch (e) {
      debugPrint('Error in handleEmailLogin: $e');
      setError('Login failed. Please check your email and password.');
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

  void handleForgotPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }
}
