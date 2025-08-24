import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/api.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../Cache/cache_service.dart';
import '../../models/popular_category_model.dart';

class CategoryService {
  final Dio _dio;
  final CacheService _cacheService = CacheService();
  final Map<String, CategoryModel> _categoryCache = {};
  static const String _accessTokenKey = 'auth_token';

  CategoryService() : _dio = Dio() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get the access token from cache
          final accessToken = await _cacheService.getString(_accessTokenKey);
          if (accessToken != null) {
            // Add both Authorization header and Cookie token
            options.headers['Authorization'] = 'Bearer $accessToken';
            options.headers['Cookie'] = 'token=$accessToken';
          }
          return handler.next(options);
        },
      ),
    );
  }
  
  // Helper method to get auth options
  Future<Options> _getAuthOptions() async {
    final token = await _cacheService.getString(_accessTokenKey);
    return Options(
      headers: {
        'Cookie': 'token=$token',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }
  
  // Fetch subcategory data including products
  Future<Map<String, dynamic>> getSubCategoryData(String subCategoryId) async {
    try {
      // Get auth token
      final token = await _cacheService.getString(_accessTokenKey);
      debugPrint('Using auth token: $token');
      
      // Ensure we have proper auth headers
      final options = Options(
        headers: {
          'Cookie': 'token=$token',
          'Authorization': 'Bearer $token',
        },
      );
      
      debugPrint('Fetching subcategory data for ID: $subCategoryId');
      final response = await _dio.get(
        'https://api.giftginnie.in/api/subcategory/single/$subCategoryId',
        options: options,
      );
      
      debugPrint('Subcategory response status: ${response.statusCode}');
      
      if (response.data['data'] == null) {
        throw Exception('No subcategory data found');
      }
      
      final subCategoryData = response.data['data'];
      final List<Product> products = [];
      
      // Parse products from the response
      if (subCategoryData['products'] != null && subCategoryData['products'] is List) {
        for (final productJson in subCategoryData['products']) {
          try {
            // Create a Product object from each product in the list
            final product = Product.fromJson(productJson);
            products.add(product);
          } catch (e) {
            debugPrint('Error parsing product: $e');
          }
        }
      }
      
      return {
        'subCategory': {
          'id': subCategoryData['_id'],
          'name': subCategoryData['name'],
          'description': subCategoryData['description'],
          'image': subCategoryData['image'],
        },
        'products': products,
      };
    } catch (e) {
      debugPrint('Error fetching subcategory data: $e');
      throw Exception('Failed to load subcategory data: $e');
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}${ApiEndpoints.categories}');
      final data = response.data['data'] as List;
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      throw Exception('Failed to load categories');
    }
  }
  
  // New method to fetch categories from the new API
  Future<List<CategoryModel>> fetchCategoriesFromNewApi() async {
    try {
      final options = await _getAuthOptions();
      
      final response = await _dio.get(
        'https://api.giftginnie.in/api/category',
        options: options,
      );
      
      final data = response.data['data'] as List;
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching categories from new API: $e');
      throw Exception('Failed to load categories');
    }
  }

  Future<Map<String, dynamic>> getCategoryData(String categoryId) async {
    // Check cache first
    if (_categoryCache.containsKey(categoryId)) {
      return {'category': _categoryCache[categoryId]!, 'subCategories': []};
    }

    try {
      final options = await _getAuthOptions();
      
      final response = await _dio.get(
        'https://api.giftginnie.in/api/category/$categoryId',
        options: options,
      );
      
      final categoryData = CategoryModel.fromJson(response.data['data']);
      
      // Cache the result
      _categoryCache[categoryId] = categoryData;
      
      // Extract subcategories from the response
      final List<Map<String, dynamic>> subCategories = [];
      if (response.data['data']['subCategories'] != null) {
        for (var subCat in response.data['data']['subCategories']) {
          subCategories.add({
            'id': subCat['_id'],
            'name': subCat['name'],
            'description': subCat['description'],
            'image': subCat['image'],
            'products': subCat['products'] ?? [],
          });
        }
      }
      
      return {
        'category': categoryData,
        'subCategories': subCategories,
      };
    } catch (e) {
      debugPrint('Error fetching category data: $e');
      throw Exception('Failed to load category data');
    }
  }

  void clearCache(String? categoryId) {
    if (categoryId != null) {
      _categoryCache.remove(categoryId);
    } else {
      _categoryCache.clear();
    }
  }

  Future<List<PopularCategory>> getPopularCategories() async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}${ApiEndpoints.popularCategories}');
      final data = response.data['data'] as List;
      return data.map((json) => PopularCategory.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching popular categories: $e');
      throw Exception('Failed to load popular categories');
    }
  }
}