import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/config/route_transitions.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/fonts.dart';
import '../../models/cart_model.dart';
import '../../models/success_model.dart';
import '../success_screen.dart';
import '../../services/Order/checkout_service.dart';
import '../../services/image_service.dart';
import '../../controllers/main/address_controller.dart';
import '../Address Screen/address_selection_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'order_failed_screen.dart';
import '../../controllers/main/home_controller.dart';
import '../home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math' show min;

class CheckoutConfirmationScreen extends StatefulWidget {
  final CartModel cartData;

  const CheckoutConfirmationScreen({
    super.key,
    required this.cartData,
  });

  @override
  State<CheckoutConfirmationScreen> createState() =>
      _CheckoutConfirmationScreenState();
}

class _CheckoutConfirmationScreenState
    extends State<CheckoutConfirmationScreen> {
  final CheckoutService _checkoutService = CheckoutService();
  bool _isProcessing = false;

  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (mounted) {
      setState(() => _isProcessing = true);

      try {
        // Log the payment ID
        print('Razorpay Payment ID: ${response.paymentId}');
        print('Razorpay Order ID: ${response.orderId}');
        print('Razorpay Signature: ${response.signature}');

        final success = await _checkoutService.verifyPayment(
          paymentId: response.paymentId!,
          orderId: response.orderId!,
          signature: response.signature!,
        );

        if (!success) {
          throw Exception('Payment verification failed');
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              model: SuccessModel(
                title: 'Order Placed Successfully!',
                message: 'Your order has been placed successfully. You can track your order in the Orders section.',
                buttonText: 'Go Back',
                showBackButton: false,
              ),
              onButtonPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (_) => HomeController(),
                      child: const HomeScreen(),
                    ),
                  ),
                  (route) => false,
                ).then((_) {
                  final homeController = Provider.of<HomeController>(context, listen: false);
                  homeController.setCurrentIndex(3);
                });
              },
            ),
          ),
          (route) => false,
        );
      } catch (e) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => OrderFailedScreen(
                message: 'Payment verification failed. Please try again.',
                onRetry: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutConfirmationScreen(
                        cartData: widget.cartData,
                      ),
                    ),
                  );
                },
                showBackButton: true,
              ),
            ),
            (route) => false, // This removes all previous routes
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OrderFailedScreen(
            message: 'Payment failed. Please try again.',
            onRetry: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckoutConfirmationScreen(
                    cartData: widget.cartData,
                  ),
                ),
              );
            },
            showBackButton: true,
          ),
        ),
        (route) => false, // This removes all previous routes
      );
    }
  }

    void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("External wallet selected: ${response.walletName}")),
      );
    }
  }

  Future<void> _processPayment() async {
    if (mounted) {
      final addressController = Provider.of<AddressController>(context, listen: false);
      if (addressController.selectedAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a delivery address'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
          ),
        );
        return;
      }
    }

    setState(() => _isProcessing = true);

    try {
      // Calculate the final amount to be paid (with coupon discount if applicable)
      final double amountToPay = widget.cartData.finalPrice ?? widget.cartData.totalPrice;
      
      // Debug log to verify the amount
      debugPrint('Processing payment: Original price: ${widget.cartData.totalPrice}, '
                'Final price: $amountToPay, '
                'Coupon: ${widget.cartData.appliedCouponCode}');
      
      // Create order with address ID and coupon code if applicable
      final orderDetails = await _checkoutService.createOrder(
        Provider.of<AddressController>(context, listen: false).selectedAddress!.id,
        couponCode: widget.cartData.appliedCouponCode,
      );
      
      // Log order details received from the backend
      debugPrint('Order created successfully with details:');
      debugPrint('- Order ID: ${orderDetails['orderId']}');
      debugPrint('- Razorpay Order ID: ${orderDetails['razorpayOrderId']}');
      debugPrint('- Amount to Pay: ${orderDetails['amount']}');
      debugPrint('- Discount Applied: ${orderDetails['discount']}');
      
      // Prepare Razorpay options
      // Note: Razorpay requires amount in paise (multiply by 100)
      var options = {
        'key': dotenv.env['RAZORPAY_KEY'],
        'amount': orderDetails['amount'] * 100,  // Convert to paise
        'name': 'GiftGinnie',
        'order_id': orderDetails['razorpayOrderId'],
        'description': 'Order Payment',
        'timeout': 300,
        'currency': orderDetails['currency'],
      };

      _razorpay.open(options);
    } catch (e) {
      // Detailed error logging
      debugPrint('Error in _processPayment: $e');
      
      if (e.toString().contains('Authentication token not found')) {
        // Handle authentication error
        debugPrint('Authentication error detected');
      } else if (e.toString().contains('DioError')) {
        // Handle network errors
        debugPrint('Network error detected');
      }
      
      if (mounted) {
        // Show a more informative error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment initialization failed: ${e.toString().substring(0, min(e.toString().length, 100))}'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'Checkout',
            style: AppFonts.paragraph.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderSummary(),
              const SizedBox(height: 16),
              _buildDeliveryAddress(),
              const SizedBox(height: 16),
              _buildPaymentMethod(),
              const SizedBox(height: 16),
              _buildBillDetails(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: AppFonts.paragraph.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.cartData.items
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ImageService.getNetworkImage(
                            imageUrl: item.variantImages.isNotEmpty
                                ? item.variantImages[0]
                                : item.productImages.isNotEmpty
                                    ? item.productImages[0]
                                    : 'assets/images/placeholder.png',
                            width: 60,
                            height: 60,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: AppFonts.paragraph.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryRed),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Qty: ${item.quantity}',
                                style: AppFonts.paragraph.copyWith(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${item.variantPrice.toStringAsFixed(2)}',
                                style: AppFonts.paragraph.copyWith(
                                  fontSize: 14,
                                  color: AppColors.primaryRed,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Consumer<AddressController>(
      builder: (context, addressController, _) {
        final selectedAddress = addressController.selectedAddress;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Address',
                  style: AppFonts.paragraph.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 18,
                      color: AppColors.primaryRed,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: selectedAddress != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedAddress.getAddressLabel(),
                                  style: AppFonts.paragraph.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  selectedAddress.fullAddress,
                                  style: AppFonts.paragraph.copyWith(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Tap to select delivery address',
                              style: AppFonts.paragraph.copyWith(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF656565),
                      size: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: AppFonts.paragraph.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.payment,
                size: 18,
                color: AppColors.primaryRed,
              ),
              const SizedBox(width: 8),
              Text(
                'Online Payment',
                style: AppFonts.paragraph.copyWith(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillDetails() {
    // Get the original total price
    final double totalPrice = widget.cartData.totalPrice;
    
    // Check if we have a coupon applied
    final bool hasCoupon = widget.cartData.appliedCouponCode != null && widget.cartData.discountAmount != null;
    
    // Set the prices based on coupon status
    final double originalPrice = totalPrice;
    final double discountedPrice = widget.cartData.finalPrice ?? totalPrice;
    final double discount = widget.cartData.discountAmount ?? 0.0;

    // Set the discount label based on coupon status
    String discountLabel = hasCoupon 
        ? 'Discount (${widget.cartData.appliedCouponCode})' 
        : 'Discount';

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bill Details',
            style: AppFonts.paragraph.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
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
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
          _buildBillRow(
            'Total Pay',
            '₹${discountedPrice.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
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
              color: isTotal ? Colors.black : Colors.grey[600],
              fontWeight: isTotal ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: AppFonts.paragraph.copyWith(
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? AppColors.primaryRed : Colors.black,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: AppColors.primaryRed,
      child: SafeArea(
        child: Container(
          width: double.infinity,
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          color: AppColors.primaryRed,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_isProcessing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TweenAnimationBuilder(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 700 + (index * 200)),
                        curve: Curves.easeInOut,
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: _isProcessing ? null : _processPayment,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pay ₹${(widget.cartData.finalPrice ?? widget.cartData.totalPrice).toStringAsFixed(2)}',
                          style: AppFonts.paragraph.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
