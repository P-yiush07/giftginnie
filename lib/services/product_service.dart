import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:giftginnie_ui/config/api.dart';
import 'package:giftginnie_ui/constants/products.dart';
import 'package:giftginnie_ui/models/CarouselItem_model.dart';
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
        originalPrice: double.parse(json['original_price'].toString()),
        sellingPrice: double.parse(json['selling_price'].toString()),
        images: (json['images'] as List?)?.isNotEmpty == true 
            ? (json['images'] as List).map((img) => img['image'].toString()).toList()
            : ['assets/images/placeholder.png'],
        brand: json['brand']?.toString() ?? 'Unknown Brand',
        productType: json['product_type']?.toString() ?? 'Gift Item',
        inStock: json['in_stock'] as bool? ?? true,
        isLiked: json['is_liked'] as bool? ?? false,
        rating: (json['rating'] ?? 0.0).toDouble(),
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

  Future<List<Product>> getPopularProducts() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiEndpoints.popularProducts}',
      );

      debugPrint('Popular products response received: ${response.data}');

      if (response.data['data'] == null) {
        debugPrint('No popular products found in response');
        return [];
      }

      return (response.data['data'] as List).map((json) => Product(
        id: json['id'].toString(),
        name: json['name'] as String,
        description: json['description'] as String,
        originalPrice: double.parse(json['original_price']?.toString() ?? '0.0'),
        sellingPrice: double.parse(json['selling_price']?.toString() ?? '0.0'),
        images: (json['images'] as List?)?.isNotEmpty == true 
            ? (json['images'] as List).map((img) => img['image'].toString()).toList()
            : ['assets/images/placeholder.png'],
        brand: json['brand']?.toString() ?? 'Unknown Brand',
        productType: json['product_type']?.toString() ?? 'Gift Item',
        inStock: json['in_stock'] as bool? ?? true,
        isLiked: json['is_liked'] as bool? ?? false,
        rating: (json['rating'] ?? 0.0).toDouble(),
      )).toList();
    } catch (e) {
      debugPrint('Error fetching popular products: $e');
      throw Exception('Failed to load popular products');
    }
  }

  Future<Product> getProductById(String productId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiEndpoints.productById(productId)}',
      );

      debugPrint('Product detail response received: ${response.data}');

      if (response.data['data'] == null) {
        throw Exception('No product data found');
      }

      final json = response.data['data'];
      return Product(
        id: json['id'].toString(),
        name: json['name'] as String,
        description: json['description'] as String,
        originalPrice: double.parse(json['original_price'].toString()),
        sellingPrice: double.parse(json['selling_price'].toString()),
        images: (json['images'] as List?)?.isNotEmpty == true 
            ? (json['images'] as List).map((img) => img['image'].toString()).toList()
            : ['assets/images/placeholder.png'],
        brand: json['brand']?.toString() ?? 'Unknown Brand',
        productType: json['product_type']?.toString() ?? 'Gift Item',
        inStock: json['in_stock'] as bool? ?? true,
        isLiked: json['is_liked'] as bool? ?? false,
        rating: (json['rating'] ?? 0.0).toDouble(),
      );
    } catch (e) {
      debugPrint('Error fetching product by ID: $e');
      throw Exception('Failed to load product details');
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

  Future<List<CarouselItem>> getCarouselItems() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiEndpoints.carouselItems}',
        options: Options(
          headers: {
            'Accept': 'image/webp,image/jpeg,image/*,*/*;q=0.8',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((item) => CarouselItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching carousel items: $e');
      return [];
    }
  }

  Future<bool> toggleFavorite(String productId) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiEndpoints.favouriteProducts}',
        data: {
          "id": productId
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      throw Exception('Failed to update favorite status');
    }
  }
}