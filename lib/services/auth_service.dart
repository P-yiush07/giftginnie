import 'package:giftginnie_ui/api/auth_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final AuthApiService _apiService;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthService({AuthApiService? apiService})
      : _apiService = apiService ?? AuthApiService();

  // Phone Authentication
  Future<void> sendOTP(String phoneNumber) async {
    final response = await _apiService.sendOTP(phoneNumber);
    if (!response['success']) {
      throw Exception(response['message']);
    }
  }

  Future<void> verifyOTP(String phoneNumber, String otp) async {
    final response = await _apiService.verifyOTP(phoneNumber, otp);
    if (!response['success']) {
      throw Exception(response['message']);
    }

    // Save auth data
    await _saveAuthData(
      token: response['token'],
      userData: response['user'],
    );
  }

  // Token Management
  Future<void> _saveAuthData({
    required String token,
    required Map<String, dynamic> userData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_tokenKey, token),
      prefs.setString(_userKey, userData.toString()),
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

    // Convert string back to map
    // Note: In a real app, you might want to use json.encode/decode
    // or a proper serialization method
    return Map<String, dynamic>.from(userStr as Map);
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_tokenKey),
      prefs.remove(_userKey),
    ]);
  }

  // Refresh Token (if your API supports it)
  Future<void> refreshToken() async {
    // TODO: Implement token refresh logic
    // final response = await _apiService.refreshToken();
    // await _saveAuthData(
    //   token: response['token'],
    //   userData: response['user'],
    // );
  }
}
