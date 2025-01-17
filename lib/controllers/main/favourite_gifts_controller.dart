import 'package:flutter/material.dart';
import 'package:giftginnie_ui/models/product_model.dart';

class FavouriteGiftsController extends ChangeNotifier {
  bool _isLoading = false;
  List<Product> _favouriteGifts = [];

  bool get isLoading => _isLoading;
  List<Product> get favouriteGifts => _favouriteGifts;
  bool get hasGifts => _favouriteGifts.isNotEmpty;

  Future<void> loadFavouriteGifts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement API call to fetch favourite gifts
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      _favouriteGifts = []; // Empty for now
    } catch (e) {
      debugPrint('Error loading favourite gifts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToFavourites(Product product) async {
    // TODO: Implement add to favourites
    try {
      _favouriteGifts.add(product);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding to favourites: $e');
    }
  }

  Future<void> removeFromFavourites(String productId) async {
    // TODO: Implement remove from favourites
    try {
      _favouriteGifts.removeWhere((product) => product.id == productId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing from favourites: $e');
    }
  }
}
