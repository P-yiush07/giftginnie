import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:giftginnie_ui/constants/icons.dart';
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
    return ListView.builder(
      itemCount: controller.favouriteGifts.length,
      itemBuilder: (context, index) {
        final gift = controller.favouriteGifts[index];
        // TODO: Implement gift list item widget
        return Container();
      },
    );
  }
}