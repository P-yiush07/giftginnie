import 'package:dio/dio.dart';
import '../models/checkout_model.dart';
import '../config/api.dart';
import 'cache_service.dart';
import 'package:flutter/foundation.dart';

class CheckoutService {
  final Dio _dio;
  final CacheService _cacheService = CacheService();
  static const String _accessTokenKey = 'auth_token';

  CheckoutService() : _dio = Dio() {
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

  Future<Map<String, dynamic>> createOrder(int addressId) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiEndpoints.createOrder}',
        data: {
          'address_id': addressId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'orderId': response.data['order_id'],
          'razorpayOrderId': response.data['razorpay_order_id'],
          'amount': response.data['amount'],
          'currency': response.data['currency'],
        };
      }
      throw Exception(response.data['message'] ?? 'Failed to create order');
    } catch (e) {
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }

  Future<CheckoutModel> initializeCheckout() async {
    // TODO: Implement API call to get checkout details
    // This is a mock implementation
    await Future.delayed(const Duration(seconds: 1));
    
    return CheckoutModel(
      orderId: "ORD${DateTime.now().millisecondsSinceEpoch}",
      items: [],
      originalPrice: 0,
      discountedPrice: 0,
      deliveryAddress: "",
      paymentMethod: "Online Payment",
    );
  }

  Future<bool> processPayment() async {
    // TODO: Implement payment processing
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  Future<bool> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      // Debug log before making the API call
      print('Attempting to verify payment with:');
      print('Payment ID: $paymentId');
      print('Order ID: $orderId');
      print('Signature: $signature');

      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiEndpoints.verifyPayment}',
        data: {
          'razorpay_payment_id': paymentId,
          'razorpay_order_id': orderId,
          'razorpay_signature': signature,
        },
      );

      // Debug log after API response
      print('Payment verification API response:');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.data}');

      return response.statusCode == 200;
    } catch (e) {
      // Debug log for errors
      print('Error in verifyPayment:');
      print(e.toString());
      return false;
    }
  }
}