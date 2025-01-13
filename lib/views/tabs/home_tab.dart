import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/main/tabs/home_tab_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:giftginnie_ui/constants/icons.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/constants/colors.dart';

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

  final List<OfferBanner> _offers = [
    OfferBanner(
      title: 'Get a Special Discount',
      discount: '50%',
      description: 'For all Corporate Labels',
      buttonText: 'Claim',
      imageUrl: 'assets/images/gifts.webp',
      isLimitedTime: true,
    ),
    OfferBanner(
      title: 'Exclusive Offer',
      discount: '30%',
      description: 'On Premium Gifts',
      buttonText: 'Claim',
      imageUrl: 'assets/images/gifts.webp',
      isLimitedTime: false,
    ),
    OfferBanner(
      title: 'Special Deal',
      discount: '40%',
      description: 'For Bulk Orders',
      buttonText: 'Claim',
      imageUrl: 'assets/images/gifts.webp',
      isLimitedTime: true,
    ),
  ];

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
                      Container(
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
                          child: Image.network(
                            'https://img-cdn.pixlr.com/image-generator/history/65bb506dcb310754719cf81f/ede935de-1138-4f66-8ed7-44bd16efc709/medium.webp',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Location Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HomeTown',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: AppColors.primaryRed,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '6391 Elgin St, Delaware 10299',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.black,
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Settings Icon
                      IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: AppColors.black,
                        ),
                        onPressed: () {
                          // Handle settings tap
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
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: TextField(
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search Gift, Products, Labels....',
                    hintStyle: TextStyle(
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
            // Carousel Section
            Column(
              children: [
                SizedBox(
                  height: 210,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemCount: _offers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background Image
                              Image.asset(
                                _offers[index].imageUrl,
                                fit: BoxFit.cover,
                              ),
                              // Gradient Overlay
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      AppColors.black.withOpacity(0.8),
                                      AppColors.black.withOpacity(0.5),
                                      AppColors.black.withOpacity(0.3),
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                              ),
                              // Content
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_offers[index].isLimitedTime)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFFFFF),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Text(
                                          'Limited Time',
                                          style: TextStyle(
                                            color: Color(0xFFED6E61),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    const Spacer(),
                                    Text(
                                      _offers[index].title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          'upto ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${_offers[index].discount}',
                                          style: const TextStyle(
                                            color: Color(0xFFED6E61),
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text(
                                          ' off',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              _offers[index].description,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              '|',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w200,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'T&C applied',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        FilledButton(
                                          onPressed: () {
                                            // Handle claim button tap
                                            print('Claim button tapped for offer ${index + 1}');
                                            // Add your claim logic here
                                          },
                                          style: FilledButton.styleFrom(
                                            backgroundColor: AppColors.primaryRed,
                                            minimumSize: Size.zero,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            elevation: 0, // No shadow
                                          ),
                                          child: Text(
                                            _offers[index].buttonText,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Dots Indicator
                const SizedBox(height: 16),
                Center(
                  child: DotsIndicator(
                    dotsCount: _offers.length,
                    position: _currentPage,
                    decorator: DotsDecorator(
                      color: AppColors.grey500.withOpacity(0.5),
                      activeColor: AppColors.primaryRed,
                      size: const Size(8, 8),
                      activeSize: const Size(8, 8),
                      spacing: const EdgeInsets.all(4),
                    ),
                  ),
                ),
                // Categories Section
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        children: [
                          _buildCategoryItem(
                            icon: '🏅',
                            label: 'Prizes',
                          ),
                          const SizedBox(width: 16),
                          _buildCategoryItem(
                            icon: '🎂',
                            label: 'Birthday',
                          ),
                          const SizedBox(width: 16),
                          _buildCategoryItem(
                            icon: '💑',
                            label: 'Anniversary',
                          ),
                          const SizedBox(width: 16),
                          _buildCategoryItem(
                            icon: '🐱',
                            label: 'Pet Gifts',
                          ),
                          const SizedBox(width: 16),
                          _buildCategoryItem(
                            icon: '👔',
                            label: 'Corporate',
                          ),
                          const SizedBox(width: 16),
                          _buildCategoryItem(
                            icon: '💝',
                            label: 'Valentine',
                          ),
                          const SizedBox(width: 16),
                          _buildCategoryItem(
                            icon: '🎄',
                            label: 'Christmas',
                          ),
                          const SizedBox(width: 16),
                          _buildCategoryItem(
                            icon: '👶',
                            label: 'Baby',
                          ),
                          const SizedBox(width: 16),
                          _buildCategoryItem(
                            icon: '🎓',
                            label: 'Graduation',
                          ),
                        ],
                      ),
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
                      const Text(
                        'Top Products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Gift your loved ones the best products',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 380,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          children: [
                            _buildProductCard(
                              image: 'assets/images/top_product.webp',
                              title: 'Premium Gift Box',
                              deliveryDays: 3,
                              rating: 4.5,
                              index: 0,
                            ),
                            const SizedBox(width: 16),
                            _buildProductCard(
                              image: 'assets/images/office_gift.webp',
                              title: 'Corporate Gift Set',
                              deliveryDays: 4,
                              rating: 4.8,
                              index: 1,
                            ),
                            const SizedBox(width: 16),
                            _buildProductCard(
                              image: 'assets/images/birthday_gift.webp',
                              title: 'Special Birthday Bundle',
                              deliveryDays: 2,
                              rating: 4.7,
                              index: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildCategoryItem({required String icon, required String label}) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Handle category tap
              print('Category tapped: $label');
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
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard({
    required String image,
    required String title,
    required int deliveryDays,
    required double rating,
    required int index,
  }) {
    bool isLiked = _likedProducts.contains(index);

    return GestureDetector(
      onTap: () {
        // Handle product tap
        print('Product tapped: $title');
        // Add your navigation or detail view logic here
      },
      child: Container(
        width: 280,
        height: 380,
        child: Stack(
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                image,
                height: double.infinity,
                width: double.infinity,
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
            
            // Updated Heart Icon with tap handler
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (isLiked) {
                      _likedProducts.remove(index);
                    } else {
                      _likedProducts.add(index);
                    }
                  });
                },
                child: SvgPicture.asset(
                  'assets/images/like.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    isLiked ? AppColors.primaryRed : Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            
            // Bottom Content
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16, // Decreased from 24
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Clock Icon
                      SvgPicture.asset(
                        'assets/images/alarm-clock.svg',
                        width: 16, // Decreased from 24
                        height: 16, // Decreased from 24
                        colorFilter: ColorFilter.mode(
                          AppColors.successGreen,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Delivery Text
                      Text(
                        '$deliveryDays Days Delivery',
                        style: const TextStyle(
                          fontSize: 14, // Decreased from 20
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Star Icon
                      Icon(
                        Icons.star_rounded,
                        size: 16, // Decreased from 24
                        color: AppColors.ratingAmber,
                      ),
                      const SizedBox(width: 4),
                      // Rating Text
                      Text(
                        rating.toString(),
                        style: const TextStyle(
                          fontSize: 14, // Decreased from 20
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}