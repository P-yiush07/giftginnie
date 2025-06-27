import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:giftginnie_ui/config/api.dart';
import 'package:giftginnie_ui/constants/products.dart';
import 'package:giftginnie_ui/models/CarouselItem_model.dart';
import 'package:giftginnie_ui/models/product_model.dart';
import 'package:giftginnie_ui/services/Cache/cache_service.dart';

class ProductService {
  final Dio _dio;
  final CacheService _cacheService = CacheService();
  final Map<String, List<Product>> _productCache = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);
  final Map<String, DateTime> _cacheTimestamps = {};
  static const String _accessTokenKey = 'auth_token';
  
  // Banner/Carousel caching
  List<CarouselItem>? _cachedCarouselItems;
  DateTime? _carouselCacheTimestamp;
  static const Duration _carouselCacheExpiry = Duration(hours: 1); // Cache banners for 1 hour

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
      final token = await _cacheService.getString(_accessTokenKey);
      debugPrint('Using auth token for product detail: $token');
      
      // Ensure we have proper auth headers
      final options = Options(
        headers: {
          'Cookie': 'token=$token',
          'Authorization': 'Bearer $token',
        },
      );
      
      final response = await _dio.get(
        'https://api.giftginnie.in/api/product/$productId',
        options: options,
      );

      debugPrint('Product detail response status: ${response.statusCode}');

      if (response.data['data'] == null) {
        throw Exception('No product data found');
      }

      final json = response.data['data'];
      
      // Try to extract product details from the new API format
      try {
        return Product.fromJson(json);
      } catch (parseError) {
        debugPrint('Error parsing product from new API format: $parseError');
        
        // Fall back to old format if new format parsing fails
        // Extract variants
        List<ProductVariant> variants = [];
        if (json['variants'] != null && json['variants'] is List) {
          for (var variantJson in json['variants']) {
            if (variantJson is Map<String, dynamic>) {
              final variant = ProductVariant(
                id: variantJson['_id'] ?? '',
                description: variantJson['description'] ?? '',
                descriptionSecond: variantJson['descriptionsecond'] ?? '',
                price: double.tryParse('${variantJson['price']}') ?? 0.0,
                color: variantJson['color'] ?? 'Default',
                stock: variantJson['stock'] ?? 0,
                images: variantJson['images'] != null ? List<String>.from(variantJson['images']) : [],
                isGift: variantJson['isGift'] ?? false,
              );
              variants.add(variant);
              debugPrint('Added variant: ${variant.color} with price ${variant.price}');
            }
          }
        }
        
        // Default price if no variants
        double originalPrice = 0.0;
        double sellingPrice = 0.0;
        bool inStock = true;
        
        // If we have variants, use the first variant's price
        if (variants.isNotEmpty) {
          originalPrice = variants[0].price;
          sellingPrice = variants[0].price; // Use exact price from variant
          inStock = variants[0].stock > 0;
          debugPrint('Using variant price: $originalPrice');
        }
        
        return Product(
          id: json['_id'] ?? json['id'] ?? '',
          name: json['title'] ?? json['name'] ?? 'Unnamed Product',
          description: json['description'] ?? '',
          originalPrice: originalPrice,
          sellingPrice: sellingPrice,
          images: json['images'] != null ? List<String>.from(json['images']) : ['assets/images/placeholder.png'],
          brand: "Brand", // Default since API doesn't provide brand
          productType: "Product", // Default since API doesn't provide type
          inStock: inStock,
          variants: variants,
          isLiked: json['is_liked'] as bool? ?? false,
          rating: (json['rating'] ?? 4.5).toDouble(),
        );
      }
    } catch (e) {
      debugPrint('Error fetching product by ID: $e');
      throw Exception('Failed to load product details: $e');
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
  
  void clearCarouselCache() {
    debugPrint('Clearing banner/carousel cache');
    _cachedCarouselItems = null;
    _carouselCacheTimestamp = null;
  }
  
  void clearAllCache() {
    debugPrint('Clearing all caches');
    clearCache();
    clearCarouselCache();
  }

  Future<List<CarouselItem>> getCarouselItems() async {
    try {
      // Check if we have cached data and it's still valid
      if (_cachedCarouselItems != null && _carouselCacheTimestamp != null) {
        final now = DateTime.now();
        final cacheAge = now.difference(_carouselCacheTimestamp!);
        
        if (cacheAge < _carouselCacheExpiry) {
          debugPrint('Returning cached banner items (${_cachedCarouselItems!.length} items, cached ${cacheAge.inMinutes} minutes ago)');
          return _cachedCarouselItems!;
        } else {
          debugPrint('Banner cache expired (${cacheAge.inMinutes} minutes old), fetching fresh data');
        }
      } else {
        debugPrint('No cached banner data found, fetching from API');
      }
      
      debugPrint('Fetching banner items from: ${ApiConstants.baseUrl}${ApiEndpoints.carouselItems}');
      
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiEndpoints.carouselItems}',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      debugPrint('Banner API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Check if response has success field and data array
        if (responseData is Map && 
            responseData['success'] == true && 
            responseData['data'] is List) {
          
          final List<dynamic> bannerData = responseData['data'];
          debugPrint('Found ${bannerData.length} banner items from API');
          
          List<CarouselItem> carouselItems = [];
          for (int i = 0; i < bannerData.length; i++) {
            try {
              final item = bannerData[i];
              if (item is Map) {
                final carouselItem = CarouselItem.fromJson(Map<String, dynamic>.from(item));
                carouselItems.add(carouselItem);
                debugPrint('Parsed banner item ${i + 1}: ${carouselItem.image}');
              }
            } catch (parseError) {
              debugPrint('Error parsing banner item $i: $parseError');
            }
          }
          
          // Cache the results
          _cachedCarouselItems = carouselItems;
          _carouselCacheTimestamp = DateTime.now();
          debugPrint('Cached ${carouselItems.length} banner items for future use');
          
          return carouselItems;
        } else {
          debugPrint('Invalid banner API response structure');
          // Return cached data if available, even if API response is invalid
          return _cachedCarouselItems ?? [];
        }
      }
      
      debugPrint('Banner API returned status: ${response.statusCode}');
      // Return cached data if available, even if API request failed
      return _cachedCarouselItems ?? [];
    } catch (e) {
      debugPrint('Error fetching banner items: $e');
      if (e is DioException) {
        debugPrint('Request URL: ${e.requestOptions.uri}');
        debugPrint('Status Code: ${e.response?.statusCode}');
        debugPrint('Error Response: ${e.response?.data}');
      }
      
      // Return cached data if available, even if there's an error
      if (_cachedCarouselItems != null) {
        debugPrint('Returning cached banner items due to API error');
        return _cachedCarouselItems!;
      }
      
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

  Future<List<Product>> searchProducts(String query, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // Get auth token for the cookie
      final accessToken = await _cacheService.getString(_accessTokenKey);
      
      // Build query parameters for search endpoint
      Map<String, dynamic> queryParams = {};
      
      // Ensure we have a search query
      if (query.isEmpty) {
        debugPrint('No search query provided');
        return [];
      }
      
      queryParams['query'] = query;
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      debugPrint('Searching products with query: "$query"');
      debugPrint('Search parameters: $queryParams');
      
      // Build the full URL with query parameters for debugging
      final uri = Uri.parse('https://api.giftginnie.in/api/product/search').replace(queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())));
      debugPrint('Full request URL: $uri');

      // First try without authentication to see if that's the issue
      debugPrint('Trying request without authentication first...');
      
      Response response;
      try {
        response = await _dio.get(
          '${ApiConstants.baseUrl}/product/search',
          queryParameters: queryParams,
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
        debugPrint('Request without auth succeeded');
      } catch (noAuthError) {
        debugPrint('Request without auth failed: $noAuthError');
        
        // Try with authentication
        debugPrint('Trying with authentication...');
        response = await _dio.get(
          '${ApiConstants.baseUrl}/product/search',
          queryParameters: queryParams,
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (accessToken != null) 'Cookie': 'token=$accessToken',
              if (accessToken != null) 'Authorization': 'Bearer $accessToken',
            },
            extra: {
              'withCredentials': true,
            }
          ),
        );
      }

      debugPrint('Search API response status: ${response.statusCode}');
      debugPrint('Search API response data: ${response.data}');

      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        
        if (responseData is Map && responseData['data'] != null) {
          final productsData = responseData['data'];
          if (productsData is List) {
            debugPrint('Found ${productsData.length} products');
            
            List<Product> products = [];
            for (int i = 0; i < productsData.length; i++) {
              try {
                final productJson = productsData[i];
                if (productJson is Map) {
                  final product = _parseProductFromBackend(Map<String, dynamic>.from(productJson));
                  products.add(product);
                }
              } catch (parseError) {
                debugPrint('Error parsing product $i: $parseError');
              }
            }
            
            return products;
          }
        }
      }
      
      return [];
    } catch (e) {
      debugPrint('Error searching products: $e');
      if (e is DioException) {
        debugPrint('Request URL: ${e.requestOptions.uri}');
        debugPrint('Status Code: ${e.response?.statusCode}');
        debugPrint('Error Response: ${e.response?.data}');
      }
      return [];
    }
  }

  Product _parseProductFromBackend(Map<String, dynamic> json) {
    try {
      debugPrint('Parsing product: ${json['title']}');
      
      // Parse variants
      List<ProductVariant> variants = [];
      if (json['variants'] is List) {
        for (var variantJson in json['variants']) {
          if (variantJson is Map) {
            try {
              variants.add(ProductVariant.fromJson(Map<String, dynamic>.from(variantJson)));
            } catch (e) {
              debugPrint('Error parsing variant: $e');
            }
          }
        }
      }
      
      // Get pricing from variants
      double originalPrice = 0.0;
      double sellingPrice = 0.0;
      bool inStock = false;
      
      if (variants.isNotEmpty) {
        // Get minimum price from variants
        sellingPrice = variants.map((v) => v.price).reduce((a, b) => a < b ? a : b);
        originalPrice = sellingPrice; // Assuming no separate original price
        inStock = variants.any((v) => v.inStock);
      }
      
      // Get main product images
      List<String> images = [];
      if (json['images'] is List) {
        images.addAll((json['images'] as List).map((img) => img.toString()).toList());
      }
      
      // Add variant images (from first variant if available)
      if (variants.isNotEmpty && variants.first.images.isNotEmpty) {
        images.addAll(variants.first.images);
      }
      
      // Remove duplicates
      images = images.toSet().toList();

      return Product(
        id: json['_id']?.toString() ?? '',
        name: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        originalPrice: originalPrice,
        sellingPrice: sellingPrice,
        images: images,
        brand: '', // Not in your schema
        productType: 'Gift Item', // Default value
        inStock: inStock,
        isLiked: false, // Default value
        rating: 0.0, // Calculate from reviews if needed
        variants: variants,
      );
    } catch (e) {
      debugPrint('Error parsing product from backend: $e');
      debugPrint('Product JSON: $json');
      rethrow;
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}