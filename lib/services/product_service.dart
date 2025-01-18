import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:giftginnie_ui/config/api.dart';
import 'package:giftginnie_ui/constants/products.dart';
import 'package:giftginnie_ui/models/product_model.dart';
import 'package:giftginnie_ui/services/cache_service.dart';

class ProductService {
  final Dio _dio;
  final CacheService _cacheService = CacheService();
  final Map<String, List<Product>> _productCache = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);
  final Map<String, DateTime> _cacheTimestamps = {};
  static const String _accessTokenKey = 'auth_token';

  ProductService() : _dio = Dio() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get the access token from cache
          final accessToken = await _cacheService.getString(_accessTokenKey);
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    debugPrint('Fetching products for category: $categoryId');
    
    // Check cache first
    if (_productCache.containsKey(categoryId)) {
      final cacheTime = _cacheTimestamps[categoryId];
      if (cacheTime != null && DateTime.now().difference(cacheTime) < _cacheExpiry) {
        return _productCache[categoryId]!;
      }
    }

    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiEndpoints.categoryProducts(categoryId)}',
      );

      debugPrint('Response received: ${response.data}');

      if (response.data['data'] == null) {
        debugPrint('No data found in response');
        return [];
      }

      final products = (response.data['data'] as List).map((json) => Product(
        id: json['id'].toString(),
        name: json['name'] as String,
        description: json['description'] as String,
        price: double.parse(json['price'].toString()),
        images: (json['images'] as List?)?.isNotEmpty == true 
            ? (json['images'] as List).map((img) => img['image'].toString()).toList()
            : ['assets/images/placeholder.png'],
        brand: json['brand']?.toString() ?? 'Unknown Brand',
        productType: json['product_type']?.toString() ?? 'Gift Item',
        isLiked: false,
        rating: json['rating']?.toDouble() ?? 0.0,
      )).toList();

      // Cache the results
      _productCache[categoryId] = products;
      _cacheTimestamps[categoryId] = DateTime.now();

      return products;
    } catch (e) {
      debugPrint('Error fetching products by category: $e');
      // Return cached data if available, even if expired
      if (_productCache.containsKey(categoryId)) {
        return _productCache[categoryId]!;
      }
      throw Exception('Failed to load products for category: $categoryId');
    }
  }

  void clearCache([String? categoryId]) {
    if (categoryId != null) {
      _productCache.remove(categoryId);
      _cacheTimestamps.remove(categoryId);
    } else {
      _productCache.clear();
      _cacheTimestamps.clear();
    }
  }
}