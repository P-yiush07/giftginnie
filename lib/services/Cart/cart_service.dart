import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/api.dart';
import '../../models/cart_model.dart';
import '../Cache/cache_service.dart';

class CartService {
  // Singleton instance
  static final CartService _instance = CartService._internal();
  
  // Factory constructor to return the same instance
  factory CartService() {
    return _instance;
  }
  
  final Dio _dio;
  final CacheService _cacheService = CacheService();
  static const String _accessTokenKey = 'auth_token';
  
  // Local storage for coupon data
  String? _appliedCouponCode;
  double? _discountAmount;
  double? _finalPrice;
  
  // Getters for coupon info
  String? get appliedCouponCode => _appliedCouponCode;
  double? get discountAmount => _discountAmount;
  double? get finalPrice => _finalPrice;

  // Private constructor for singleton
  CartService._internal() : _dio = Dio() {
    debugPrint('CartService singleton initialized');
    _initializeDio();
  }

  void _initializeDio() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await _cacheService.getString(_accessTokenKey);
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
            // Also add the cookie header for APIs that require it
            options.headers['Cookie'] = 'token=$accessToken';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<CartModel?> getCart() async {
    try {
      debugPrint('Fetching cart from: https://api.giftginnie.in/api/cart');
      debugPrint('Current local coupon state: Code: $_appliedCouponCode, Discount: $_discountAmount');
      
      // Get the auth token for the cookie header
      final accessToken = await _cacheService.getString(_accessTokenKey);
      if (accessToken == null) {
        debugPrint('User not logged in - no auth token found');
        return null;
      }
      
      // Create options with the correct headers
      final options = Options(
        headers: {
          'Cookie': 'token=$accessToken',
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => true, // Don't throw errors for any status code
      );
      
      final response = await _dio.get(
        'https://api.giftginnie.in/api/cart',
        options: options,
      );

      debugPrint('Cart response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        if (response.data['data'] != null) {
          debugPrint('Cart data received: ${response.data['data']}');
          
          // Check if there's discount information
          double? discountAmount;
          double? finalPrice;
          String? appliedCouponCode;
          
          if (response.data['discount'] != null) {
            discountAmount = (response.data['discount'] is int) 
                ? (response.data['discount'] as int).toDouble() 
                : (response.data['discount'] as double);
          }
          
          if (response.data['finalPrice'] != null) {
            finalPrice = (response.data['finalPrice'] is int) 
                ? (response.data['finalPrice'] as int).toDouble() 
                : (response.data['finalPrice'] as double);
          }
          
          if (response.data['appliedCoupon'] != null) {
            appliedCouponCode = response.data['appliedCoupon'] as String;
          }
          
          // Create cart model with items
          final cartItems = CartModel.fromJson(response.data['data']);
          
          // Clear local coupon data if not present in API response
          if (appliedCouponCode == null && discountAmount == null && finalPrice == null) {
            debugPrint('No coupon data in API response, clearing local coupon data');
            _appliedCouponCode = null;
            _discountAmount = null;
            _finalPrice = null;
          }
          
          // Use data from API response, fallback to local data only if API has partial data
          final String? couponCode = appliedCouponCode ?? _appliedCouponCode;
          final double? discount = discountAmount ?? _discountAmount;
          final double? finalPriceValue = finalPrice ?? _finalPrice ?? 
              (discount != null ? cartItems.totalPrice - discount : null);
          
          debugPrint('Returning cart with coupon data - Code: $couponCode, Discount: $discount, Final Price: $finalPriceValue');
          
          // Return cart with discount info if available
          return CartModel(
            items: cartItems.items,
            totalPrice: cartItems.totalPrice,
            totalItems: cartItems.totalItems,
            discountAmount: discount,
            finalPrice: finalPriceValue,
            appliedCouponCode: couponCode,
          );
        }
        
        debugPrint('Cart is empty');
        return CartModel(items: [], totalPrice: 0, totalItems: 0);
      }
      
      debugPrint('Failed to load cart: ${response.statusMessage}');
      throw Exception('Failed to load cart data: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        debugPrint('Cart not found (404)');
        return CartModel(items: [], totalPrice: 0, totalItems: 0); // Return empty cart for 404
      }
      debugPrint('Error fetching cart: $e');
      throw Exception('Failed to load cart data: ${e.toString()}');
    }
  }

  Future<void> updateItemQuantity(String itemId, String variantId, int quantity) async {
    try {
    // Get the auth token for the cookie header
    final accessToken = await _cacheService.getString(_accessTokenKey);
    if (accessToken == null) {
      throw Exception('User not logged in - no auth token found');
    }

     final options = Options(
      headers: {
        'Cookie': 'token=$accessToken',
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) => true, // Don't throw errors for any status code
    );

     final Map<String, dynamic> payload = {
      'productId': itemId,
      'variantId': variantId,
      'quantity': quantity,
    };

      final response = await _dio.put(
        'https://api.giftginnie.in/api/cart',
        data: payload,
        options: options,
      );

      if (response.statusCode == 200) {
        debugPrint('Item updated successfully');
      } else {
        debugPrint('Failed to update item: ${response.statusMessage}');
        throw Exception('Failed to update item quantity');
      }
    } catch (e) {
      debugPrint('Error updating cart item quantity: $e');
      throw Exception('Failed to update item quantity');
    }
  }

