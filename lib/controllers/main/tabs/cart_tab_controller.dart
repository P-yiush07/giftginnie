import 'package:flutter/material.dart';
import '../../../models/cart_model.dart';
import '../../../services/Cart/cart_service.dart';
import '../../../controllers/main/home_controller.dart';

class CartTabController extends ChangeNotifier {
  // Use the singleton instance of CartService
  final CartService _cartService = CartService();
  final HomeController _homeController;
  bool _isLoading = false;
  String? _error;
  CartModel? _cartData;
  Set<String> _loadingItemIds = {}; 
  
  // Debug identifier
  final String _id = DateTime.now().millisecondsSinceEpoch.toString();

  bool get isLoading => _isLoading;
  String? get error => _error;
  CartModel? get cartData => _cartData;

  CartTabController(this._homeController) {
    // Listen to tab changes
    debugPrint('CartTabController initialized [ID: $_id]');
    _homeController.addListener(_onTabChange);
    initializeData();
  }

  void _onTabChange() {
    // Refresh data when returning to cart tab (index 1)
    if (_homeController.currentIndex == 1) {
      // Clear any locally stored coupon data when switching back to cart tab
      _cartService.clearLocalCouponData();
      initializeData();
    }
  }

  Future<void> initializeData() async {
    debugPrint('CartTabController [ID: $_id] initializing data');
    _isLoading = true;
    notifyListeners();
    
    try {
      _cartData = await _cartService.getCart();
      _error = null; // Clear any previous errors
      
      // Log the cart data
      debugPrint('CartTabController [ID: $_id] received cart data:');
      debugPrint('- Coupon: ${_cartData?.appliedCouponCode}');
      debugPrint('- Discount: ${_cartData?.discountAmount}');
      debugPrint('- Final Price: ${_cartData?.finalPrice}');
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('CartTabController [ID: $_id] error fetching cart: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateItemQuantity(String itemId, String variantId, int quantity) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _cartService.updateItemQuantity(itemId, variantId, quantity);
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

Future<void> removeItem(String productId, String variantId) async {
  final itemKey = "$productId-$variantId";

  _loadingItemIds.add(itemKey);
  notifyListeners();

  try {
    await _cartService.removeItem(productId, variantId);
   _cartData?.items.removeWhere(
    (item) => item.productId == productId && item.variantId == variantId,
  );
  _error = null;
  } catch (e) {
    _error = e.toString().replaceAll('Exception: ', '');
  } finally {
    // Stop loading for this specific item
    _loadingItemIds.remove(itemKey);
    notifyListeners();
  }
}

bool isItemLoading(String productId, String variantId) {
  return _loadingItemIds.contains("$productId-$variantId");
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
      
      final success = await _cartService.removeCoupon();
      if (success) {
        debugPrint('Coupon removed successfully, updating local cart data');
        
        // Instead of refreshing from API, just update our local cart model
        // to remove the coupon information
        if (_cartData != null) {
          _cartData = CartModel(
            items: _cartData!.items,
            totalPrice: _cartData!.totalPrice,
            totalItems: _cartData!.totalItems,
            // Clear all coupon-related fields
            discountAmount: null,
            finalPrice: null,
            appliedCouponCode: null,
          );
          debugPrint('Cart data updated locally to remove coupon');
        }
      } else {
        debugPrint('Failed to remove coupon');
        throw Exception('Failed to remove coupon');
      }
    } catch (e) {
      debugPrint('Error removing coupon: $e');
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    // Refresh cart data
    await initializeData();
  }
  
  // Method to update cart with coupon data without fetching from server
  void updateWithCouponData(String couponCode, double discount, double finalPrice) {
    debugPrint('CartTabController [ID: $_id] manually updating with coupon data:');
    debugPrint('- Coupon: $couponCode, Discount: $discount, Final: $finalPrice');
    
    if (_cartData != null) {
      // Create a new cart model with the same items but updated coupon info
      _cartData = CartModel(
        items: _cartData!.items,
        totalPrice: _cartData!.totalPrice,
        totalItems: _cartData!.totalItems,
        discountAmount: discount,
        finalPrice: finalPrice,
        appliedCouponCode: couponCode,
      );
      notifyListeners();
    } else {
      debugPrint('CartTabController [ID: $_id] cannot update coupon data - cart is null');
    }
  }

  @override
  void dispose() {
    debugPrint('CartTabController disposed [ID: $_id]');
    _homeController.removeListener(_onTabChange);
    super.dispose();
  }
}