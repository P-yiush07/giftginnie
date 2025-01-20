import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api.dart';
import '../models/cart_model.dart';
import 'cache_service.dart';

class CartService {
  final Dio _dio;
  final CacheService _cacheService = CacheService();
  static const String _accessTokenKey = 'auth_token';

  CartService() : _dio = Dio() {
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

  Future<CartModel> getCart() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiEndpoints.cart}',
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        return CartModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to load cart data');
    } catch (e) {
      debugPrint('Error fetching cart: $e');
      throw Exception('Failed to load cart data');
    }
  }

  // Future<void> updateItemQuantity(String itemId, int quantity) async {
  //   try {
  //     await _dio.patch(
  //       '${ApiConstants.baseUrl}${ApiEndpoints.cartItem(itemId)}',
  //       data: {'quantity': quantity},
  //     );
  //   } catch (e) {
  //     debugPrint('Error updating cart item quantity: $e');
  //     throw Exception('Failed to update item quantity');
  //   }
  // }

  // Future<void> removeItem(String itemId) async {
  //   try {
  //     await _dio.delete(
  //       '${ApiConstants.baseUrl}${ApiEndpoints.cartItem(itemId)}',
  //     );
  //   } catch (e) {
  //     debugPrint('Error removing cart item: $e');
  //     throw Exception('Failed to remove item from cart');
  //   }
  // }

  Future<void> addItem(String productId, int quantity) async {
    try {
      await _dio.post(
        '${ApiConstants.baseUrl}${ApiEndpoints.cart}',
        data: {
          'product_id': productId,
          'quantity': quantity,
        },
      );
    } catch (e) {
      debugPrint('Error adding item to cart: $e');
      throw Exception('Failed to add item to cart');
    }
  }

  // Future<void> applyCoupon(String couponCode) async {
  //   try {
  //     await _dio.post(
  //       '${ApiConstants.baseUrl}${ApiEndpoints.cartApplyCoupon}',
  //       data: {'code': couponCode},
  //     );
  //   } catch (e) {
  //     debugPrint('Error applying coupon: $e');
  //     throw Exception('Failed to apply coupon');
  //   }
  // }
}