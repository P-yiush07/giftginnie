import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CouponShimmer extends StatelessWidget {
  const CouponShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search bar shimmer
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              const SizedBox(height: 24),
              
              // Coupon items shimmer
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) => _buildCouponItemShimmer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCouponItemShimmer() {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and title row
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Container(
                width: 200,
                height: 16,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Condition text
          Container(
            width: double.infinity,
            height: 14,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          // Coupon code container
          Container(
            width: 120,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 16),
          // Dotted line
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          // Apply text
          Center(
            child: Container(
              width: 80,
              height: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}