  Future<void> removeItem(int itemId) async {
    try {
      await _dio.delete(
        '${ApiConstants.baseUrl}${ApiEndpoints.cartItem(itemId)}',
      );
    } catch (e) {
      debugPrint('Error removing cart item: $e');
      throw Exception('Failed to remove item from cart');
    }
  }

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

  Future<Map<String, dynamic>> applyCoupon(String couponCode) async {
    try {
      debugPrint('Applying coupon: $couponCode');
      
      // Get the cart items first
      final cartData = await getCart();
      if (cartData == null || cartData.items.isEmpty) {
        throw Exception('Your cart is empty');
      }
      
      // Prepare cart items in the format expected by the backend
      final List<Map<String, dynamic>> cartItems = cartData.items.map((item) => {
        'product': {
          '_id': item.productId,
          'variants': [
            {
              '_id': item.variantId,
              'price': item.variantPrice,
            }
          ]
        },
        'quantity': item.quantity,
      }).toList();
      
      debugPrint('Sending coupon apply request with cart items: ${cartItems.length}');
      
      // Send request to apply coupon endpoint
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/coupons/apply-coupon',
        data: {
          'couponCode': couponCode,
          'cart': cartItems,
        },
      );
      
      debugPrint('Coupon apply response: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          // Store coupon information locally
          _appliedCouponCode = couponCode;
          _discountAmount = responseData['discount'] is int 
              ? (responseData['discount'] as int).toDouble() 
              : (responseData['discount'] as double? ?? 0.0);
          _finalPrice = responseData['priceToPay'] is int 
              ? (responseData['priceToPay'] as int).toDouble() 
              : (responseData['priceToPay'] as double? ?? 0.0);
          
          debugPrint('Coupon applied successfully. Code: $_appliedCouponCode, Discount: $_discountAmount, Final price: $_finalPrice');
          
          return {
            'success': true,
            'totalAmount': responseData['totalAmount'] ?? 0.0,
            'discount': _discountAmount ?? 0.0,
            'priceToPay': _finalPrice ?? 0.0,
            'message': responseData['message'] ?? 'Coupon applied successfully',
          };
        } else {
          throw Exception(responseData['message'] ?? 'Failed to apply coupon');
        }
      } else {
        throw Exception('Failed to apply coupon');
      }
    } on DioException catch (e) {
      debugPrint('Error applying coupon: $e');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Failed to apply coupon');
    } catch (e) {
      debugPrint('Error applying coupon: $e');
      throw Exception(e.toString());
    }
  }

  // Method to clear local coupon data (used when switching tabs)
  void clearLocalCouponData() {
    debugPrint('Clearing local coupon data');
    _appliedCouponCode = null;
    _discountAmount = null;
    _finalPrice = null;
  }

  Future<bool> removeCoupon() async {
    try {
      debugPrint('Removing applied coupon locally (no endpoint available)');
      
      // Clear local coupon data
      clearLocalCouponData();
      
      debugPrint('Coupon removed successfully from local storage');
      return true;
      
      // Note: We're not making an API call since there's no endpoint
      // If an endpoint is added in the future, uncomment this code:
      /*
      final response = await _dio.delete(
        '${ApiConstants.baseUrl}${ApiEndpoints.cartApplyCoupon}',
      );
      
      if (response.statusCode == 200) {
        // Clear local coupon data
        _appliedCouponCode = null;
        _discountAmount = null;
        _finalPrice = null;
        debugPrint('Coupon removed successfully');
        return true;
      }
      return false;
      */
    } catch (e) {
      debugPrint('Error in coupon removal process: $e');
      throw Exception('Failed to remove coupon');
    }
  }

  Future<void> addToCart(String productId, String variantId, int quantity) async {
    try {
      debugPrint('Adding to cart: productId=$productId, variantId=$variantId, quantity=$quantity');
      
      // Get the auth token for the cookie header
      final accessToken = await _cacheService.getString(_accessTokenKey);
      if (accessToken == null) {
        throw Exception('User not logged in - no auth token found');
      }
      
      debugPrint('Using auth token: $accessToken');
      
      // Create a dedicated Dio instance for this request to ensure headers are set correctly
      final cartDio = Dio();
      
      // Set both authorization methods (Cookie and Bearer token)
      final options = Options(
        headers: {
          'Cookie': 'token=$accessToken',
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => true, // Don't throw errors for any status code
      );
      
      debugPrint('Sending cart request with headers: ${options.headers}');
      
      // Ensure quantities are numbers, not strings
      final Map<String, dynamic> payload = {
        'productId': productId,
        'variantId': variantId,
        'quantity': quantity,
      };
      
      debugPrint('Request payload: $payload');
      
      final response = await cartDio.post(
        'https://api.giftginnie.in/api/cart',
        data: payload,
        options: options,
      );
      
      debugPrint('Add to cart response: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned error: ${response.statusCode} - ${response.statusMessage}');
      }
    } catch (e) {
      debugPrint('Error adding item to cart: $e');
      throw Exception('Failed to add item to cart: ${e.toString()}');
    }
  }
}