import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/api.dart';
import '../models/email_verification_model.dart';

class EmailVerificationController extends ChangeNotifier {
  final EmailVerificationModel model = EmailVerificationModel();
  final TextEditingController otpController = TextEditingController();
  
  String? _authToken;
  String? _email;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get email => _email;

  EmailVerificationController({String? email, String? authToken}) {
    _email = email;
    _authToken = authToken;
  }

  set email(String? value) {
    _email = value;
    notifyListeners();
  }

  set authToken(String? value) {
    _authToken = value;
    notifyListeners();
  }

  String? get authToken => _authToken;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<bool> verifyEmail() async {
    if (otpController.text.isEmpty) {
      setError('Please enter the verification code');
      return false;
    }
    
    // Validate that the OTP is numeric
    if (!RegExp(r'^\d+$').hasMatch(otpController.text)) {
      setError('Verification code must only contain numbers');
      return false;
    }

    if (_authToken == null) {
      setError('Authentication error. Please try signing up again.');
      return false;
    }
    
    setError(null);
    setLoading(true);
    
    try {
      // Log the full URL we're calling for verification
      final fullUrl = '${ApiConstants.baseUrl}${ApiEndpoints.verifyEmailOTP}';
      debugPrint('Sending verification request to: $fullUrl');
      
      // Verify the URL matches the expected format
      if (fullUrl != 'https://api.giftginnie.in/api/auth/verify') {
        debugPrint('WARNING: URL may be incorrect! Expected: https://api.giftginnie.in/api/auth/verify');
      }
      
      // Convert OTP to integer as the server expects a number, not a string
      final int otpValue = int.parse(otpController.text);
      
      debugPrint('Sending OTP verification: $otpValue with token: $_authToken');
      
      // Try a different approach: use the full URL directly without baseUrl
      // This ensures we hit exactly the URL that works in Postman
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) => true, // Accept any status code to see the full response
      ));
      
      // Create the request body as a JSON string for logging
      final jsonBody = jsonEncode({'otp': otpValue});
      debugPrint('Request body: $jsonBody');
      
      // Make the request with the absolute URL
      final String directUrl = 'https://api.giftginnie.in/api/auth/verify';
      debugPrint('Making direct request to: $directUrl');
      
      // Try with explicit string JSON payload
      final String jsonPayload = '{"otp":$otpValue}';
      debugPrint('Sending raw JSON payload: $jsonPayload');
      
      final response = await dio.post(
        directUrl,
        data: jsonPayload,
        options: Options(
          contentType: 'application/json',
          headers: {
            'Authorization': 'Bearer $_authToken',
            'Cookie': 'token=$_authToken',  // Add token as a cookie
          },
        ),
      );
      
      debugPrint('Email verification response status: ${response.statusCode}');
      debugPrint('Email verification response data: ${response.data}');
      
      setLoading(false);
      
      // Log the full response for debugging
      debugPrint('Full response: ${response.toString()}');
      
      // Even with a 500 error, we might get some error details since we're accepting all status codes
      if (response.statusCode == 500) {
        debugPrint('Server returned 500 error. Full response data: ${response.data}');
        // Try to get more specific error information if available
        var errorMessage = 'Server error. Please try again later.';
        if (response.data is Map && response.data['message'] != null) {
          errorMessage = response.data['message'];
        }
        setError(errorMessage);
        return false;
      }
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Email verification successful');
        return true;
      } else {
        var errorMessage = 'Verification failed. Please try again.';
        if (response.data is Map && response.data['message'] != null) {
          errorMessage = response.data['message'];
        }
        setError(errorMessage);
        return false;
      }
    } on DioException catch (e) {
      debugPrint('Email verification error: $e');
      debugPrint('Error response: ${e.response?.data}');
      
      if (e.response != null) {
        if (e.response!.statusCode == 400) {
          setError(e.response!.data['message'] ?? 'Invalid verification code');
        } else if (e.response!.statusCode == 401) {
          setError('Authentication failed. Please try signing up again.');
        } else {
          setError('Verification failed. Please try again later.');
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
    otpController.dispose();
    super.dispose();
  }
}