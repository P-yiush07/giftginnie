import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CouponShimmer extends StatelessWidget {
  const CouponShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: List.generate(3, (index) => _buildCouponShimmerItem()),
        ),
      ),
    );
  }

  Widget _buildCouponShimmerItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Discount text shimmer
              Container(
                width: 150,
                height: 16,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              // Description shimmer
              Container(
                width: double.infinity,
                height: 12,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              // Coupon code container shimmer
              Container(
                width: 100,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
              ),
              const SizedBox(height: 16),
              // Dotted line shimmer
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              // Tap to apply text shimmer
              Center(
                child: Container(
                  width: 80,
                  height: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
