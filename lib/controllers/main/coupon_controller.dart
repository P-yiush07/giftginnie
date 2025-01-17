import 'package:flutter/material.dart';
import 'package:giftginnie_ui/models/coupon_model.dart';
import 'package:giftginnie_ui/services/coupon_service.dart';

class CouponController extends ChangeNotifier {
  final CouponService _couponService = CouponService();
  List<CouponModel> _allCoupons = [];
  List<CouponModel> _filteredCoupons = [];
  List<CouponModel> get coupons => _filteredCoupons;
  
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  CouponController() {
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _allCoupons = await _couponService.getCoupons();
      _filteredCoupons = List.from(_allCoupons);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading coupons: $e');
    }
  }

  void searchCoupons(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredCoupons = List.from(_allCoupons);
    } else {
      _filteredCoupons = _allCoupons
          .where((coupon) =>
              coupon.code.toLowerCase().contains(query.toLowerCase()) ||
              coupon.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<bool> applyCoupon(BuildContext context, String code) async {
    try {
      final success = await _couponService.applyCoupon(code);
      if (success) {
        Navigator.pop(context, code);
      }
      return success;
    } catch (e) {
      debugPrint('Error applying coupon: $e');
      return false;
    }
  }
}