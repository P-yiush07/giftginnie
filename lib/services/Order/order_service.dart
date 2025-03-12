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
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/orders/checkout/',
      );

      if (response.statusCode == 200) {
        final List<dynamic> ordersData = response.data['data'];
        return ordersData.map((json) => OrderModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load orders');
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      throw Exception('Failed to load orders');
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