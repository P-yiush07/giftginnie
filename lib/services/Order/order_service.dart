import 'dart:convert';
import 'package:giftginnie_ui/config/api.dart';
import 'package:giftginnie_ui/services/Cache/cache_service.dart';

import '../../models/orders_model.dart';
import '../../constants/orders.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class OrderService {
  final Dio _dio;
  final CacheService _cacheService = CacheService();
  static const String _accessTokenKey = 'auth_token';

  OrderService() : _dio = Dio() {
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

  Future<List<OrderModel>> getOrders() async {
    try {
      // Get auth token for the cookie
      final accessToken = await _cacheService.getString(_accessTokenKey);
      if (accessToken == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }

      debugPrint('Fetching orders from: https://api.giftginnie.in/api/order/user');
      
      final response = await _dio.post(
        'https://api.giftginnie.in/api/order/user',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Cookie': 'token=$accessToken',
            'Authorization': 'Bearer $accessToken',
          },
          extra: {
            'withCredentials': true,
          }
        ),
      );

      debugPrint('Orders API response status: ${response.statusCode}');
      debugPrint('Orders API response data: ${response.data}');

      if (response.statusCode == 200) {
        // Handle different response structures
        final dynamic responseData = response.data;
        debugPrint('Response data type: ${responseData.runtimeType}');
        debugPrint('Response data content: $responseData');
        
        List<dynamic> ordersData;
        
        if (responseData is List) {
          ordersData = responseData;
        } else if (responseData is Map && responseData['orders'] != null) {
          ordersData = responseData['orders'];
        } else if (responseData is Map && responseData['data'] != null) {
          ordersData = responseData['data'];
        } else if (responseData is String) {
          // Handle case where response is a string (possibly JSON string)
          debugPrint('Response is a string, attempting to parse as JSON');
          try {
            final parsedData = jsonDecode(responseData);
            if (parsedData is List) {
              ordersData = parsedData;
            } else if (parsedData is Map && parsedData['orders'] != null) {
              ordersData = parsedData['orders'];
            } else if (parsedData is Map && parsedData['data'] != null) {
              ordersData = parsedData['data'];
            } else {
              ordersData = [];
            }
          } catch (parseError) {
            debugPrint('Failed to parse JSON string: $parseError');
            ordersData = [];
          }
        } else {
          ordersData = [];
        }
        
        debugPrint('Orders data length: ${ordersData.length}');
        
        // Parse each order with error handling
        List<OrderModel> orders = [];
        for (int i = 0; i < ordersData.length; i++) {
          try {
            final orderJson = ordersData[i];
            debugPrint('Parsing order $i: ${orderJson.runtimeType}');
            if (orderJson is Map<String, dynamic>) {
              orders.add(OrderModel.fromJson(orderJson));
            } else if (orderJson is Map) {
              // Convert Map to Map<String, dynamic>
              orders.add(OrderModel.fromJson(Map<String, dynamic>.from(orderJson)));
            } else {
              debugPrint('Skipping order $i: not a valid map structure');
            }
          } catch (parseError) {
            debugPrint('Error parsing order $i: $parseError');
            debugPrint('Order data: ${ordersData[i]}');
          }
        }
        
        return orders;
      }
      throw Exception('Failed to load orders: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      if (e is DioException) {
        debugPrint('Request URL: ${e.requestOptions.uri}');
        debugPrint('Status Code: ${e.response?.statusCode}');
        debugPrint('Error Response: ${e.response?.data}');
      }
      throw Exception('Failed to load orders: $e');
    }
  }

  Future<OrderModel> getOrderById(String orderId) async {
    try {
      // Get auth token for the cookie
      final accessToken = await _cacheService.getString(_accessTokenKey);
      if (accessToken == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }

      debugPrint('Fetching order details from: https://api.giftginnie.in/api/order/$orderId');
      
      final response = await _dio.get(
        'https://api.giftginnie.in/api/order/$orderId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Cookie': 'token=$accessToken',
            'Authorization': 'Bearer $accessToken',
          },
          extra: {
            'withCredentials': true,
          }
        ),
      );

      debugPrint('Order detail API response status: ${response.statusCode}');
      debugPrint('Order detail API response data: ${response.data}');

      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        
        if (responseData is Map && responseData['order'] != null) {
          final orderData = responseData['order'];
          if (orderData is Map) {
            // Log address details specifically
            if (orderData['address'] != null) {
              debugPrint('=== ADDRESS DETAILS FROM API ===');
              debugPrint('Address object type: ${orderData['address'].runtimeType}');
              debugPrint('Address data: ${orderData['address']}');
              
              final addressData = orderData['address'];
              if (addressData is Map) {
                debugPrint('Address fields:');
                debugPrint('  - _id: ${addressData['_id']}');
                debugPrint('  - id: ${addressData['id']}');
                debugPrint('  - fullName: ${addressData['fullName']}');
                debugPrint('  - name: ${addressData['name']}');
                debugPrint('  - phone: ${addressData['phone']}');
                debugPrint('  - phoneNumber: ${addressData['phoneNumber']}');
                debugPrint('  - phone_number: ${addressData['phone_number']}');
                debugPrint('  - addressLine1: ${addressData['addressLine1']}');
                debugPrint('  - address_line_1: ${addressData['address_line_1']}');
                debugPrint('  - addressLine2: ${addressData['addressLine2']}');
                debugPrint('  - address_line_2: ${addressData['address_line_2']}');
                debugPrint('  - city: ${addressData['city']}');
                debugPrint('  - state: ${addressData['state']}');
                debugPrint('  - country: ${addressData['country']}');
                debugPrint('  - zipCode: ${addressData['zipCode']}');
                debugPrint('  - zipcode: ${addressData['zipcode']}');
                debugPrint('  - zip_code: ${addressData['zip_code']}');
                debugPrint('  - pincode: ${addressData['pincode']}');
                debugPrint('  - pin_code: ${addressData['pin_code']}');
                debugPrint('  - addressType: ${addressData['addressType']}');
                debugPrint('  - address_type: ${addressData['address_type']}');
                debugPrint('  - type: ${addressData['type']}');
                debugPrint('All address keys: ${addressData.keys.toList()}');
              }
              debugPrint('=== END ADDRESS DETAILS ===');
            } else {
              debugPrint('=== NO ADDRESS IN RESPONSE ===');
            }
            
            return OrderModel.fromJson(Map<String, dynamic>.from(orderData));
          }
        }
        
        throw Exception('Invalid response format');
      }
      throw Exception('Failed to load order details: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching order details: $e');
      if (e is DioException) {
        debugPrint('Request URL: ${e.requestOptions.uri}');
        debugPrint('Status Code: ${e.response?.statusCode}');
        debugPrint('Error Response: ${e.response?.data}');
      }
      throw Exception('Failed to load order details: $e');
    }
  }
  
  // // TODO: Implement order tracking
  // Future<OrderModel> trackOrder(String orderId) async {
  //   // Simulate API delay
  //   await Future.delayed(const Duration(seconds: 1));
  //   return mockOrders.firstWhere((order) => order.id == orderId);
  // }
  
  // TODO: Implement order cancellation
  Future<void> cancelOrder(String orderId) async {
    // Add actual cancellation implementation
    await Future.delayed(const Duration(seconds: 1));
  }
  
  // TODO: Implement order rating
  Future<void> rateOrder(String orderId, int rating, {String? review}) async {
    // Add actual rating implementation
    await Future.delayed(const Duration(seconds: 1));
  }
  
  // TODO: Implement reorder functionality
  Future<void> reorderItems(String orderId) async {
    // Add actual reorder implementation
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> rateProduct(String productId, int rating) async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiEndpoints.productRating(productId)}';
      final data = {
        'rating': rating,
      };
      
      // Log the request details
      debugPrint('Rating Product Request:');
      debugPrint('URL: $url');
      debugPrint('Body: $data');
      
      final response = await _dio.post(
        url,
        data: data,
      );
      
      // Log the successful response
      debugPrint('Rating Response Status: ${response.statusCode}');
      debugPrint('Rating Response Data: ${response.data}');
      
    } catch (e) {
      // Detailed error logging
      debugPrint('Error rating product:');
      if (e is DioException) {
        debugPrint('Request URL: ${e.requestOptions.uri}');
        debugPrint('Request Data: ${e.requestOptions.data}');
        debugPrint('Status Code: ${e.response?.statusCode}');
        debugPrint('Error Response: ${e.response?.data}');
      }
      debugPrint('Error Details: $e');
      throw Exception('Failed to rate product: $e');
    }
  }
}