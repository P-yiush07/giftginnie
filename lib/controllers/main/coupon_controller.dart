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
  // Use the singleton instance of CartService
  final CartService _cartService = CartService();
  final CouponService _couponService = CouponService();
  List<CouponModel> _coupons = [];
  List<CouponModel> _filteredCoupons = [];
  bool _isLoading = true;
  String? _error;
  
  // Debug identifier to track controller lifecycle
  final String _id = DateTime.now().millisecondsSinceEpoch.toString();

  List<CouponModel> get coupons => _filteredCoupons;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CouponController() {
    debugPrint('CouponController initialized [ID: $_id]');
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    try {
      _isLoading = true;
      notifyListeners();

      final allCoupons = await _couponService.getCoupons();
      
      // Filter out expired coupons by checking validTo date
      final now = DateTime.now();
      _coupons = allCoupons.where((coupon) => 
        coupon.validTo.isAfter(now) && coupon.isActive  // Check if coupon is not expired and is active
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
      debugPrint('CouponController [ID: $_id] applying coupon: $code');
      final response = await _cartService.applyCoupon(code);
      debugPrint('CouponController [ID: $_id] coupon apply response: ${response['success']}');
      
      if (response['success'] && context.mounted) {
        // Extract discount amount from the response
        final double discount = (response['discount'] is int) 
            ? (response['discount'] as int).toDouble()
            : (response['discount'] as double);
        
        // Prepare coupon data to return
        final finalPrice = response['priceToPay'] is int 
            ? (response['priceToPay'] as int).toDouble() 
            : (response['priceToPay'] as double);
            
        final couponData = {
          'success': true,
          'couponCode': code,
          'discount': discount,
          'finalPrice': finalPrice,
        };
        
        // Store coupon data for immediate use
        debugPrint('Storing coupon data for immediate use: $couponData');
        
        // Replace loading dialog with success dialog
        Navigator.of(context).pop(); // Remove loading dialog
        
        final result = await showDialog<bool>(
          context: context,
          barrierDismissible: false, // Prevent tapping outside to dismiss
          builder: (context) => CouponSuccessDialog(
            code: code,
            savedAmount: discount,
            isLoading: false,
          ),
        );
        
        if (context.mounted) {
          // Always return coupon data whether user clicked Continue or used back button
          // The WillPopScope in the dialog ensures we get a result in both cases
          Navigator.of(context).pop(couponData);
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
  
  @override
  void dispose() {
    debugPrint('CouponController disposed [ID: $_id]');
    super.dispose();
  }
}