import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:giftginnie_ui/config/api.dart';
import 'package:giftginnie_ui/models/otp_verification_model.dart';
import 'package:giftginnie_ui/services/cache_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  late final Dio _dio;
  final CacheService _cacheService = CacheService();
  
  static const String _accessTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  AuthService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
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
    required String refreshToken,
    required Map<String, dynamic> userData,
  }) async {
    await _cacheService.saveString(_accessTokenKey, accessToken);
    await _cacheService.saveString(_refreshTokenKey, refreshToken);
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

  // API Methods
  Future<OtpVerificationModel> sendOTP(String phoneNumber) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.sendOTP,
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

  Future<void> verifyOTP({
    required String phoneNumber,
    required String otp,
    required String verificationId,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.verifyOTP,
        data: {
          'phone_number': phoneNumber,
          'country_code': '91',
          'otp': otp,
          'verification_id': verificationId,
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        await _saveAuthData(
          accessToken: data['access'],
          refreshToken: data['refresh'],
          userData: {
            'user_id': JwtDecoder.decode(data['access'])['user_id'],
            'phone_number': phoneNumber,
          },
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to verify OTP');
      }
    } on DioException catch (e) {
      debugPrint('Error verifying OTP: $e');
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid OTP. Please try again.');
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
}
