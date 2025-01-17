import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../services/product_service.dart';
import '../../services/category_service.dart';

class CategoryController extends ChangeNotifier {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  CategoryModel? _categoryData;
  List<CategoryModel>? _allCategories;
  bool _isLoading = false;
  String? _error;

  CategoryModel? get categoryData => _categoryData;
  List<CategoryModel>? get allCategories => _allCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CategoryController(String categoryName, String categoryIcon) {
    loadCategoryData(categoryName, categoryIcon);
    loadAllCategories();
  }

  Future<void> loadAllCategories() async {
    try {
      _allCategories = await _categoryService.getCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> loadCategoryData(String categoryName, String categoryIcon) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final products = await _productService.getProductsByCategory(categoryName);
      _categoryData = CategoryModel(
        categoryName: categoryName,
        categoryIcon: categoryIcon,
        description: 'Explore our curated selection of $categoryName gifts, perfect for every occasion.',
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
      await loadCategoryData(_categoryData!.categoryName, _categoryData!.categoryIcon);
    }
  }
}