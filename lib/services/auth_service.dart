import 'dart:convert';
import 'package:giftginnie_ui/api/auth_api_service.dart';
import 'package:giftginnie_ui/models/otp_verification_model.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final AuthApiService _apiService;
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  AuthService({AuthApiService? apiService})
      : _apiService = apiService ?? AuthApiService();

  // Phone Authentication
  Future<OtpVerificationModel> sendOTP(String phoneNumber) async {
    return await _apiService.sendOTP(phoneNumber);
  }

 Future<void> verifyOTP({
  required String phoneNumber,
  required String otp,
  required String verificationId,
  required String token,
}) async {
  final response = await _apiService.verifyOTP(
    phoneNumber: phoneNumber,
    otp: otp,
    verificationId: verificationId,
    token: token,
  );
  
  if (response['message'] != 'OTP verified successfully') {
    throw Exception(response['message'] ?? 'OTP verification failed');
  }

  // Save auth data
  if (response['data'] != null) {
    await _saveAuthData(
      token: response['data']['access'],
      refreshToken: response['data']['refresh'],
      userData: {}, // Add user data if available from API
    );
  }
}

  // Token Management
  Future<void> _saveAuthData({
    required String token,
    required String refreshToken,
    required Map<String, dynamic> userData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_tokenKey, token),
      prefs.setString(_refreshTokenKey, refreshToken),
      prefs.setString(_userKey, json.encode(userData)),
    ]);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr == null) return null;

    return Map<String, dynamic>.from(userStr as Map);
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;
    
    try {
      if (JwtDecoder.isExpired(token)) {
        // Token is expired, try to refresh it
        final success = await refreshToken();
        return success;
      }
      return true;
    } catch (e) {
      await logout(); // Clear invalid token
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_tokenKey),
      prefs.remove(_refreshTokenKey),
      prefs.remove(_userKey),
    ]);
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

Future<bool> refreshToken() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _apiService.refreshToken(refreshToken);
      
      if (response['access'] != null) {
        await _saveAuthData(
          token: response['access'],
          refreshToken: response['refresh'] ?? refreshToken,
          userData: {}, // Add user data if available from API
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
