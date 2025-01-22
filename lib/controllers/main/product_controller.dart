import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../services/cache_service.dart';
import '../../services/wishlist_service.dart';
import 'dart:convert';

class ProductController extends ChangeNotifier {
  final ProductService _productService = ProductService();
  final WishlistService _wishlistService = WishlistService();
  final CacheService _cacheService = CacheService();
  final Map<String, bool> _likedProducts = {};
  static const String _likedProductsKey = 'liked_products';

  ProductController() {
    _loadLikedProducts();
  }

  Future<void> _loadLikedProducts() async {
    try {
      // Load from cache first
      final cachedLikes = await _cacheService.getString(_likedProductsKey);
      if (cachedLikes != null) {
        final Map<String, dynamic> likesMap = json.decode(cachedLikes);
        _likedProducts.addAll(Map<String, bool>.from(likesMap));
      }
      
      // Sync with server
      final favouriteProducts = await _wishlistService.getFavouriteProducts();
      for (var product in favouriteProducts) {
        _likedProducts[product.id] = true;
      }
      await _saveLikedProducts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading liked products: $e');
    }
  }

  Future<void> _saveLikedProducts() async {
    await _cacheService.saveString(_likedProductsKey, json.encode(_likedProducts));
  }

  bool isProductLiked(String productId) {
    return _likedProducts[productId] ?? false;
  }

  Future<Product> toggleProductLike(String productId) async {
    final previousState = _likedProducts[productId] ?? false;
    
    try {
      // Make API call first
      await _productService.toggleFavorite(productId);
      final updatedProduct = await _productService.getProductById(productId);
      
      // Update state after successful API call
      _likedProducts[productId] = updatedProduct.isLiked;
      await _saveLikedProducts();
      notifyListeners();
      
      return updatedProduct;
    } catch (e) {
      debugPrint('Error toggling product like: $e');
      rethrow;
    }
  }

  void updateProductLikeStatus(String productId, bool isLiked) {
    if (_likedProducts[productId] != isLiked) {
      _likedProducts[productId] = isLiked;
      _saveLikedProducts();
      notifyListeners();
    }
  }
}