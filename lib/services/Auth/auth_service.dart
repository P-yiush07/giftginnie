import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:giftginnie_ui/config/api.dart';
import 'package:giftginnie_ui/models/otp_verification_model.dart';
import 'package:giftginnie_ui/services/Cache/cache_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../config/auth_config.dart';

class AuthService {
  late final Dio _dio;
  final CacheService _cacheService = CacheService();
  
  static const String _accessTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  AuthService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds:30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final success = await refreshToken();
            if (success) {
              final token = await getToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              return handler.resolve(await _dio.fetch(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Token Management
  Future<void> _saveAuthData({
    required String accessToken,
    String? refreshToken,
    required Map<String, dynamic> userData,
  }) async {
    await _cacheService.saveString(_accessTokenKey, accessToken);
    if (refreshToken != null) {
      await _cacheService.saveString(_refreshTokenKey, refreshToken);
    }
    await _cacheService.saveAuthData(token: accessToken, userData: userData);
  }

  Future<String?> getToken() async {
    return _cacheService.getString(_accessTokenKey);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    return _cacheService.userData;
  }

  Future<void> logout() async {
    await _cacheService.clear();
  }

  Future<void> saveAuthData({
    required String accessToken,
    String? refreshToken,
    required Map<String, dynamic> userData,
  }) async {
    await _saveAuthData(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userData: userData,
    );

    await _cacheService.saveBool("isGuest", false);
    // await _cacheService.saveBool("isGuest", true);
  }

  // API Methods
  Future<OtpVerificationModel> sendOTP(String phoneNumber) async {
    if (AuthConfig.useDummyAuth) {
      // Return dummy verification data when using dummy auth
      return OtpVerificationModel(
        verificationId: 'dummy_verification_id',
        authToken: 'dummy_auth_token',
      );
    }

    try {
      final response = await _dio.post(
        ApiEndpoints.verifyEmailOTP,
        data: {
          'phone_number': phoneNumber,
          'country_code': '91',
        },
      );

      if (response.statusCode == 200) {
        return OtpVerificationModel.fromJson(response.data['data']);
      }
      
      throw Exception(response.data['message'] ?? 'Failed to send OTP');
    } on DioException catch (e) {
      debugPrint('Error sending OTP: $e');
      throw Exception('Failed to send OTP. Please try again.');
    }
  }

  Future<Map<String, dynamic>> getDummyTokens() async {
    try {
      final response = await _dio.get(ApiEndpoints.dummyToken);
      
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to get dummy tokens');
    } on DioException catch (e) {
      debugPrint('Error getting dummy tokens: $e');
      throw Exception('Failed to get dummy tokens. Please try again.');
    }
  }

  Future<void> verifyOTP({
    required String phoneNumber,
    required String otp,
    required String verificationId,
    required String token,
  }) async {
    try {
      debugPrint('Sending verification request with:');
      debugPrint('Phone: $phoneNumber');
      debugPrint('OTP: $otp');
      debugPrint('VerificationId: $verificationId');
      debugPrint('Token: $token');

      final response = await _dio.post(
        ApiEndpoints.verifyEmailOTP,
        data: {
          'phone_number': phoneNumber.toString(),
          'country_code': '91',
          'otp': otp.toString(),
          'verification_id': verificationId.toString(),
          'token': token.toString(),
        },
      );
      
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data['data'] != null) {
        await _saveAuthData(
          accessToken: response.data['data']['access'],
          refreshToken: response.data['data']['refresh'],
          userData: {
            'user_id': JwtDecoder.decode(response.data['data']['access'])['user_id'],
            'phone_number': phoneNumber,
          },
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to verify OTP');
      }
    } on DioException catch (e) {
      debugPrint('Error in auth process: $e');
      debugPrint('Error response: ${e.response?.data}');
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['message'] ?? 'Invalid OTP. Please try again.');
      }
      throw Exception('Failed to verify OTP. Please try again.');
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;
    
    try {
      if (JwtDecoder.isExpired(token)) {
        return await refreshToken();
      }
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _cacheService.getString(_refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh': refreshToken},
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        await _saveAuthData(
          accessToken: data['access'],
          refreshToken: data['refresh'] ?? refreshToken,
          userData: await getUserData() ?? {},
        );
        return true;
      }
      return false;
    } catch (e) {
      await logout();
      return false;
    }
  }
  
  // Email login method
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('Logging in with email: $email');
      
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      debugPrint('Login response status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        debugPrint('Login successful, data: $data');
        
        final userData = data['data'];
        final token = data['token'];
        
        // Save the user data and token
        await _saveAuthData(
          accessToken: token,
          // We don't have refresh token in this API
          userData: {
            'user_id': userData['_id'],
            'phone': userData['phone'],
            'name': userData['name'],
            'email': userData['email'],
          },
        );
        
        return data;
      } else {
        debugPrint('Login failed with status: ${response.statusCode}');
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      debugPrint('DioException in login: $e');
      debugPrint('Error response: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['message'] ?? 'Invalid login credentials');
      } else {
        throw Exception('Login failed. Please try again later.');
      }
    } catch (e) {
      debugPrint('Unexpected error in login: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> forgotPasswordSendOtp({required String email}) async {
    try {
      await _dio.post(
        ApiEndpoints.forgotPasswordSendOtp,
        data: {'email': email},
      );
    } on DioException catch (e) {
      debugPrint('Error sending password reset email: $e');
      throw Exception('Failed to send password reset email. Please try again.');
    }
  }

  Future<void> verifyOtpResetPassword({required String email, required String otp}) async {
    try {
      await _dio.post(
        ApiEndpoints.verifyOtpResetPassword,
        data: {'email': email, 'otp': otp},
      );
    } on DioException catch (e) {
      debugPrint('Error verifying OTP: $e');
      throw Exception('Failed to verify OTP. Please try again.');
    }
  }

  Future<void> resetPassword({required String email, required String newPassword, required String otp}) async {
    try {
      await _dio.post(
        ApiEndpoints.resetPassword,
        data: {'email': email, 'newPassword': newPassword, 'otp': otp},
      );
    } on DioException catch (e) {
      debugPrint('Error resetting password: $e');
      throw Exception('Failed to reset password. Please try again.');
    }
  }
}
