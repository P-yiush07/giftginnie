import 'package:flutter/material.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/models/coupon_model.dart';
import 'package:giftginnie_ui/services/Product/coupon_service.dart';
import 'package:giftginnie_ui/services/Cart/cart_service.dart';
import 'package:provider/provider.dart';
import 'package:giftginnie_ui/widgets/Success%20Dialog/coupon_success_dialog.dart';
import 'package:dio/dio.dart';
import '../../widgets/Snackbar/snackbar_widget.dart';

class CouponController extends ChangeNotifier {
  final CartService _cartService = CartService();
  final CouponService _couponService = CouponService();
  List<CouponModel> _coupons = [];
  List<CouponModel> _filteredCoupons = [];
  bool _isLoading = true;
  String? _error;

  List<CouponModel> get coupons => _filteredCoupons;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CouponController() {
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    try {
      _isLoading = true;
      notifyListeners();

      final allCoupons = await _couponService.getCoupons();
      
      // Filter out expired coupons by checking validUntil date
      final now = DateTime.now();
      _coupons = allCoupons.where((coupon) => 
        coupon.validUntil.isAfter(now)  // Only check if coupon is not expired
      ).toList();
      
      _filteredCoupons = _coupons;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchCoupons(String query) {
    if (query.isEmpty) {
      _filteredCoupons = _coupons;
    } else {
      _filteredCoupons = _coupons
          .where((coupon) =>
              coupon.code.toLowerCase().contains(query.toLowerCase()) ||
              (coupon.displayDescription.toLowerCase().contains(query.toLowerCase())))
          .toList();
    }
    notifyListeners();
  }

  Future<void> applyCoupon(BuildContext context, String code) async {
    // Show loading state in dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CouponSuccessDialog(
          code: code,
          savedAmount: 0, // Placeholder value while loading
          isLoading: true,
        ),
      );
    }

    try {
      final success = await _cartService.applyCoupon(code);
      
      if (success && context.mounted) {
        final coupon = _coupons.firstWhere((c) => c.code == code);
        
        // Replace loading dialog with success dialog
        Navigator.of(context).pop(); // Remove loading dialog
        final result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => CouponSuccessDialog(
            code: code,
            savedAmount: coupon.discountValue,
            isLoading: false,
          ),
        );
        
        if (result == true && context.mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Remove loading dialog
        
        // Extract error message
        String errorMessage = e is Exception ? e.toString().replaceAll('Exception: ', '') : 'Failed to apply coupon';
        
        // Use the custom snackbar
        CustomSnackbar.show(context, errorMessage);
      }
    }
  }
}