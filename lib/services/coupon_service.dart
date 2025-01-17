import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_coupons.dart';
import '../models/coupon_model.dart';

class CouponService {
  final Dio _dio;

  CouponService() : _dio = Dio();

  Future<List<CouponModel>> getCoupons() async {
    try {
      // TODO: Implement API call when backend is ready
      // final response = await _dio.get('${ApiConstants.baseUrl}/coupons');
      // return (response.data['data'] as List)
      //     .map((json) => CouponModel.fromJson(json))
      //     .toList();

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Using mock data for now
      return AppCoupons.availableCoupons;
    } catch (e) {
      debugPrint('Error fetching coupons: $e');
      throw Exception('Failed to load coupons');
    }
  }

  Future<bool> applyCoupon(String code) async {
    try {
      // TODO: Implement API call when backend is ready
      // final response = await _dio.post(
      //   '${ApiConstants.baseUrl}/coupons/apply',
      //   data: {'code': code},
      // );
      // return response.data['success'] as bool;

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // For now, just check if the coupon exists in our mock data
      return AppCoupons.availableCoupons.any((coupon) => coupon.code == code);
    } catch (e) {
      debugPrint('Error applying coupon: $e');
      throw Exception('Failed to apply coupon');
    }
  }
}