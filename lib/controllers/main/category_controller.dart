import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../services/product_service.dart';
import '../../services/category_service.dart';

class CategoryController extends ChangeNotifier {
  final ProductService _productService = ProductService();
  CategoryModel? _categoryData;
  bool _isLoading = false;
  bool _hasError = false;
  late final CategoryModel _category;
  bool _isDisposed = false;
  DateTime? _lastLoadTime;
  static const Duration _minLoadInterval = Duration(milliseconds: 300);

  CategoryModel? get categoryData => _categoryData;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  CategoryController(CategoryModel category) {
    _category = category;
  }

  Future<void> loadCategoryData(CategoryModel category) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _hasError = false;
      if (!_isDisposed) notifyListeners();

      final products = await _productService.getProductsByCategory(category.id.toString());
      
      if (_isDisposed) return;

      if (products.isEmpty) {
        _hasError = true;
        _categoryData = null;
      } else {
        _categoryData = CategoryModel(
          id: category.id,
          categoryName: category.categoryName,
          description: category.description,
          image: category.image,
          gifts: products.map((product) => GiftItem(
            name: product.name,
            image: product.images.isNotEmpty ? product.images[0] : 'assets/images/placeholder.png',
            images: product.images.isNotEmpty ? product.images : ['assets/images/placeholder.png'],
            subtitle: product.brand,
            category: product.productType,
            rating: product.rating,
            duration: '30 minutes',
            discount: '20%',
            price: product.price,
            isLiked: product.isLiked,
          )).toList(),
        );
        _hasError = false;
      }
    } catch (e) {
      debugPrint('Error loading category data: $e');
      _hasError = true;
      _categoryData = null;
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  Future<void> refreshData() async {
    _categoryData = null;
    _hasError = false;
    notifyListeners();
    await loadCategoryData(_category);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}