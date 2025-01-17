import 'package:flutter/material.dart';

class CartTabController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set error(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> initializeData() async {
    isLoading = true;
    error = null;

    try {
      // TODO: Fetch cart data
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      error = 'Failed to load cart data: ${e.toString()}';
    } finally {
      isLoading = false;
    }
  }
}