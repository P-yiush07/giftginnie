import 'package:dio/dio.dart';
import '../../models/checkout_model.dart';
import '../../config/api.dart';
import '../Cache/cache_service.dart';
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

  Future<Map<String, dynamic>> createOrder(String addressId, {String? couponCode}) async {
    try {
      // Get the auth token for the cookie header
      final accessToken = await _cacheService.getString(_accessTokenKey);
      if (accessToken == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }
      
      // Create request data with the exact parameter names expected by the API
      final Map<String, dynamic> requestData = {
        'addressId': addressId,  // Use addressId instead of address_id
      };
      
      // Add coupon code if provided, using promoCode as the parameter name
      if (couponCode != null && couponCode.isNotEmpty) {
        requestData['promoCode'] = couponCode;  // Use promoCode instead of coupon_code
        debugPrint('Including promo code in order creation: $couponCode');
      }
      
      debugPrint('Creating order with data: $requestData');
      debugPrint('Using token: ${accessToken.substring(0, 10)}...');
      
      // Create headers with token
      // The server extracts userId from the token
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cookie': 'token=$accessToken',
        'Authorization': 'Bearer $accessToken',
      };
      
      debugPrint('Sending request to: https://api.giftginnie.in/api/order');
      debugPrint('Headers: ${headers.toString()}');
      
      try {
        final response = await _dio.post(
          'https://api.giftginnie.in/api/order',
          data: requestData,
          options: Options(
            headers: headers,
            validateStatus: (status) => true, // Accept any status code for debugging
            followRedirects: true,
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
          ),
        );

        // Log full response details
        debugPrint('Response status code: ${response.statusCode}');
        debugPrint('Response headers: ${response.headers}');
        debugPrint('Response data: ${response.data}');
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Access the order data from the response
          final orderData = response.data['order'] ?? response.data;
          
          // Extract the fields needed for Razorpay
          return {
            'orderId': orderData['_id'] ?? orderData['id'] ?? '',
            'razorpayOrderId': orderData['razorpayOrderId'] ?? '',
            'amount': orderData['priceToPay'] ?? orderData['totalAmount'] ?? 0,
            'currency': orderData['currency'] ?? 'INR',
            'discount': orderData['discount'] ?? 0,
          };
        } else {
          // Log error details
          final errorMsg = response.data is Map ? response.data['message'] ?? response.data.toString() : response.data.toString();
          debugPrint('Server error: $errorMsg');
          throw Exception('Server returned ${response.statusCode}: $errorMsg');
        }
      } catch (requestError) {
        debugPrint('HTTP Request Error: ${requestError.toString()}');
        if (requestError is DioException) {
          debugPrint('DioError type: ${requestError.type}');
          debugPrint('DioError message: ${requestError.message}');
          debugPrint('DioError response: ${requestError.response?.data}');
        }
        rethrow;
      }
    } catch (e) {
      debugPrint('Order creation error: ${e.toString()}');
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

      // Get auth token for the cookie
      final accessToken = await _cacheService.getString(_accessTokenKey);
      if (accessToken == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }
      
      final response = await _dio.post(
        'https://api.giftginnie.in/api/transaction/verify',  // Updated to correct endpoint
        data: {
          'razorpay_payment_id': paymentId,
          'razorpay_order_id': orderId,
          'razorpay_signature': signature,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Cookie': 'token=$accessToken',  // Cookie format as required
            'Authorization': 'Bearer $accessToken',
          },
          extra: {
            'withCredentials': true,
          }
        ),
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