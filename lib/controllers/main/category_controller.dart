import 'package:flutter/material.dart';
import 'package:giftginnie_ui/controllers/main/product_controller.dart';
import 'package:giftginnie_ui/utils/global.dart';
import '../../models/category_model.dart';
import '../../services/Product/product_service.dart';
import '../../services/Product/category_service.dart';
import 'package:provider/provider.dart';

class CategoryController extends ChangeNotifier {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  CategoryModel? _categoryData;
  List<Map<String, dynamic>> _subCategories = [];
  bool _isLoading = false;
  bool _hasError = false;
  late final CategoryModel _category;
  bool _isDisposed = false;
  DateTime? _lastLoadTime;
  static const Duration _minLoadInterval = Duration(milliseconds: 300);

  CategoryModel? get categoryData => _categoryData;
  List<Map<String, dynamic>> get subCategories => _subCategories;
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
      _subCategories = [];
      if (!_isDisposed) notifyListeners();

      debugPrint('Fetching category data from new API for ID: ${category.id}');
      final result = await _categoryService.getCategoryData(category.id);
      final categoryData = result['category'] as CategoryModel;
      final subCategories = result['subCategories'] as List<Map<String, dynamic>>;
      
      if (_isDisposed) return;

      if (subCategories.isEmpty) {
        // If no subcategories, we'll fall back to fetching products for backward compatibility
        debugPrint('No subcategories found, fetching products for category: ${category.id}');
        final products = await _productService.getProductsByCategory(category.id.toString());
        
        if (products.isEmpty) {
          _hasError = true;
          _categoryData = null;
        } else {
          _categoryData = CategoryModel(
            id: category.id,
            categoryName: category.categoryName,
            description: category.description,
            image: category.image,
            subCategories: categoryData.subCategories,
            gifts: products.map((product) => GiftItem(
              id: product.id,
              name: product.name,
              description: product.description,
              images: product.images,
              brand: product.brand,
              productType: product.productType,
              rating: product.rating,
              originalPrice: product.originalPrice,
              sellingPrice: product.sellingPrice,
              inStock: product.inStock,
              isLiked: product.isLiked,
            )).toList(),
          );
          _hasError = false;
        }
      } else {
        // We have subcategories, let's use them
        _categoryData = categoryData;
        _subCategories = subCategories;
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
    if (_lastLoadTime != null && 
        DateTime.now().difference(_lastLoadTime!) < _minLoadInterval) {
      return;
    }
    _lastLoadTime = DateTime.now();
    
    // Store current like states
    final likedStates = _categoryData?.gifts
        .map((gift) => MapEntry(gift.id, gift.isLiked))
        .toList();
        
    await loadCategoryData(_category);
    
    // Restore like states
    if (likedStates != null && _categoryData != null) {
      for (var entry in likedStates) {
        final giftIndex = _categoryData!.gifts
            .indexWhere((gift) => gift.id == entry.key);
        if (giftIndex != -1) {
          _categoryData!.gifts[giftIndex].isLiked = entry.value;
        }
      }
      notifyListeners();
    }
  }

  void updateGiftLikeStatus(String giftId, bool isLiked) {
    if (_categoryData != null) {
      final giftIndex = _categoryData!.gifts.indexWhere((gift) => gift.id == giftId);
      if (giftIndex != -1) {
        _categoryData!.gifts[giftIndex].isLiked = isLiked;
        final productController = Provider.of<ProductController>(
          navigatorKey.currentContext!, 
          listen: false
        );
        productController.updateProductLikeStatus(giftId, isLiked);
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}