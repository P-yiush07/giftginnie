import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:giftginnie_ui/controllers/main/coupon_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../models/coupon_model.dart';
import '../constants/icons.dart';
import '../widgets/shimmer/coupon_shimmer.dart';

class CouponScreen extends StatelessWidget {
  const CouponScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CouponController(),
      child: const CouponScreenView(),
    );
  }
}

class CouponScreenView extends StatelessWidget {
  const CouponScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CouponController>(
      builder: (context, controller, _) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFF9F9F9),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Container(
                color: Colors.white,
                child: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    'Coupon Code',
                    style: AppFonts.paragraph.copyWith(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  surfaceTintColor: Colors.white,
                ),
              ),
            ),
            body: controller.isLoading
                ? const CouponShimmer()
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Search Bar
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Consumer<CouponController>(
                              builder: (context, controller, _) {
                                return TextField(
                                  onChanged: controller.searchCoupons,
                                  decoration: InputDecoration(
                                    hintText: 'Search Coupon code here',
                                    hintStyle: AppFonts.paragraph.copyWith(
                                      color: Colors.grey[400],
                                    ),
                                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Coupon List
                          Consumer<CouponController>(
                            builder: (context, controller, _) {
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.coupons.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final coupon = controller.coupons[index];
                                  return _buildCouponItem(
                                    context,
                                    discount: coupon.discount,
                                    description: coupon.description,
                                    condition: coupon.condition,
                                    code: coupon.code,
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildCouponItem(BuildContext context, {
    required String discount,
    required String description,
    required String condition,
    required String code,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                AppIcons.svg_couponIcon,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  AppColors.primaryRed,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                discount + description,
                style: AppFonts.paragraph.copyWith(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            condition,
            style: AppFonts.paragraph.copyWith(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryRed,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Text(
              code,
              style: AppFonts.paragraph.copyWith(
                color: AppColors.primaryRed,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Dotted Separator and Tap To Apply
          Row(
            children: [
              Expanded(
                child: CustomPaint(
                  painter: DottedLinePainter(color: Colors.grey[300]!),
                  child: const SizedBox(height: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Tap To Apply',
              style: AppFonts.paragraph.copyWith(
                color: AppColors.primaryRed,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;
  
  DottedLinePainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
      
    const double dashWidth = 4;
    const double dashSpace = 4;
    double currentX = 0;
    
    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, 0),
        Offset(currentX + dashWidth, 0),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}