import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api.dart';
import '../models/address_model.dart';
import '../models/user_profile_model.dart';
import 'cache_service.dart';

class UserService {
  final Dio _dio;
  final CacheService _cacheService = CacheService();
  static const String _accessTokenKey = 'auth_token';

  UserService() : _dio = Dio() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await _cacheService.getString(_accessTokenKey);
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<List<AddressModel>> getUserAddresses() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiEndpoints.userAddresses}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> addressesJson = response.data['data'];
        return addressesJson
            .map((json) => AddressModel.fromJson(json))
            .toList();
      }
      
      throw Exception(response.data['message'] ?? 'Failed to fetch addresses');
    } on DioException catch (e) {
      debugPrint('Error fetching user addresses: $e');
      throw Exception('Failed to load addresses. Please try again.');
    }
  }

  Future<UserProfileModel> getUserProfile() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiEndpoints.userProfile}',
      );

      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(response.data['data']);
      }
      
      throw Exception(response.data['message'] ?? 'Failed to fetch profile');
    } on DioException catch (e) {
      debugPrint('Error fetching user profile: $e');
      throw Exception('Failed to load profile. Please try again.');
    }
  }

  Future<UserProfileModel> updateUserProfile({
    required String email,
    required String fullName,
    required String phoneNumber,
    required String countryCode,
    required String gender,
    required bool isWholesaleCustomer,
    File? imageFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'email': email,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'country_code': countryCode,
        'gender': gender,
        'is_wholesale_customer': isWholesaleCustomer,
      });

      if (imageFile != null) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(imageFile.path),
          ),
        );
      }

      final response = await _dio.patch(
        '${ApiConstants.baseUrl}${ApiEndpoints.updateUserProfile}',
        data: formData,
      );

      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(response.data['data']);
      }
      
      throw Exception(response.data['message'] ?? 'Failed to update profile');
    } on DioException catch (e) {
      debugPrint('Error updating user profile: $e');
      throw Exception('Failed to update profile. Please try again.');
    }
  }

  Future<AddressModel> addAddress({
    required String addressLine1,
    required String addressLine2,
    required String city,
    required String state,
    required String pincode,
    required String addressType,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiEndpoints.userAddresses}',
        data: {
          'address_line_1': addressLine1,
          'address_line_2': addressLine2,
          'city': city,
          'state': state,
          'country': 'IN',
          'pincode': pincode,
          'address_type': addressType,
        },
      );

      if (response.statusCode == 201) {
        return AddressModel.fromJson(response.data['data']);
      }
      
      throw Exception(response.data['message'] ?? 'Failed to add address');
    } on DioException catch (e) {
      debugPrint('Error adding address: $e');
      throw Exception('Failed to add address. Please try again.');
    }
  }
}