import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:giftginnie_ui/constants/icons.dart';
import 'package:giftginnie_ui/controllers/main/category_controller.dart';
import 'package:giftginnie_ui/models/category_model.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/services/product_service.dart';
import 'package:giftginnie_ui/widgets/favourite_button.dart';
import 'package:giftginnie_ui/widgets/shimmer/product_detail_shimmer.dart';
import 'package:shimmer/shimmer.dart';
import '../models/product_model.dart';
import '../widgets/product_detail_bottom_sheet.dart';
import '../widgets/shimmer/category_shimmer.dart';
import '../services/image_service.dart';
import '../views/no_products_view.dart';
import 'package:flutter/rendering.dart';

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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  List<GiftItem> _getFilteredGifts() {
    final categoryData = _controller.categoryData;
    if (categoryData == null) return [];
    
    if (_searchQuery.isEmpty) return categoryData.gifts;
    
    return categoryData.gifts.where((gift) {
      return gift.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             gift.brand.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
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
                        '${widget.category.categoryName} Category',
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
                        widget.category.description,
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
                    _buildProductGrid(widget.category),
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
          controller: _searchController,
          style: AppFonts.paragraph.copyWith(
            color: AppColors.black,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
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

  Widget _buildProductGrid(CategoryModel categoryData) {
    final filteredGifts = _getFilteredGifts();
    
    // Only show shimmer during initial load, not during search
    if (_controller.isLoading && _searchQuery.isEmpty) {
      return const CategoryShimmer();
    }
    
    if (filteredGifts.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: Text(
            'No results found',
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
      itemCount: filteredGifts.length,
      itemBuilder: (context, index) {
        return _buildGiftItem(filteredGifts[index], index);
      },
    );
  }

  Widget _buildGiftItem(GiftItem gift, int index) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => FutureBuilder<Product>(
            future: ProductService().getProductById(gift.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ProductDetailBottomSheet(
                  product: snapshot.data!,
                  onProductUpdated: (Product updatedProduct) {
                    _controller.updateGiftLikeStatus(gift.id, updatedProduct.isLiked);
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
                    gift.images?.isNotEmpty == true ? gift.images![0] : 'assets/images/placeholder.png',
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
                    productId: gift.id,
                    isLiked: gift.isLiked,
                    onProductUpdated: (updatedProduct) {
                      _controller.updateGiftLikeStatus(gift.id, updatedProduct.isLiked);
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
                            decorationColor: AppColors.black
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
