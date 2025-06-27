import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/api.dart';
import '../../models/coupon_model.dart';
import '../Cache/cache_service.dart';

class CouponService {
  final Dio _dio;
  final CacheService _cacheService = CacheService();
  static const String _accessTokenKey = 'auth_token';

  CouponService() : _dio = Dio() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await _cacheService.getString(_accessTokenKey);
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<List<CouponModel>> getCoupons() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/coupons',
      );

      debugPrint('Coupons response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List)
            .map((json) => CouponModel.fromJson(json))
            .toList();
      }
      throw Exception('Failed to load coupons');
    } catch (e) {
      debugPrint('Error fetching coupons: $e');
      throw Exception('Failed to load coupons');
    }
  }

  // Future<bool> applyCoupon(String code) async {
  //   try {
  //     // TODO: Implement API call when backend is ready
  //     // final response = await _dio.post(
  //     //   '${ApiConstants.baseUrl}/coupons/apply',
  //     //   data: {'code': code},
  //     // );
  //     // return response.data['success'] as bool;

  //     // Simulate network delay
  //     await Future.delayed(const Duration(milliseconds: 800));
      
  //     // For now, just check if the coupon exists in our mock data
  //     return AppCoupons.availableCoupons.any((coupon) => coupon.code == code);
  //   } catch (e) {
  //     debugPrint('Error applying coupon: $e');
  //     throw Exception('Failed to apply coupon');
  //   }
  // }
}