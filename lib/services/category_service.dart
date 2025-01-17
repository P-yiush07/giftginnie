import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/categories.dart';
import '../models/category_model.dart';

class CategoryService {
  final Dio _dio;

  CategoryService() : _dio = Dio();

  Future<List<CategoryModel>> getCategories() async {
    try {
      // TODO: Implement API call when backend is ready
      // final response = await _dio.get('${ApiConstants.baseUrl}/categories');
      // return (response.data['data'] as List)
      //     .map((json) => CategoryModel.fromJson(json))
      //     .toList();

      // Using mock data for now
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
      return mockCategories.map((json) => CategoryModel(
            categoryName: json['name'] as String,
            categoryIcon: json['icon'] as String,
            description: json['description'] as String,
            gifts: [], // Initially empty, will be populated when category is selected
          )).toList();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      throw Exception('Failed to load categories');
    }
  }
}