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
          Navigator.pushReplacement(
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
                showBackButton: false,
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
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      Navigator.pushReplacement(
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
            showBackButton: false,
          ),
        ),
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
      // Create order
      final orderDetails = await _checkoutService.createOrder(
        Provider.of<AddressController>(context, listen: false).selectedAddress!.id,
      );
      
      var options = {
        'key': 'rzp_test_sAHiDzlP1sRvQQ',
        'amount': orderDetails['amount'] * 100,
        'name': 'GiftGinnie',
        'order_id': orderDetails['razorpayOrderId'],
        'description': 'Order Payment',
        'timeout': 300,
        'currency': orderDetails['currency'],
      };

      _razorpay.open(options);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again later.'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
            duration: Duration(seconds: 3),
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
                            imageUrl: item.product.images.isNotEmpty
                                ? item.product.images[0]
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
                                item.product.name,
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
                                '₹${item.product.sellingPrice.toStringAsFixed(2)}',
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
    final double originalPrice = widget.cartData.originalPrice;
    final double discountedPrice = widget.cartData.discountedPrice;
    final double discount = originalPrice - discountedPrice;

    String discountLabel = 'Discount';
    if (widget.cartData.coupon != null) {
      if (widget.cartData.coupon!.discountType == 'FLAT') {
        discountLabel =
            'Discount (₹${widget.cartData.coupon!.discountValue.toStringAsFixed(0)} OFF)';
      } else {
        discountLabel =
            'Discount (${widget.cartData.coupon!.discountValue.toStringAsFixed(0)}% OFF)';
      }
    }

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
                          'Pay ₹${widget.cartData.discountedPrice.toStringAsFixed(2)}',
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
