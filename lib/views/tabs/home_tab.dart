import 'package:flutter/material.dart';
import 'package:giftginnie_ui/config/route_transitions.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:giftginnie_ui/constants/images.dart';
import 'package:giftginnie_ui/controllers/main/user_controller.dart';
import 'package:giftginnie_ui/models/popular_category_model.dart';
import 'package:giftginnie_ui/models/product_model.dart';
import 'package:giftginnie_ui/views/address_selection_screen.dart';
import 'package:giftginnie_ui/widgets/favourite_button.dart';
import 'package:provider/provider.dart';
import '../../../controllers/main/tabs/home_tab_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:giftginnie_ui/constants/icons.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/views/search_screen.dart';
import 'package:giftginnie_ui/views/category_screen.dart';
import 'package:giftginnie_ui/constants/categories.dart';
import '../../../controllers/main/home_controller.dart';
import 'package:giftginnie_ui/models/category_model.dart';
import 'package:giftginnie_ui/widgets/shimmer/home_tab_category_shimmer.dart';
import 'package:giftginnie_ui/services/image_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:giftginnie_ui/widgets/shimmer/home_tab_products_shimmer.dart';
import 'package:giftginnie_ui/services/product_service.dart';
import 'package:giftginnie_ui/widgets/product_detail_bottom_sheet.dart';
import 'package:giftginnie_ui/widgets/shimmer/product_detail_shimmer.dart';
import 'package:shimmer/shimmer.dart';
import '../../../controllers/main/address_controller.dart';
import 'package:giftginnie_ui/widgets/shimmer/carousel_shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:giftginnie_ui/config/layout_constants.dart';
import 'package:giftginnie_ui/widgets/home_carousel.dart';

class OfferBanner {
  final String title;
  final String discount;
  final String description;
  final String buttonText;
  final String imageUrl;
  final bool isLimitedTime;

  OfferBanner({
    required this.title,
    required this.discount,
    required this.description,
    required this.buttonText,
    required this.imageUrl,
    this.isLimitedTime = false,
  });
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: ChangeNotifierProvider(
        create: (_) => HomeTabController(),
        child: const HomeTabView(),
      ),
    );
  }
}

