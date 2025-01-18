import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:giftginnie_ui/constants/icons.dart';
import 'package:giftginnie_ui/models/product_model.dart';
import 'package:giftginnie_ui/services/image_service.dart';
import 'package:giftginnie_ui/widgets/product_detail_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../controllers/main/favourite_gifts_controller.dart';
import '../widgets/shimmer/favourite_gifts_shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FavouriteGiftsScreen extends StatelessWidget {
  const FavouriteGiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FavouriteGiftsController()..loadFavouriteGifts(),
      child: const FavouriteGiftsView(),
    );
  }
}

class FavouriteGiftsView extends StatelessWidget {
  const FavouriteGiftsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'My Favourite Gift',
            style: AppFonts.paragraph.copyWith(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: Consumer<FavouriteGiftsController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return const FavouriteGiftsShimmer();
            }

            if (!controller.hasGifts) {
              return _buildEmptyState(context);
            }

            return _buildGiftsList(controller);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Image.asset(
          AppIcons.svg_heartIcon,
          width: 55,
          height: 55,
        ),
        const SizedBox(height: 16),
        Text(
          'No Favorites Yet',
          style: AppFonts.paragraph.copyWith(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'Items or places will appear here\nonce you start adding them.',
            textAlign: TextAlign.center,
            style: AppFonts.paragraph.copyWith(
              fontSize: 14,
              color: AppColors.textGrey,
            ),
          ),
        ),
        const Spacer(),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(
              'Add Favorites',
              style: AppFonts.paragraph.copyWith(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildGiftsList(FavouriteGiftsController controller) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.53,
      ),
      itemCount: controller.favouriteGifts.length,
      itemBuilder: (context, index) {
        final product = controller.favouriteGifts[index];
        return _buildGiftItem(context, product, controller);
      },
    );
  }

  Widget _buildGiftItem(BuildContext context, Product product, FavouriteGiftsController controller) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ProductDetailBottomSheet(product: product),
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
                ImageService.getNetworkImage(
                  key: ValueKey('favourite_product_${product.id}'),
                  imageUrl: product.images.isNotEmpty ? product.images[0] : 'assets/images/placeholder.png',
                  width: MediaQuery.of(context).size.width / 2 - 24,
                  height: 240,
                  fit: BoxFit.cover,
                  errorWidget: Image.asset(
                    'assets/images/placeholder.png',
                    width: MediaQuery.of(context).size.width / 2 - 24,
                    height: 240,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => controller.removeFromFavourites(product.id),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Color(0xFFFF7643),
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppFonts.paragraph.copyWith(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.productType,
                  style: AppFonts.paragraph.copyWith(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: AppFonts.paragraph.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryRed,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: AppFonts.paragraph.copyWith(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
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