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
import '../../../models/cart_model.dart';

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
                              
                              // Cart items list - new implementation for updated API
                              ...controller.cartData!.items.map((item) => 
                                _buildNewCartItem(
                                  item: item,
                                  controller: controller,
                                )
                              ).toList(),
                              
                              const SizedBox(height: 16),
                              
                              // Offers and coupon section
                              _buildOffersSection(),
                              
                              const SizedBox(height: 24),
                              
                              // Bill details section
                              Container(
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
                                child: Builder(
                                  builder: (context) {
                                    // Debug print to verify we have coupon data
                                    debugPrint('Displaying cart with: ' +
                                      'Coupon: ${controller.cartData!.appliedCouponCode}, ' +
                                      'Discount: ${controller.cartData!.discountAmount}, ' +
                                      'Final Price: ${controller.cartData!.finalPrice}');
                                    
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                    Text(
                                      'Price Details',
                                      style: AppFonts.paragraph.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Item total
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Item Total (${controller.cartData!.totalItems} items)',
                                          style: AppFonts.paragraph.copyWith(
                                            color: AppColors.textGrey,
                                          ),
                                        ),
                                        Text(
                                          '₹${controller.cartData!.totalPrice.toStringAsFixed(2)}',
                                          style: AppFonts.paragraph.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    // Discount (only if a coupon is applied)
                                    if (controller.cartData!.discountAmount != null && controller.cartData!.discountAmount! > 0) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Discount ',
                                                style: AppFonts.paragraph.copyWith(
                                                  color: Colors.green,
                                                ),
                                              ),
                                              if (controller.cartData!.appliedCouponCode != null)
                                                Text(
                                                  '(${controller.cartData!.appliedCouponCode})',
                                                  style: AppFonts.paragraph.copyWith(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          Text(
                                            '- ₹${controller.cartData!.discountAmount!.toStringAsFixed(2)}',
                                            style: AppFonts.paragraph.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Divider(),
                                    ),
                                    
                                    // Total amount (with discount if applicable)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total Amount',
                                          style: AppFonts.paragraph.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          '₹${(controller.cartData!.finalPrice ?? controller.cartData!.totalPrice).toStringAsFixed(2)}',
                                          style: AppFonts.paragraph.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: AppColors.primaryRed,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                    );
                                  }
                                ),
                              ),
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
                    'Proceed to Pay (₹${(controller.cartData?.finalPrice ?? controller.cartData?.totalPrice ?? 0.0).toStringAsFixed(2)})',
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
  
  Widget _buildAddressShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: AppColors.grey300,
          highlightColor: AppColors.grey100,
          child: Container(
            width: 80,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 8),
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
  
  Widget _buildOffersSection() {
    return Consumer<CartTabController>(
      builder: (context, controller, _) {
        // Check if there's an applied coupon in the cart data
        final hasCoupon = controller.cartData?.appliedCouponCode != null;
        
        // Debug print to verify coupon status
        debugPrint('Building offers section - Has coupon: $hasCoupon, Code: ${controller.cartData?.appliedCouponCode}');

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
                try {
                  final result = await Navigator.push(
                    context,
                    SlidePageRoute(
                      page: const CouponScreen(),
                      direction: SlideDirection.right,
                    ),
                  );
                  
                  debugPrint('Returned from coupon screen with result: $result');
                  
                  if (result != null) {
                    // Get the controller
                    final controller = Provider.of<CartTabController>(context, listen: false);
                    
                    // Check if we received coupon data map
                    if (result is Map<String, dynamic> && result['success'] == true) {
                      debugPrint('Applying coupon data to cart: ${result['couponCode']}');
                      
                      // Update the controller with coupon data without fetching from server
                      controller.updateWithCouponData(
                        result['couponCode'] as String,
                        result['discount'] as double,
                        result['finalPrice'] as double,
                      );
                    } else if (result == true) {
                      // Fallback to old behavior if we just get a boolean result
                      debugPrint('Received boolean result, triggering simple UI update');
                      controller.notifyListeners();
                    }
                  }
                } catch (e) {
                  debugPrint('Error handling coupon result: $e');
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
                            'Coupon ${controller.cartData?.appliedCouponCode ?? ""} Applied',
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
  
  // New cart item builder for the updated API response format
  Widget _buildNewCartItem({
    required CartItem item,
    required CartTabController controller,
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
                  child: item.variantImages.isNotEmpty
                      ? Image.network(
                          item.variantImages.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.image_not_supported,
                            color: AppColors.grey300,
                          ),
                        )
                      : item.productImages.isNotEmpty
                          ? Image.network(
                              item.productImages.first,
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppFonts.paragraph.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.variantColor,
                      style: AppFonts.paragraph.copyWith(
                        color: AppColors.textGrey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '₹${item.variantPrice.toStringAsFixed(2)}',
                          style: AppFonts.paragraph.copyWith(
                            color: AppColors.primaryRed,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Delete button
              TextButton.icon(
                onPressed: () async {
                  // Show confirmation dialog
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Remove Item'),
                      content: const Text('Are you sure you want to remove this item from your cart?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  );
                  
                  if (shouldDelete == true) {
                    try {
                      // TODO: Implement removeItem with new API
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Remove functionality will be implemented soon')),
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red[700],
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                icon: const Icon(Icons.delete_outline, size: 20),
                label: const Text('Remove'),
              ),
              
              // Quantity selector
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Minus button
                    InkWell(
                      onTap: item.quantity > 1 ? () async {
                        try {
                      controller.updateItemQuantity(
                        item.productId,
                        item.variantId,
                        item.quantity - 1,
                      );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      } : null,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.remove,
                          size: 16,
                          color: item.quantity > 1 ? AppColors.black : AppColors.grey300,
                        ),
                      ),
                    ),
                    
                    // Quantity text
                    Container(
                      constraints: const BoxConstraints(minWidth: 30),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity}',
                        style: AppFonts.paragraph.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    // Plus button
                    InkWell(
                      onTap: item.quantity < (item.variantStock) ? () async {
                        try {
                        controller.updateItemQuantity(
                        item.productId,
                        item.variantId,
                        item.quantity + 1,
                      );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      } : null,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.add,
                          size: 16,
                          color: item.quantity < (item.variantStock) ? AppColors.black : AppColors.grey300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}