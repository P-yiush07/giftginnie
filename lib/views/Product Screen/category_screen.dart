import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:giftginnie_ui/constants/icons.dart';
import 'package:giftginnie_ui/controllers/main/category_controller.dart';
import 'package:giftginnie_ui/models/category_model.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/services/Product/category_service.dart';
import 'package:giftginnie_ui/services/Product/product_service.dart';
import 'package:giftginnie_ui/views/Product%20Screen/subcategory_screen.dart';
import 'package:giftginnie_ui/widgets/Item/favourite_button.dart';
import 'package:giftginnie_ui/widgets/shimmer/product_detail_shimmer.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/product_model.dart';
import '../../widgets/Item/product_detail_bottom_sheet.dart';
import '../../widgets/shimmer/category_shimmer.dart';
import '../../services/image_service.dart';
import 'no_products_view.dart';
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

  List<GiftItem> _getFilteredGifts() {
    final categoryData = _controller.categoryData;
    if (categoryData == null) return [];
    return categoryData.gifts;
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
                    // Category Title and Description
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.category.categoryName} Category',
                            style: AppFonts.paragraph.copyWith(
                              fontSize: 24,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.category.description,
                            style: AppFonts.paragraph.copyWith(
                              fontSize: 14,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Display subcategories if available
                    _controller.subCategories.isNotEmpty 
                        ? _buildSubCategories(_controller.subCategories)
                        : _buildProductGrid(widget.category),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }



  Widget _buildProductGrid(CategoryModel categoryData) {
    final filteredGifts = _getFilteredGifts();
    
    if (_controller.isLoading) {
      return const CategoryShimmer();
    }
    
    if (filteredGifts.isEmpty) {
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
      itemCount: filteredGifts.length,
      itemBuilder: (context, index) {
        return _buildGiftItem(filteredGifts[index], index);
      },
    );
  }

  Widget _buildSubCategories(List<Map<String, dynamic>> subCategories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Subcategories',
            style: AppFonts.paragraph.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subCategories.length,
          itemBuilder: (context, index) {
            final subCategory = subCategories[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: GestureDetector(
                onTap: () {
                  // Navigate to subcategory products
                  _navigateToSubcategoryProducts(subCategory);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: Image.network(
                          subCategory['image'] ?? 'assets/images/placeholder.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/placeholder.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subCategory['name'] ?? '',
                                style: AppFonts.paragraph.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subCategory['description'] ?? '',
                                style: AppFonts.paragraph.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textGrey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(subCategory['products'] as List?)?.length ?? 0} products',
                                style: AppFonts.paragraph.copyWith(
                                  fontSize: 12,
                                  color: AppColors.primaryRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(
                          Icons.chevron_right,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  
  void _navigateToSubcategoryProducts(Map<String, dynamic> subCategory) {
    debugPrint('Navigating to subcategory: ${subCategory['name']} with ID: ${subCategory['id']}');
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryRed,
        ),
      ),
    );
    
    // Fetch subcategory data with products
    CategoryService().getSubCategoryData(subCategory['id']).then((data) {
      // Close loading dialog
      Navigator.pop(context);
      
      final subCategoryData = data['subCategory'] as Map<String, dynamic>;
      final products = data['products'] as List<Product>;
      
      debugPrint('Fetched ${products.length} products for subcategory: ${subCategoryData['name']}');
      
      // Navigate to SubcategoryScreen directly with the products
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubcategoryScreen(
            subcategoryName: subCategoryData['name'],
            subcategoryDescription: subCategoryData['description'],
            products: products,
          ),
        ),
      );
    }).catchError((error) {
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading subcategory products: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
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
