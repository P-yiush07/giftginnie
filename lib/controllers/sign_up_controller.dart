import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/api.dart';
import '../models/sign_up_model.dart';
import '../services/Auth/auth_service.dart';

class SignUpController extends ChangeNotifier {
  final SignUpModel model = SignUpModel();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
  
  bool _isLoading = false;
  String? _error;
  String? _authToken;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get authToken => _authToken;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  bool _validateInputs() {
    if (nameController.text.isEmpty) {
      setError('Please enter your name');
      return false;
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (emailController.text.isEmpty || !emailRegex.hasMatch(emailController.text)) {
      setError('Please enter a valid email address');
      return false;
    }
    
    if (phoneController.text.isEmpty || phoneController.text.length != 10) {
      setError('Please enter a valid 10-digit phone number');
      return false;
    }
    
    if (passwordController.text.isEmpty || passwordController.text.length < 8) {
      setError('Password should be at least 8 characters');
      return false;
    }
    
    return true;
  }

  Future<bool> handleSignUp() async {
    // Validate all inputs first
    if (!_validateInputs()) {
      return false;
    }
    
    setError(null);
    setLoading(true);
    
    try {
      // Prepare the request body as per the API requirements
      final Map<String, dynamic> requestBody = {
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'password': passwordController.text,
      };
      
      debugPrint('Sending registration request: ${jsonEncode(requestBody)}');
      
      // Make the API call
      final response = await _dio.post(
        ApiEndpoints.register,
        data: requestBody,
      );
      
      debugPrint('Registration response: $response');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        setLoading(false);
        
        // Check if the response contains a token for email verification
        if (response.data != null && response.data['token'] != null) {
          // Store the token for email verification
          _authToken = response.data['token'];
          return true;
        } 
        // If the API returns auth tokens in the old format, save them
        else if (response.data['data'] != null && 
            response.data['data']['access'] != null && 
            response.data['data']['refresh'] != null) {
          
          // Save authentication data using AuthService
          final authService = AuthService();
          await authService.saveAuthData(
            accessToken: response.data['data']['access'],
            refreshToken: response.data['data']['refresh'],
            userData: {
              'name': nameController.text,
              'email': emailController.text,
              'phone': phoneController.text,
            },
          );
          return true;
        } else {
          // Generic success case
          return true;
        }
      } else {
        // Handle server response errors
        setError(response.data['message'] ?? 'Registration failed. Please try again.');
        setLoading(false);
        return false;
      }
    } on DioException catch (e) {
      debugPrint('Registration error: $e');
      debugPrint('Error response: ${e.response?.data}');
      
      // Handle API errors with better error messages
      if (e.response != null) {
        if (e.response!.statusCode == 400) {
          // Specific error message from backend
          String errorMsg = e.response!.data['message'] ?? 'Validation error';
          
          // Handle field-specific errors if available
          if (e.response!.data['errors'] != null) {
            final errors = e.response!.data['errors'] as Map<String, dynamic>;
            if (errors.isNotEmpty) {
              // Use the first error message from the errors map
              errorMsg = errors.values.first[0] ?? errorMsg;
            }
          }
          
          setError(errorMsg);
        } else if (e.response!.statusCode == 409) {
          setError('Email or phone number already registered');
        } else {
          setError('Registration failed. Please try again later.');
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        setError('Connection timeout. Please check your internet connection.');
      } else {
        setError('Network error. Please check your internet connection and try again.');
      }
      
      setLoading(false);
      return false;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      setError('An unexpected error occurred. Please try again.');
      setLoading(false);
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}