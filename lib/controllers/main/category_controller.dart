import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../services/product_service.dart';

class CategoryController extends ChangeNotifier {
  final ProductService _productService = ProductService();
  CategoryModel? _categoryData;
  bool _isLoading = false;
  String? _error;

  CategoryModel? get categoryData => _categoryData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CategoryController(CategoryModel category) {
    loadCategoryData(category);
  }

  Future<void> loadCategoryData(CategoryModel category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final products = await _productService.getProductsByCategory(category.categoryName);
      _categoryData = CategoryModel(
        id: category.id,
        categoryName: category.categoryName,
        description: category.description,  // Use the description we already have
        image: category.image,
        gifts: products.map((product) => GiftItem(
          name: product.name,
          image: product.image,
          subtitle: product.brand,
          category: product.productType,
          rating: product.rating,
          duration: '30 minutes',
          discount: '20%',
          price: product.price,
          isLiked: product.isLiked,
        )).toList(),
      );
    } catch (e) {
      _error = 'Failed to load category: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    if (_categoryData != null) {
      await loadCategoryData(_categoryData!);
    }
  }
}