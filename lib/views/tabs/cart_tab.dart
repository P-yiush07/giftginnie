import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:giftginnie_ui/views/Address%20Screen/address_selection_screen.dart';
import 'package:giftginnie_ui/widgets/shimmer/cartItem_shimmer.dart';
import 'package:provider/provider.dart';
import '../../../controllers/main/tabs/cart_tab_controller.dart';
import 'package:giftginnie_ui/views/Product%20Screen/coupon_screen.dart';
import 'package:giftginnie_ui/config/route_transitions.dart';
import '../../../controllers/main/address_controller.dart';
import 'package:shimmer/shimmer.dart';
import '../../../controllers/main/home_controller.dart';
import '../../widgets/Error/error_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:giftginnie_ui/views/Order%20Screen/checkout_confirmation_screen.dart';
import '../../../services/connectivity_service.dart';
import '../../widgets/Internet/connectivity_wrapper.dart';

class CartTab extends StatelessWidget {
  const CartTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      onRetry: () {
        if (context.read<ConnectivityService>().isConnected) {
          context.read<CartTabController>().refreshData();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: ChangeNotifierProvider(
          create: (_) => CartTabController(context.read<HomeController>()),
          child: const CartTabView(),
        ),
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
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
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
                        
                        if (controller.error != null)
                          SizedBox(
                            height: MediaQuery.of(context).size.height - 300,
                            child: ErrorState(
                              message: controller.error!,
                              onRetry: () => controller.initializeData(),
                            ),
                          )
                        else if (controller.cartData == null || controller.cartData!.items.isEmpty)
                          SizedBox(
                            height: MediaQuery.of(context).size.height - 300,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 64,
                                    color: AppColors.grey300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Your cart is empty',
                                    style: AppFonts.paragraph.copyWith(
                                      fontSize: 18,
                                      color: AppColors.textGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Column(
                            children: [
                              Consumer<AddressController>(
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
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
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
                              const SizedBox(height: 24),
                              ...controller.cartData!.items.map((item) => 
                                _buildCartItem(
                                  id: item.id,
                                  name: item.product.name,
                                  brand: item.product.brand,
                                  originalPrice: item.product.originalPrice,
                                  sellingPrice: item.product.sellingPrice,
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
          Consumer<CartTabController>(
            builder: (context, controller, _) {
              if (controller.isLoading || controller.error != null || controller.cartData?.items.isEmpty != false) {
                return const SizedBox.shrink();
              }

              return Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(
                        page: CheckoutConfirmationScreen(
                          cartData: controller.cartData!,
                        ),
                        direction: SlideDirection.right,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(
                    'Proceed to Pay (₹${controller.cartData?.discountedPrice.toStringAsFixed(2) ?? "0.00"})',
                    style: AppFonts.paragraph.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem({
    required int id,
    required String name,
    required String brand,
    required double originalPrice,
    required double sellingPrice,
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
                      brand,
                      style: AppFonts.paragraph.copyWith(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '₹${sellingPrice.toStringAsFixed(2)}',
                          style: AppFonts.paragraph.copyWith(
                            fontSize: 14,
                            color: AppColors.primaryRed,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${originalPrice.toStringAsFixed(2)}',
                          style: AppFonts.paragraph.copyWith(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: AppColors.black
                          ),
                        ),
                      ],
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
                      onPressed: quantity <= 1 ? null : () async {
                        try {
                          await context.read<CartTabController>().updateItemQuantity(id, quantity - 1);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      },
                    ),
                    Text(
                      quantity.toString(),
                      style: AppFonts.paragraph.copyWith(
                        color: AppColors.primaryRed,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, size: 16, color: AppColors.primaryRed),
                      onPressed: () async {
                        try {
                          await context.read<CartTabController>().updateItemQuantity(id, quantity + 1);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      },
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
            onTap: () async {
              try {
                await context.read<CartTabController>().removeItem(id);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline, color: AppColors.primaryRed),
                const SizedBox(width: 8),
                Text(
                  'Remove Item',
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
    return Consumer<CartTabController>(
      builder: (context, controller, _) {
        // Show coupon only if not in loading state and coupon exists
        final cartData = controller.cartData;
        final hasCoupon = !controller.isLoading && cartData?.coupon != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Offers and Benefits',
              style: AppFonts.paragraph.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.authSocialButtonText,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: hasCoupon ? null : () async {
                final result = await Navigator.push(
                  context,
                  SlidePageRoute(
                    page: const CouponScreen(),
                    direction: SlideDirection.right,
                  ),
                );
                
                if (result == true) {
                  await context.read<CartTabController>().initializeData();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
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
                child: hasCoupon
                  ? Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/coupon.svg',
                          width: 20,
                          height: 20,
                          color: AppColors.primaryRed,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${cartData!.coupon!.code} Applied',
                            style: AppFonts.paragraph.copyWith(
                              color: AppColors.primaryRed,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              await controller.removeCoupon();
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Remove',
                            style: AppFonts.paragraph.copyWith(
                              color: AppColors.primaryRed,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/coupon.svg',
                          width: 20,
                          height: 20,
                          color: AppColors.primaryRed,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Apply Coupon',
                            style: AppFonts.paragraph.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        Text(
                          'Apply',
                          style: AppFonts.paragraph.copyWith(
                            color: AppColors.primaryRed,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          color: AppColors.primaryRed,
                          size: 20,
                        ),
                      ],
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBillDetails() {
    return Consumer<CartTabController>(
      builder: (context, controller, _) {
        final cartData = controller.cartData;
        if (cartData == null) return const SizedBox.shrink();

        final double originalPrice = cartData.originalPrice;
        final double discountedPrice = cartData.discountedPrice;
        final double discount = originalPrice - discountedPrice;
        
        // Get discount display text based on coupon type
        String discountLabel = 'Discount';
        if (cartData.coupon != null) {
          if (cartData.coupon!.discountType == 'FLAT') {
            discountLabel = 'Discount (₹${cartData.coupon!.discountValue.toStringAsFixed(0)} OFF)';
          } else {
            discountLabel = 'Discount (${cartData.coupon!.discountValue.toStringAsFixed(0)}% OFF)';
          }
        }

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
              _buildBillRow('Item Total', '₹${originalPrice.toStringAsFixed(2)}'),
              if (discount > 0)
                _buildBillRow(
                  discountLabel,
                  '-₹${discount.toStringAsFixed(2)}',
                ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(vertical: 16),
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
              _buildBillRow(
                'Total Pay', 
                '₹${discountedPrice.toStringAsFixed(2)}',
                isTotal: true
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBillRow(String label, String amount, {bool isTotal = false}) {
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