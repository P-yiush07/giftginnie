import 'package:giftginnie_ui/models/otp_verification_model.dart';

import 'api_client.dart';
import '../constants/api.dart';

class AuthApiService {
  final ApiClient _client;
  
  AuthApiService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<OtpVerificationModel> sendOTP(String phoneNumber) async {
    final response = await _client.post(
      ApiEndpoints.sendOTP,
      data: {
        'phone_number': phoneNumber,
        'country_code': '91',
      },
    );

    if (response['message'] == 'OTP sent successfully') {
      return OtpVerificationModel.fromJson(response['data']);
    } else {
      throw Exception('Failed to send OTP');
    }
  }

  Future<Map<String, dynamic>> verifyOTP({
    required String phoneNumber,
    required String otp,
    required String verificationId,
    required String token,
  }) async {
    final response = await _client.post(
      ApiEndpoints.verifyOTP,
      data: {
        'phone_number': phoneNumber,
        'country_code': '91',
        'otp': otp,
        'verification_id': verificationId,
        'token': token,
      },
    );

    return response;
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _client.post(
      ApiEndpoints.refreshToken,
      data: {
        'refresh': [refreshToken],
      },
    );
    return response;
  }
}