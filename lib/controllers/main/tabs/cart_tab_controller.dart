import 'package:flutter/material.dart';
import '../../../models/cart_model.dart';
import '../../../services/Cart/cart_service.dart';
import '../../../controllers/main/home_controller.dart';

class CartTabController extends ChangeNotifier {
  final CartService _cartService = CartService();
  final HomeController _homeController;
  bool _isLoading = false;
  String? _error;
  CartModel? _cartData;

  bool get isLoading => _isLoading;
  String? get error => _error;
  CartModel? get cartData => _cartData;

  CartTabController(this._homeController) {
    // Listen to tab changes
    _homeController.addListener(_onTabChange);
    initializeData();
  }

  void _onTabChange() {
    // Refresh data when returning to cart tab (index 1)
    if (_homeController.currentIndex == 1) {
      initializeData();
    }
  }

  Future<void> initializeData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _cartData = await _cartService.getCart();
      _error = null; // Clear any previous errors
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateItemQuantity(int itemId, int quantity) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _cartService.updateItemQuantity(itemId, quantity);
      await initializeData(); // Refresh cart data
    } catch (e) {
      _error = 'Failed to update quantity: ${e.toString()}';
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeItem(int itemId) async {
    try {
      _isLoading = true; // Set loading state immediately
      notifyListeners();
      
      await _cartService.removeItem(itemId);
      await initializeData(); // Refresh cart data
    } catch (e) {
      _error = 'Failed to remove item: ${e.toString()}';
      notifyListeners();
      rethrow; // Rethrow to handle in UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(String productId, int quantity) async {
    try {
      await _cartService.addItem(productId, quantity);
      await initializeData(); // Refresh cart data
    } catch (e) {
      _error = 'Failed to add item: ${e.toString()}';
      notifyListeners();
    }
  }

  // Future<void> applyCoupon(String couponCode) async {
  //   try {
  //     await _cartService.applyCoupon(couponCode);
  //     await initializeData(); // Refresh cart data
  //   } catch (e) {
  //     _error = 'Failed to apply coupon: ${e.toString()}';
  //     notifyListeners();
  //   }
  // }

  Future<void> removeCoupon() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _cartService.removeCoupon();
      await initializeData(); // This will refresh the cart data
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> refreshData() async {
    // Refresh cart data
    await initializeData();
  }

  @override
  void dispose() {
    _homeController.removeListener(_onTabChange);
    super.dispose();
  }
}