class HomeTabView extends StatefulWidget {
  const HomeTabView({super.key});

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Set<int> _likedProducts = {};
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    
    // Add a small delay to ensure the PageController is properly initialized
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _startCarouselTimer();
      }
    });
  }

  void _loadProfile() async {
    final userController = context.read<UserController>();
    await userController.loadUserProfile();
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && _pageController.hasClients) {
        final homeTabController = context.read<HomeTabController>();
        if (homeTabController.carouselItems.isNotEmpty) {
          final nextPage = (_currentPage + 1) % homeTabController.carouselItems.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  String _convertImageUrl(String url) {
    if (url.toLowerCase().endsWith('.avif')) {
      // Try WebP format first
      return url.replaceAll('.avif', '.webp');
      // Or if you want to directly use JPEG:
      // return url.replaceAll('.avif', '.jpg');
    }
    return url;
  }

  String getAddressTypeLabel(String type) {
      switch (type.toLowerCase()) {
        case 'h':
          return 'Home';
        case 'b':
          return 'Work';
        case 'o':
          return 'Other';
        default:
          return 'Other';
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Address Section with white background
            Container(
              color: Colors.white,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 16.0),
                  child: Row(
                    children: [
                      // Profile Image
                      Consumer<UserController>(
                        builder: (context, userController, _) {
                          return Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.grey300,
                                width: 1,
                              ),
                            ),
                            child: ClipOval(
                              child: userController.isLoading
                                  ? Shimmer.fromColors(
                                      baseColor: AppColors.grey300,
                                      highlightColor: AppColors.grey100,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        color: Colors.white,
                                      ),
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: userController.userProfile?.profileImage?.isNotEmpty == true 
                                          ? userController.userProfile!.profileImage! 
                                          : 'https://static.vecteezy.com/system/resources/thumbnails/036/594/092/small_2x/man-empty-avatar-photo-placeholder-for-social-networks-resumes-forums-and-dating-sites-male-and-female-no-photo-images-for-unfilled-user-profile-free-vector.jpg',
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Shimmer.fromColors(
                                        baseColor: AppColors.grey300,
                                        highlightColor: AppColors.grey100,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Image.asset(
                                        'assets/images/placeholder.png',
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      // Location Info
                      Consumer<AddressController>(
                        builder: (context, addressController, _) {
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  SlidePageRoute(
                                    page: const AddressSelectionScreen(),
                                    direction: SlideDirection.bottom,
                                  ),
                                );
                              },
                              child: addressController.isLoading
                                  ? _buildAddressShimmer()
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          addressController.selectedAddress?.getAddressLabel() ?? 'Select Address',
                                          style: AppFonts.paragraph.copyWith(
                                            fontSize: 14,
                                            color: AppColors.textGrey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 18,
                                              color: AppColors.primaryRed,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                addressController.selectedAddress?.fullAddress ?? 'Tap to select delivery address',
                                                style: AppFonts.paragraph.copyWith(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.black,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.keyboard_arrow_down,
                                              color: AppColors.black,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                            ),
                          );
                        },
                      ),
                      // Settings Icon
                      IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: AppColors.black,
                        ),
                        onPressed: () {
                          // Get the HomeController instance and set the index to 4 (Profile tab)
                          Provider.of<HomeController>(context, listen: false).setCurrentIndex(4);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Search Bar with SVG icon
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(
                      direction: SlideDirection.right,
                      page: const SearchScreen(
                        autoFocus: true,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: TextField(
                    enabled: false,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search Gift, Products, Labels....',
                      hintStyle: AppFonts.paragraph.copyWith(
                        color: AppColors.textGrey,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
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
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Carousel Section
            Consumer<HomeTabController>(
              builder: (context, controller, _) {
                if (controller.isLoading) {
                  return const CarouselShimmer();
                }

                if (controller.carouselItems.isEmpty) {
                  return const SizedBox.shrink();
                }

                return HomeCarousel(items: controller.carouselItems);
              },
            ),
            // Categories Section
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Categories',
                    style: AppFonts.heading1.copyWith(
                      fontSize: 18,
                      color: AppColors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Consumer<HomeTabController>(
                  builder: (context, controller, _) {
                    if (controller.isLoadingCategories) {
                      return const HomeTabCategoryShimmer();
                    }
                    
                    // Split categories using the constant
                    final mainCategories = controller.categories.take(LayoutConstants.maxMainCategories).toList();
                    final overflowCategories = controller.categories.length > LayoutConstants.maxMainCategories 
                        ? controller.categories.sublist(LayoutConstants.maxMainCategories) 
                        : <CategoryModel>[];

                    return Column(
                      children: [
                        // Main category items
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: LayoutConstants.horizontalPadding),
                            itemCount: mainCategories.length,
                            itemBuilder: (context, index) {
                              final category = mainCategories[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index != mainCategories.length - 1 ? LayoutConstants.chipSpacing : 0,
                                ),
                                child: _buildCategoryItem(category: category),
                              );
                            },
                          ),
                        ),
                        // Overflow category chips
                        if (overflowCategories.isNotEmpty) ...[
                          SizedBox(height: LayoutConstants.rowSpacing * 2),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: LayoutConstants.horizontalPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var i = 0; i < overflowCategories.length; i += LayoutConstants.chipsPerRow)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      bottom: i + LayoutConstants.chipsPerRow < overflowCategories.length 
                                          ? LayoutConstants.rowSpacing 
                                          : 0
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        for (var j = i; j < i + LayoutConstants.chipsPerRow && j < overflowCategories.length; j++)
                                          Padding(
                                            padding: EdgeInsets.only(
                                              right: j % LayoutConstants.chipsPerRow != LayoutConstants.chipsPerRow - 1 
                                                  && j != overflowCategories.length - 1 
                                                  ? LayoutConstants.chipSpacing 
                                                  : 0
                                            ),
                                            child: _buildCategoryChip(overflowCategories[j]),
                                          ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
            // Increased spacing before Top Products
            const SizedBox(height: 40),
            // Top Products Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Products',
                    style: AppFonts.heading1.copyWith(
                      fontSize: 18,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Gift your loved ones the best products',
                    style: AppFonts.paragraph.copyWith(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 380,
                    child: Consumer<HomeTabController>(
                      builder: (context, controller, _) {
                        if (controller.isLoading) {
                          return const HomeTabProductsShimmer();
                        }

                        if (controller.popularProducts.isEmpty) {
                          return Center(
                            child: Text(
                              'No popular products available',
                              style: AppFonts.paragraph.copyWith(
                                color: AppColors.textGrey,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: controller.popularProducts.length,
                          itemBuilder: (context, index) {
                            return Consumer<HomeTabController>(
                              builder: (context, controller, _) {
                                final product = controller.popularProducts[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: index != controller.popularProducts.length - 1 ? 16.0 : 0,
                                  ),
                                  child: _buildProductCard(
                                    image: product.images.first,
                                    title: product.name,
                                    rating: product.rating,
                                    index: index,
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // After the Top Products section, add:
            const SizedBox(height: 40),
            
            // Popular Categories Section
            Container(
              width: double.infinity,
              height: 125,
              padding: const EdgeInsets.fromLTRB(16.0, 28.0, 16.0, 16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFFF1EB),
                    const Color(0xFFF7F5CA),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Popular Categories',
                    style: AppFonts.paragraph.copyWith(
                      fontSize: 18,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Start your day with the right mind',
                    style: AppFonts.paragraph.copyWith(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            // After the Popular Categories section
            const SizedBox(height: 16),
            Consumer<HomeTabController>(
              builder: (context, controller, _) {
                if (controller.popularCategories.isEmpty) {
                  return const SizedBox.shrink();
                }

                return SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: controller.popularCategories.length,
                    itemBuilder: (context, index) {
                      final category = controller.popularCategories[index];
                      return Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: _buildGiftCategoryCard(
                          image: category.image,
                          rating: category.averageRating,
                          title: category.categoryName,
                          categories: [category.categoryDescription],
                          isBestDeal: false,
                          category: category,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            // After the gift category ListView,
            const SizedBox(height: 24),
            Material(
              color: Colors.white,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    image: AssetImage(AppImages.webp_cta),
                    fit: BoxFit.fitHeight,
                    alignment: Alignment.centerRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'For Bulk Orders',
                        style: AppFonts.paragraph.copyWith(
                          fontSize: 14,
                          color: AppColors.textDarkGrey.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'CONNECT\nOVER\nWHATSAPP',
                        style: AppFonts.paragraph.copyWith(
                          fontSize: 24,
                          height: 1.2,
                          color: AppColors.textDarkGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),  // Added bottom spacing
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildCategoryItem({required CategoryModel category}) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                SlidePageRoute(
                  page: CategoryScreen(
                    category: category,
                  ),
                  direction: SlideDirection.right
                ),
              );
            },
            borderRadius: BorderRadius.circular(32),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.grey100,
                shape: BoxShape.circle,
              ),
              child: Container(
                width: 64,
                height: 64,
                child: ClipOval(
                  child: ImageService.getNetworkImage(
                    imageUrl: category.image,
                    width: 64,
                    height: 64,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          category.categoryName,
          style: AppFonts.paragraph.copyWith(
            fontSize: 12,
            color: AppColors.labelGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard({
    required String image,
    required String title,
    required double rating,
    required int index,
  }) {
    return Consumer<HomeTabController>(
      builder: (context, controller, _) {
        final product = controller.popularProducts[index];
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
                      onProductUpdated: (updatedProduct) {
                        // Update only this specific product in the list
                        final index = controller.popularProducts.indexWhere((p) => p.id == updatedProduct.id);
                        if (index != -1) {
                          controller.updatePopularProduct(index, updatedProduct);
                        }
                      },
                    );
                  }
                  return const ProductDetailShimmer();
                },
              ),
            );
          },
          child: Container(
            width: 280,
            height: 380,
            child: Stack(
              children: [
                // Background Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ImageService.getNetworkImage(
                    imageUrl: image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                
                // Darker Gradient Overlay - Updated opacity values
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.black.withOpacity(0.5),  // Increased from 0.2
                        AppColors.black.withOpacity(0.9),  // Increased from 0.8
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
                
                // Updated Heart Icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: FavoriteButton(
                    productId: product.id,
                    isLiked: product.isLiked,
                    onProductUpdated: (updatedProduct) {
                      // Update only this specific product in the list
                      final index = controller.popularProducts.indexWhere((p) => p.id == updatedProduct.id);
                      if (index != -1) {
                        controller.updatePopularProduct(index, updatedProduct);
                      }
                    },
                  ),
                ),
                
                // Content
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppFonts.heading1.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(CategoryModel category) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            SlidePageRoute(
              page: CategoryScreen(
                category: category,
              ),
              direction: SlideDirection.right,
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.grey300,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            category.categoryName,
            style: AppFonts.paragraph.copyWith(
              fontSize: 14,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGiftCategoryCard({
    required String image,
    required double rating,
    required String title,
    required List<String> categories,
    required bool isBestDeal,
    required PopularCategory category,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          SlidePageRoute(
            page: CategoryScreen(
              category: CategoryModel(
                id: category.categoryId,
                categoryName: category.categoryName,
                description: category.categoryDescription,
                image: category.image,
                gifts: [], // Initially empty, will be populated by CategoryScreen
              ),
            ),
            direction: SlideDirection.right,
          ),
        );
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Image - Changed from Image.asset to ImageService.getNetworkImage
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: ImageService.getNetworkImage(
                    imageUrl: image,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorWidget: Image.asset(
                      'assets/images/placeholder.png',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Dark Gradient Overlay
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
                // Best Deal Badge
                if (isBestDeal)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Best Deal',
                        style: AppFonts.paragraph.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                // Rating
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: AppColors.ratingAmber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: AppFonts.paragraph.copyWith(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.paragraph.copyWith(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    categories.join(', '),
                    style: AppFonts.heading1.copyWith(
                      fontSize: 14,
                      color: AppColors.primaryRed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: AppColors.grey300,
          highlightColor: AppColors.grey100,
          child: Container(
            width: 80,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 18,
              color: AppColors.grey300,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Shimmer.fromColors(
                baseColor: AppColors.grey300,
                highlightColor: AppColors.grey100,
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.grey300,
              size: 20,
            ),
          ],
        ),
      ],
    );
  }
}