import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:giftginnie_ui/config/api.dart';
import 'package:giftginnie_ui/models/product_model.dart';
import 'package:giftginnie_ui/services/Cache/cache_service.dart';

class WishlistService {
  final Dio _dio;
  final CacheService _cacheService = CacheService();
  static const String _accessTokenKey = 'auth_token';

  WishlistService() : _dio = Dio() {
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

  Future<List<Product>> getFavouriteProducts() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiEndpoints.favouriteProducts}',
      );

      if (response.data['data'] == null) {
        return [];
      }

      return (response.data['data'] as List).map((item) {
        final productData = item['product'];
        return Product(
          id: productData['id'].toString(),
          name: productData['name'],
          description: productData['description'],
          originalPrice: double.parse(productData['original_price'] ?? '0.0'),
          sellingPrice: double.parse(productData['selling_price'] ?? '0.0'),
          images: (productData['images'] as List?)?.map((img) => img['image'].toString()).toList() ?? [],
          brand: productData['brand'] ?? '',
          productType: productData['product_type'] ?? '',
          inStock: productData['in_stock'] ?? true,
          rating: (productData['rating'] ?? 0.0).toDouble(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching favourite products: $e');
      throw Exception('Failed to load favourite products');
    }
  }
}