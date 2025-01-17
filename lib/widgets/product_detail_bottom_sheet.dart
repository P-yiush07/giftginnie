import 'package:flutter/material.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:giftginnie_ui/models/product_model.dart';

class ProductDetailBottomSheet extends StatelessWidget {
  final Product product;

  const ProductDetailBottomSheet({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Content
              Expanded(
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    // Product Image with proper padding and rounded corners
                    SliverToBoxAdapter(
                      child: Stack(
                        children: [
                          // Image with rounded corners
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 300,
                              color: Colors.white,
                              child: Image.asset(
                                product.image,
                                width: double.infinity,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Drag handle on top of image
                          Positioned(
                            top: 8,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                          // Close button
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 20),
                              ),
                            ),
                          ),
                          // Favorite button
                          Positioned(
                            top: 8,
                            right: 56,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                product.isLiked ? Icons.favorite : Icons.favorite_border,
                                color: product.isLiked ? AppColors.primaryRed : Colors.grey,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Product Details
                    SliverPadding(
                      padding: const EdgeInsets.all(24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Text(
                            product.name,
                            style: AppFonts.heading1.copyWith(
                              fontSize: 24,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'INR ${product.price.toStringAsFixed(2)}',
                            style: AppFonts.heading1.copyWith(
                              fontSize: 20,
                              color: AppColors.primaryRed,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Highlights Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF5F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Highlights',
                                  style: AppFonts.heading1.copyWith(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildHighlightRow('Brand', product.brand),
                                const SizedBox(height: 12),
                                _buildHighlightRow('Product Type', product.productType),
                                const SizedBox(height: 16),
                                Text(
                                  'Information',
                                  style: AppFonts.heading1.copyWith(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  product.description,
                                  style: AppFonts.paragraph.copyWith(
                                    color: AppColors.textGrey,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Add to Cart Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                // Add to cart logic here
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryRed,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: Text(
                                'Add to Cart',
                                style: AppFonts.heading1.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                          // Ratings Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "What's other think\nabout the product",
                                  style: AppFonts.heading1.copyWith(
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF9E7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 28,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          product.rating.toStringAsFixed(1),
                                          style: AppFonts.heading1.copyWith(
                                            fontSize: 28,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Avg. Customer Ratings',
                                      style: AppFonts.paragraph.copyWith(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 50),
                          // Rating Bars
                          _buildRatingBar(5, 120, 0.9),
                          _buildRatingBar(4, 84, 0.7),
                          _buildRatingBar(3, 68, 0.5),
                          _buildRatingBar(2, 42, 0.3),
                          _buildRatingBar(1, 15, 0.1),
                          const SizedBox(height: 16),
                          // Share Rate Button
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle share rate action
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryRed,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                'Share your rate',
                                style: AppFonts.paragraph.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // All Ratings Section
                          Text(
                            'All Ratings',
                            style: AppFonts.heading1.copyWith(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // User Ratings List
                          _buildUserRating(
                            name: 'Savannah Nguyen',
                            rating: 5,
                            avatarColor: Color(0xFFFFE9E9),
                          ),
                          const SizedBox(height: 24),
                          _buildUserRating(
                            name: 'Marvin McKinney',
                            rating: 4,
                            avatarColor: Color(0xFFFFF9E7),
                          ),
                          const SizedBox(height: 24),
                          _buildUserRating(
                            name: 'Cameron Williamson',
                            rating: 5,
                            avatarColor: Color(0xFFFFECE3),
                          ),
                          const SizedBox(height: 24),
                          _buildUserRating(
                            name: 'Eleanor Pena',
                            rating: 4,
                            avatarColor: Color(0xFFE9F5FF),
                          ),
                          const SizedBox(height: 52),
                          // Illustration
                          Center(
                            child: Image.asset(
                              'assets/images/shopping_bags.webp',
                              width: 300,
                              height: 300,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHighlightRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppFonts.paragraph.copyWith(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppFonts.paragraph.copyWith(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBar(int rating, int count, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$rating',
            style: AppFonts.paragraph.copyWith(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: AppFonts.paragraph.copyWith(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRating({
    required String name,
    required int rating,
    required Color avatarColor,
  }) {
    return Row(
      children: [
        // Avatar Circle
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: avatarColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              name[0], // First letter of name
              style: AppFonts.heading1.copyWith(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Name and Rating
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppFonts.paragraph.copyWith(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}