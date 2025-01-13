import 'api_client.dart';
import '../constants/api.dart';

class AuthApiService {
  final ApiClient _client;
  
  AuthApiService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    // TODO: Replace with actual endpoint
    return _client.post(
      ApiEndpoints.sendOTP,
      data: {'phone': phoneNumber},
    );
  }

  Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otp) async {
    // TODO: Replace with actual endpoint
    return _client.post(
      ApiEndpoints.verifyOTP,
      data: {
        'phone': phoneNumber,
        'otp': otp,
      },
    );
  }
}