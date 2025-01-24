import 'package:flutter/material.dart';
import 'package:giftginnie_ui/models/CarouselItem_model.dart';
import 'package:giftginnie_ui/models/home_tab_model.dart';
import 'package:giftginnie_ui/models/category_model.dart';
import 'package:giftginnie_ui/models/popular_category_model.dart';
import 'package:giftginnie_ui/models/product_model.dart';
import 'package:giftginnie_ui/services/category_service.dart';
import 'package:giftginnie_ui/services/product_service.dart';
import 'package:giftginnie_ui/utils/global.dart';
import 'package:provider/provider.dart';
import 'package:giftginnie_ui/controllers/main/product_controller.dart';
import 'package:giftginnie_ui/services/connectivity_service.dart';

class HomeTabController extends ChangeNotifier {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final HomeTabModel _model = HomeTabModel();
  bool _isLoading = true;
  bool _isLoadingCategories = true;
  String? _error;
  List<CategoryModel> _categories = [];
  List<Product> _popularProducts = [];
  List<PopularCategory> _popularCategories = [];
  List<CarouselItem> _carouselItems = [];

  // Getters
  HomeTabModel get model => _model;
  bool get isLoading => _isLoading;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get error => _error;
  List<CategoryModel> get categories => _categories;
  List<Product> get popularProducts => _popularProducts;
  List<PopularCategory> get popularCategories => _popularCategories;
  List<CarouselItem> get carouselItems => _carouselItems;

  HomeTabController() {
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    _isLoading = true;
    notifyListeners();

    final connectivityService = Provider.of<ConnectivityService>(
      navigatorKey.currentContext!,
      listen: false,
    );

    if (!connectivityService.isConnected) {
      _error = 'No internet connection';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // Fetch carousel items first for faster appearance
      await _fetchCarouselItems();
      
      // Then fetch the rest in parallel
      await Future.wait([
        _fetchCategories(),
        _fetchPopularProducts(),
        _fetchPopularCategories(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchCategories() async {
    _isLoadingCategories = true;
    notifyListeners();

    try {
      _categories = await _categoryService.getCategories();
      
      _isLoadingCategories = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> _fetchPopularProducts() async {
    try {
      _popularProducts = await _productService.getPopularProducts();
      // Initialize like states in ProductController
      final productController = Provider.of<ProductController>(navigatorKey.currentContext!, listen: false);
      for (var product in _popularProducts) {
        productController.updateProductLikeStatus(product.id, product.isLiked);
      }
    } catch (e) {
      debugPrint('Error fetching popular products: $e');
    }
  }

  Future<void> _fetchPopularCategories() async {
    try {
      _popularCategories = await _categoryService.getPopularCategories();
      
      // Debug logging
      debugPrint('Popular Categories Response:');
      for (var category in _popularCategories) {
        debugPrint('''
          Category ID: ${category.categoryId}
          Name: ${category.categoryName}
          Image URL: ${category.image}
          Rating: ${category.averageRating}
          Description: ${category.categoryDescription}
          ----------------------------------------
        ''');
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching popular categories: $e');
    }
  }

  Future<void> _fetchCarouselItems() async {
    try {
      _carouselItems = await _productService.getCarouselItems();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching carousel items: $e');
    }
  }

  // Setters
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set error(String? value) {
    _error = value;
    notifyListeners();
  }

  // Initialize data
  Future<void> initializeData() async {
    isLoading = true;
    error = null;

    try {
      // TODO: Fetch categories
      await _fetchCategories();
      
      // TODO: Fetch featured products
      await _fetchFeaturedProducts();
      
      // TODO: Fetch trending products
      await _fetchTrendingProducts();
      
      // TODO: Fetch special offers
      await _fetchSpecialOffers();
      
    } catch (e) {
      error = 'Failed to load home data: ${e.toString()}';
    } finally {
      isLoading = false;
    }
  }

  Future<void> _fetchFeaturedProducts() async {
    // TODO: Implement featured products fetching
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _fetchTrendingProducts() async {
    // TODO: Implement trending products fetching
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _fetchSpecialOffers() async {
    // TODO: Implement special offers fetching
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> refreshData() async {
    await initializeData();
  }

  void handleCategoryTap(String categoryId) {
    // TODO: Implement category navigation
  }

  void handleProductTap(String productId) {
    // TODO: Implement product details navigation
  }

  void handleOfferTap(String offerId) {
    // TODO: Implement offer details navigation
  }

  Future<void> refreshPopularProducts() async {
    try {
      _isLoading = true;
      notifyListeners();
      _popularProducts = await _productService.getPopularProducts();
      // Update global product controller with latest like statuses
      final productController = Provider.of<ProductController>(navigatorKey.currentContext!, listen: false);
      for (var product in _popularProducts) {
        productController.updateProductLikeStatus(product.id, product.isLiked);
      }
    } catch (e) {
      debugPrint('Error refreshing popular products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updatePopularProduct(int index, Product updatedProduct) {
    if (index >= 0 && index < _popularProducts.length) {
      _popularProducts[index] = updatedProduct;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Clean up any resources
    super.dispose();
  }
}
