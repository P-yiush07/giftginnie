import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:giftginnie_ui/constants/icons.dart';
import 'package:giftginnie_ui/controllers/main/category_controller.dart';
import 'package:giftginnie_ui/models/category_model.dart';
import 'package:flutter/services.dart';
import '../models/product_model.dart';
import '../widgets/product_detail_bottom_sheet.dart';
import '../widgets/shimmer/category_shimmer.dart';
import '../services/image_service.dart';
import '../views/no_products_view.dart';

class CategoryScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late CategoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CategoryController(widget.category);
    _controller.loadCategoryData(widget.category);
  }

  Future<void> _loadData() async {
    debugPrint('Loading data for category: ${widget.category.id}');
    try {
      await _controller.loadCategoryData(widget.category);
      debugPrint('Data loaded successfully');
    } catch (e) {
      debugPrint('Error loading category data: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        final categoryData = _controller.categoryData;
        if (categoryData == null) {
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
            body: _controller.isLoading 
                ? const CategoryShimmer()
                : _controller.hasError || (_controller.categoryData?.gifts.isEmpty ?? true)
                    ? NoProductsView(
                        onExplore: () => Navigator.pop(context),
                      )
                    : const CategoryShimmer(),
          );
        }

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
          body: RefreshIndicator(
            onRefresh: _controller.refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Title
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                      child: Text(
                        '${categoryData.categoryName} Category',
                        style: AppFonts.paragraph.copyWith(
                          fontSize: 24,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        categoryData.description,
                        style: AppFonts.paragraph.copyWith(
                          color: AppColors.textGrey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // Search Bar
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.53,
                      ),
                      itemCount: categoryData.gifts.length,
                      itemBuilder: (context, index) {
                        return _buildGiftItem(categoryData.gifts[index], index);
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search Gift, Restaurant, Dish....',
            hintStyle: AppFonts.paragraph.copyWith(
              color: AppColors.textGrey,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset(
                AppIcons.svg_searchTabIcon,
                colorFilter: ColorFilter.mode(
                  AppColors.textGrey,
                  BlendMode.srcIn,
                ),
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGiftItem(GiftItem gift, int index) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ProductDetailBottomSheet(
            product: Product(
              id: gift.id,
              name: gift.name,
              description: gift.description,
              originalPrice: gift.originalPrice,
              sellingPrice: gift.sellingPrice,
              images: gift.images?.toList() ?? ['assets/images/placeholder.png'],
              brand: gift.brand,
              productType: gift.productType,
              inStock: gift.inStock,
              rating: gift.rating,
              isLiked: gift.isLiked,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section with specific rounded corners
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: Stack(
              children: [
                ImageService.getNetworkImage(
                  key: ValueKey('product_image_${gift.name}'),
                  imageUrl: gift.images?.isNotEmpty == true ? gift.images![0] : 'assets/images/placeholder.png',
                  width: MediaQuery.of(context).size.width / 2 - 24,
                  height: 200,
                  fit: BoxFit.cover,
                  errorWidget: Image.asset(
                    'assets/images/placeholder.png',
                    width: MediaQuery.of(context).size.width / 2 - 24,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                // Heart icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      gift.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: gift.isLiked ? AppColors.primaryRed : Colors.grey,
                      size: 14,
                    ),
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
                  gift.name,
                  style: AppFonts.paragraph.copyWith(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  gift.brand,
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
                          '₹${gift.sellingPrice.toStringAsFixed(2)}',
                          style: AppFonts.paragraph.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryRed,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${gift.originalPrice.toStringAsFixed(2)}',
                          style: AppFonts.paragraph.copyWith(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
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
                          gift.rating.toStringAsFixed(1),
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
