import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:giftginnie_ui/views/address_selection_screen.dart';
import 'package:giftginnie_ui/widgets/shimmer/cartItem_shimmer.dart';
import 'package:provider/provider.dart';
import '../../../controllers/main/tabs/cart_tab_controller.dart';
import 'package:giftginnie_ui/views/coupon_screen.dart';
import 'package:giftginnie_ui/config/route_transitions.dart';
import '../../../controllers/main/address_controller.dart';
import 'package:shimmer/shimmer.dart';
import '../../../controllers/main/home_controller.dart';

class CartTab extends StatelessWidget {
  const CartTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Consumer<HomeController>(
        builder: (context, homeController, _) {
          return ChangeNotifierProvider(
            create: (_) => CartTabController(homeController),
            child: const CartTabView(),
          );
        },
      ),
    );
  }
}

class CartTabView extends StatefulWidget {
  const CartTabView({super.key});

  @override
  State<CartTabView> createState() => _CartTabViewState();
}

class _CartTabViewState extends State<CartTabView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Consumer<CartTabController>(
            builder: (context, controller, _) {
              if (controller.isLoading) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Cart',
                            style: AppFonts.paragraph.copyWith(
                              fontSize: 24,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Review and manage the items in your cart before proceeding to checkout.',
                            style: AppFonts.paragraph.copyWith(
                              fontSize: 15,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Address shimmer
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          height: 80,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Cart items shimmer
                      const CartItemsShimmer(),
                      const SizedBox(height: 16),
                      
                      // Offers section shimmer
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          height: 80,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Bill details shimmer
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          height: 200,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Cart',
                          style: AppFonts.paragraph.copyWith(
                            fontSize: 24,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Review and manage the items in your cart before proceeding to checkout.',
                          style: AppFonts.paragraph.copyWith(
                            fontSize: 15,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Address Selection Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Consumer<AddressController>(
                        builder: (context, addressController, _) {
                          return GestureDetector(
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
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    if (controller.error != null)
                      Text(controller.error!)
                    else if (controller.cartData == null || controller.cartData!.items.isEmpty)
                      const Text('Your cart is empty')
                    else
                      Column(
                        children: [
                          ...controller.cartData!.items.map((item) => 
                            _buildCartItem(
                              name: item.product.name,
                              description: item.product.description,
                              price: item.price,
                              quantity: item.quantity,
                              imageUrl: item.product.images.isNotEmpty ? item.product.images.first : null,
                            )
                          ).toList(),
                          const SizedBox(height: 16),
                          _buildOffersSection(),
                          const SizedBox(height: 24),
                          _buildBillDetails(),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: Consumer<CartTabController>(
            builder: (context, controller, _) {
              final price = controller.cartData?.items.isNotEmpty == true 
                ? controller.cartData!.items.first.price 
                : 0.0;
              
              return ElevatedButton(
                onPressed: () {
                  // Handle checkout
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Proceed to Pay (\$${price.toStringAsFixed(2)})',
                  style: AppFonts.paragraph.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem({
    required String name,
    required String description,
    required double price,
    required int quantity,
    String? imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.image_not_supported,
                            color: AppColors.grey300,
                          ),
                        )
                      : const Icon(
                          Icons.image_not_supported,
                          color: AppColors.grey300,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppFonts.paragraph.copyWith(
                        fontSize: 16,
                        color: AppColors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppFonts.paragraph.copyWith(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$' + price.toStringAsFixed(2),
                      style: AppFonts.paragraph.copyWith(
                        fontSize: 14,
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryRed, width: 1.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, size: 16, color: AppColors.primaryRed),
                      onPressed: () {},
                    ),
                    Text(
                      quantity.toString(),
                      style: AppFonts.paragraph.copyWith(
                        color: AppColors.primaryRed,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, size: 16, color: AppColors.primaryRed),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 50,
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              // Handle add item
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: AppColors.primaryRed),
                const SizedBox(width: 8),
                Text(
                  'Add Item',
                  style: AppFonts.paragraph.copyWith(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersSection() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          SlidePageRoute(
            page: const CouponScreen(),
            direction: SlideDirection.right,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Offers and Benefits',
                style: AppFonts.paragraph.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.authSocialButtonText
                ),
              ),
            ),
            Text(
              'Apply Coupon',
              style: AppFonts.paragraph.copyWith(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.primaryRed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bill Details',
            style: AppFonts.paragraph.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.authSocialButtonText
            ),
          ),
          const SizedBox(height: 16),
          _buildBillRow('Item Total', '\$14.86'),
          _buildBillRow('Delivery Cost', '\$5.00'),
          _buildBillRow('Platform Fee', '\$1.14', originalPrice: '\$2.00'),
          _buildBillRow('GST and Other Charges', '\$9.00'),
          const Divider(height: 32),
          _buildBillRow('Total Pay', '\$165.00', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String amount, {String? originalPrice, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppFonts.paragraph.copyWith(
              fontSize: 14,
              color: isTotal ? AppColors.black : AppColors.textGrey,
              fontWeight: isTotal ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          Row(
            children: [
              if (originalPrice != null) ...[
                Text(
                  originalPrice,
                  style: AppFonts.paragraph.copyWith(
                    fontSize: 14,
                    color: AppColors.textGrey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                amount,
                style: isTotal 
                  ? AppFonts.heading1.copyWith(
                      fontSize: 16,
                      color: AppColors.primaryRed,
                    )
                  : AppFonts.paragraph.copyWith(
                      fontSize: 14,
                      color: AppColors.black,
                      fontWeight: FontWeight.normal,
                    ),
              ),
            ],
          ),
        ],
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