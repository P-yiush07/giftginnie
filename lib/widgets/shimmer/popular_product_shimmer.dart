import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PopularProductsShimmer extends StatelessWidget {
  const PopularProductsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380, // Match your product card height
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: 3, // Number of shimmer cards to show
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(
                right: index != 2 ? 16.0 : 0,
              ),
              child: Container(
                width: 280, // Match your product card width
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}