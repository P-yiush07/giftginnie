import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:giftginnie_ui/constants/products.dart';
import 'package:giftginnie_ui/models/product_model.dart';

class ProductService {
  final Dio _dio;

  ProductService() : _dio = Dio();

  Future<List<Product>> getProducts() async {
    try {
      // TODO: Implement API call when backend is ready
      // final response = await _dio.get('${ApiConstants.baseUrl}/products');
      // return (response.data['data'] as List)
      //     .map((json) => Product.fromJson(json))
      //     .toList();

      // Using mock data for now
      return mockProducts
          .map((json) => Product(
                id: json['id'] as String,
                name: json['name'] as String,
                description: json['description'] as String,
                price: json['price'] as double,
                image: json['image'] as String,
                brand: json['brand'] as String,
                productType: json['productType'] as String,
                isLiked: json['isLiked'] as bool,
                rating: json['rating'] as double,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error fetching products: $e');
      throw Exception('Failed to load products');
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      // TODO: Implement API call when backend is ready
      // final response = await _dio.get('${ApiConstants.baseUrl}/products?category=$category');
      // return (response.data['data'] as List)
      //     .map((json) => Product.fromJson(json))
      //     .toList();

      // Using mock data for now
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
      return mockProducts
          .map((json) => Product(
                id: json['id'] as String,
                name: json['name'] as String,
                description: json['description'] as String,
                price: json['price'] as double,
                image: json['image'] as String,
                brand: json['brand'] as String,
                productType: json['productType'] as String,
                isLiked: json['isLiked'] as bool,
                rating: json['rating'] as double,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error fetching products by category: $e');
      throw Exception('Failed to load products for category: $category');
    }
  }
}