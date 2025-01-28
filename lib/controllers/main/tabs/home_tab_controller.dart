import 'package:flutter/material.dart';
import 'package:giftginnie_ui/models/CarouselItem_model.dart';
import 'package:giftginnie_ui/models/home_tab_model.dart';
import 'package:giftginnie_ui/models/category_model.dart';
import 'package:giftginnie_ui/models/popular_category_model.dart';
import 'package:giftginnie_ui/models/product_model.dart';
import 'package:giftginnie_ui/services/Product/category_service.dart';
import 'package:giftginnie_ui/services/Product/product_service.dart';
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
  bool _isLoadingPopularProducts = true;
  bool _isLoadingCarousel = true;
  bool _isLoadingPopularCategories = false;
  String? _error;
  List<CategoryModel> _categories = [];
  List<Product> _popularProducts = [];
  List<PopularCategory> _popularCategories = [];
  List<CarouselItem> _carouselItems = [];
  DateTime? _lastRefreshTime;
  static const Duration _minRefreshInterval = Duration(seconds: 2);
  bool _isDisposed = false;

  // Getters
  HomeTabModel get model => _model;
  bool get isLoading => _isLoading;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingPopularProducts => _isLoadingPopularProducts;
  bool get isLoadingCarousel => _isLoadingCarousel;
  bool get isLoadingPopularCategories => _isLoadingPopularCategories;
  String? get error => _error;
  List<CategoryModel> get categories => _categories;
  List<Product> get popularProducts => _popularProducts;
  List<PopularCategory> get popularCategories => _popularCategories;
  List<CarouselItem> get carouselItems => _carouselItems;

  HomeTabController() {
    initializeData();
  }

  Future<void> initializeData() async {
    _isLoading = true;
    _isLoadingPopularProducts = true;
    notifyListeners();

    final connectivityService = Provider.of<ConnectivityService>(
      navigatorKey.currentContext!,
      listen: false,
    );

    if (!connectivityService.isConnected) {
      _error = 'No internet connection';
      _isLoading = false;
      _isLoadingPopularProducts = false;
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
      _isLoadingPopularProducts = false;
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
      rethrow;
    }
  }

  Future<void> _fetchPopularProducts() async {
    try {
      _isLoadingPopularProducts = true;
      notifyListeners();
      
      await Future.delayed(const Duration(milliseconds: 500));
      _popularProducts = await _productService.getPopularProducts();
    } catch (e) {
      debugPrint('Error fetching popular products: $e');
      rethrow;
    } finally {
      _isLoadingPopularProducts = false;
      notifyListeners();
    }
  }

  Future<void> _fetchPopularCategories() async {
    try {
      _popularCategories = await _categoryService.getPopularCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching popular categories: $e');
      rethrow;
    }
  }

  Future<void> _fetchCarouselItems() async {
    try {
      _isLoadingCarousel = true;
      notifyListeners();
      
      final items = await _productService.getCarouselItems();
      if (!_isDisposed) {
        _carouselItems = items;
        _isLoadingCarousel = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching carousel items: $e');
      if (!_isDisposed) {
        _isLoadingCarousel = false;
        notifyListeners();
      }
      rethrow;
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
  Future<void> refreshData() async {
    // Check if enough time has passed since last refresh
    if (_lastRefreshTime != null && 
        DateTime.now().difference(_lastRefreshTime!) < _minRefreshInterval) {
      return;
    }
    
    _error = null;
    _lastRefreshTime = DateTime.now();
    
    // Set loading states for all sections including carousel
    _isLoadingCarousel = true;
    _isLoadingPopularProducts = true;
    _isLoadingCategories = true;
    notifyListeners();

    try {
      // Clear existing data
      _carouselItems = [];
      _categories = [];
      _popularProducts = [];
      notifyListeners();

      await Future.wait([
        _fetchCarouselItems(),
        _fetchCategories(),
        _fetchPopularProducts(),
      ]);

    } catch (e) {
      _error = 'Failed to refresh content';
      debugPrint('Error refreshing home data: $e');
    } finally {
      _isLoadingCarousel = false;
      _isLoadingPopularProducts = false;
      _isLoadingCategories = false;
      notifyListeners();
    }
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
    _isDisposed = true;
    // Clean up any resources
    super.dispose();
  }
}
