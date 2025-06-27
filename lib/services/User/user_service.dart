import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/api.dart';
import '../../models/address_model.dart';
import '../../models/user_profile_model.dart';
import '../Cache/cache_service.dart';

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
      // Get the auth token for the cookie header
      final accessToken = await _cacheService.getString(_accessTokenKey);
      if (accessToken == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }
      
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiEndpoints.addresses}',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Cookie': 'token=$accessToken',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      debugPrint('Address response: ${response.data}');

      if (response.statusCode == 200 && response.data['addresses'] != null) {
        final List<dynamic> addressesJson = response.data['addresses'];
        return addressesJson
            .map((json) => AddressModel.fromJson(json))
            .toList();
      }
      
      // If addresses key is missing or empty, return an empty list
      if (response.statusCode == 200) {
        return [];
      }
      
      throw Exception(response.data['message'] ?? 'Failed to fetch addresses');
    } on DioException catch (e) {
      debugPrint('Error fetching user addresses: $e');
      throw Exception('Failed to load addresses. Please try again.');
    }
  }

  Future<UserProfileModel> getUserProfile() async {
    try {
      // Get user ID from cached user data
      final userData = await _cacheService.userData;
      if (userData == null || userData['user_id'] == null) {
        throw Exception('User ID not found. Please log in again.');
      }
      
      final userId = userData['user_id'];
      debugPrint('Fetching profile for user ID: $userId');

      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiEndpoints.userProfile(userId)}',
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        debugPrint('Profile response: ${response.data}');
        return UserProfileModel.fromJson(response.data['data']);
      }
      
      throw Exception(response.data['message'] ?? 'Failed to fetch profile');
    } on DioException catch (e) {
      debugPrint('Error fetching user profile: $e');
      throw Exception('Failed to load profile. Please try again.');
    } catch (e) {
      debugPrint('Error parsing user profile: $e');
      throw Exception('Failed to process profile data. Please try again.');
    }
  }

  Future<UserProfileModel> updateUserProfile({
    String? email,
    required String fullName,
    required String phoneNumber,
    required String countryCode,
    String? gender,
    required bool isWholesaleCustomer,
  }) async {
    try {
      // Use the exact field names required by the API
      final Map<String, dynamic> data = {
        'name': fullName,
        'phone': phoneNumber,
      };
      
      // Using new update endpoint with PUT method
      debugPrint('Updating user profile with data: $data');
      
      // Get the auth token for the cookie header
      final accessToken = await _cacheService.getString(_accessTokenKey);
      if (accessToken == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }
      
      final response = await _dio.put(
        '${ApiConstants.baseUrl}${ApiEndpoints.updateUser}',
        data: data,  // Sending as JSON rather than FormData
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Cookie': 'token=$accessToken',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      debugPrint('Update profile response status: ${response.statusCode}');
      debugPrint('Update profile response data: ${response.data}');
      
      if (response.statusCode == 200) {
        try {
          debugPrint('Parsing user profile from response data: ${response.data['data']}');
          return UserProfileModel.fromJson(response.data['data']);
        } catch (parseError) {
          debugPrint('Error parsing user profile: $parseError');
          debugPrint('Response data structure: ${response.data}');
          throw Exception('Failed to parse updated profile data: $parseError');
        }
      }
      
      throw Exception(response.data['message'] ?? 'Failed to update profile. Status: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('DioException updating user profile: $e');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');
      
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Failed to update profile. Please try again.');
    } catch (e) {
      debugPrint('General error updating user profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<AddressModel> addAddress({
    required String fullName,
    required String addressLine1,
    required String addressLine2,
    required String city,
    required String state,
    required String pincode,
    required String phone,
    bool isDefault = false,
    // Keeping this parameter for backward compatibility but not using it
    String? addressType,
  }) async {
    try {
      // Get the auth token for the cookie header
      final accessToken = await _cacheService.getString(_accessTokenKey);
      if (accessToken == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }
      
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiEndpoints.addresses}',
        data: {
          'fullName': fullName,
          'addressLine1': addressLine1,
          'addressLine2': addressLine2,
          'city': city,
          'state': state,
          'country': 'India',
          'zipCode': pincode,
          'phone': phone,
          'isDefault': isDefault
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Cookie': 'token=$accessToken',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      debugPrint('Add address response: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.data['data'] != null) {
          return AddressModel.fromJson(response.data['data']);
        }
        throw Exception('Invalid response format');
      }
      
      throw Exception(response.data['message'] ?? 'Failed to add address');
    } on DioException catch (e) {
      debugPrint('Error adding address: $e');
      throw Exception('Failed to add address. Please try again.');
    }
  }

  Future<AddressModel> updateAddress({
    required String addressId,
    required String fullName,
    required String addressLine1,
    required String addressLine2,
    required String city,
    required String state,
    required String pincode,
    required String phone,
    bool isDefault = false,
    String? addressType, // Keeping for backward compatibility
  }) async {
    try {
      // Get the auth token for the cookie header
      final accessToken = await _cacheService.getString(_accessTokenKey);
      if (accessToken == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }
      
      final response = await _dio.put(
        '${ApiConstants.baseUrl}${ApiEndpoints.addresses}/$addressId',
        data: {
          'fullName': fullName,
          'addressLine1': addressLine1,
          'addressLine2': addressLine2,
          'city': city,
          'state': state,
          'country': 'India',
          'zipCode': pincode,
          'phone': phone,
          'isDefault': isDefault,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Cookie': 'token=$accessToken',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      debugPrint('Update address response: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data['data'] != null) {
          return AddressModel.fromJson(response.data['data']);
        }
        throw Exception('Invalid response format');
      }
      
      throw Exception(response.data['message'] ?? 'Failed to update address');
    } on DioException catch (e) {
      debugPrint('Error updating address: $e');
      throw Exception('Failed to update address. Please try again.');
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      // Get the auth token for the cookie header
      final accessToken = await _cacheService.getString(_accessTokenKey);
      if (accessToken == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }
      
      final response = await _dio.delete(
        '${ApiConstants.baseUrl}/address/$addressId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Cookie': 'token=$accessToken',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      debugPrint('Delete address response: ${response.data}');
      
      // Consider both 200 and 204 as success status codes for deletion
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(response.data?['message'] ?? 'Failed to delete address');
      }
    } on DioException catch (e) {
      debugPrint('Error deleting address: $e');
      // Check if the error response has a 200 status (some APIs return 200 even for errors)
      if (e.response?.statusCode == 200 || e.response?.statusCode == 204) {
        return;
      }
      throw Exception('Failed to delete address. Please try again.');
    }
  }
}