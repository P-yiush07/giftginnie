import 'package:flutter/material.dart';
import 'package:giftginnie_ui/controllers/main/product_controller.dart';
import 'package:giftginnie_ui/utils/global.dart';
import '../../models/category_model.dart';
import '../../services/product_service.dart';
import '../../services/category_service.dart';
import 'package:provider/provider.dart';

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