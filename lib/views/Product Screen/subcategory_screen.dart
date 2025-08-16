import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:giftginnie_ui/controllers/main/tabs/cart_tab_controller.dart';
import 'package:giftginnie_ui/models/category_model.dart';
import 'package:giftginnie_ui/models/product_model.dart';
import 'package:giftginnie_ui/services/Product/product_service.dart';
import 'package:giftginnie_ui/views/Product%20Screen/floating_cart_widget.dart';
import 'package:giftginnie_ui/widgets/Item/favourite_button.dart';
import 'package:giftginnie_ui/widgets/Item/product_detail_bottom_sheet.dart';
import 'package:giftginnie_ui/widgets/shimmer/product_detail_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SubcategoryScreen extends StatefulWidget {
  final String subcategoryName;
  final String subcategoryDescription;
  final List<Product> products;

  const SubcategoryScreen({
    super.key,
    required this.subcategoryName,
    required this.subcategoryDescription,
    required this.products,
  });

  @override
  State<SubcategoryScreen> createState() => _SubcategoryScreenState();
}

class _SubcategoryScreenState extends State<SubcategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        surfaceTintColor: Colors.white,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              // For now, just a dummy refresh
              return Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subcategory Title and Description
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.subcategoryName,
                            style: AppFonts.paragraph.copyWith(
                              fontSize: 24,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.subcategoryDescription,
                            style: AppFonts.paragraph.copyWith(
                              fontSize: 14,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildProductGrid(),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
          // Floating Cart
          Consumer<CartTabController>(
            builder: (context, cartController, child) {
              if (cartController.isLoading) {
                return const SizedBox.shrink(); // hide while loading
              }

              if (cartController.cartData == null ||
                  cartController.cartData!.items.isEmpty) {
                return const SizedBox.shrink(); // hide if empty
              }

              return FloatingCartWidget(cartController: cartController);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    if (widget.products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: Text(
            'No products found',
            style: AppFonts.paragraph.copyWith(
              color: AppColors.textGrey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.53,
      ),
      itemCount: widget.products.length,
      itemBuilder: (context, index) {
        final product = widget.products[index];
        return _buildProductItem(product, index);
      },
    );
  }

  Widget _buildProductItem(Product product, int index) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => FutureBuilder<Product>(
            future: ProductService().getProductById(product.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ProductDetailBottomSheet(
                  product: snapshot.data!,
                  onProductUpdated: (Product updatedProduct) {
                    setState(() {
                      // Update like status if needed
                      widget.products[index].isLiked = updatedProduct.isLiked;
                    });
                  },
                );
              }
              return const ProductDetailShimmer();
            },
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 24,
                  height: 210,
                  child: Image.network(
                    product.images.isNotEmpty
                        ? product.images[0]
                        : 'assets/images/placeholder.png',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          color: Colors.white,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/placeholder.png',
                        width: MediaQuery.of(context).size.width / 2 - 24,
                        height: 200,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: FavoriteButton(
                    productId: product.id,
                    isLiked: product.isLiked,
                    onProductUpdated: (updatedProduct) {
                      setState(() {
                        product.isLiked = updatedProduct.isLiked;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Details Section
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppFonts.paragraph.copyWith(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  product.brand,
                  style: AppFonts.paragraph.copyWith(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '₹${product.sellingPrice.toStringAsFixed(2)}',
                          style: AppFonts.paragraph.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryRed,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${product.originalPrice.toStringAsFixed(2)}',
                          style: AppFonts.paragraph.copyWith(
                              fontSize: 12,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: AppColors.black),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: AppFonts.paragraph.copyWith(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
