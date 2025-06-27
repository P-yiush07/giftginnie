import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/colors.dart';
import '../../constants/fonts.dart';
import '../../models/orders_model.dart';
import 'package:intl/intl.dart';
import '../../services/Order/order_service.dart';

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    const double dashWidth = 5;
    const double dashSpace = 5;
    double startX = 0;
    final double endX = size.width;

    while (startX < endX) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderModel order;
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    // Initialize with the passed order
    order = widget.order;
    // Fetch fresh order details from API
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final freshOrder = await OrderService().getOrderById(order.id);
      
      // Log the address information from the parsed order
      debugPrint('=== PARSED ORDER ADDRESS INFO ===');
      if (freshOrder.deliveryAddress != null) {
        final addr = freshOrder.deliveryAddress!;
        debugPrint('Address parsed successfully:');
        debugPrint('  - ID: "${addr.id}"');
        debugPrint('  - Name: "${addr.name}"');
        debugPrint('  - Phone: "${addr.phoneNumber}"');
        debugPrint('  - Line 1: "${addr.addressLine1}"');
        debugPrint('  - Line 2: "${addr.addressLine2}"');
        debugPrint('  - City: "${addr.city}"');
        debugPrint('  - State: "${addr.state}"');
        debugPrint('  - Country: "${addr.country}"');
        debugPrint('  - Zipcode: "${addr.pincode}"');
        debugPrint('  - Type: "${addr.addressType}"');
      } else {
        debugPrint('No delivery address in parsed order');
      }
      debugPrint('=== END PARSED ORDER ADDRESS INFO ===');
      
      setState(() {
        order = freshOrder;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      // Show error but keep the original order data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh order details: $e'),
            backgroundColor: Colors.orange,
          ),
        );
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
            'Order Details',
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
          actions: [
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.black),
                onPressed: _fetchOrderDetails,
              ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _fetchOrderDetails,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 42),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderHeader(),
                const SizedBox(height: 16),
                _buildOrderItems(),
                const SizedBox(height: 16),
                _buildDeliveryAddress(),
                const SizedBox(height: 16),
                _buildPaymentDetails(),
                const SizedBox(height: 16), // Extra space at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: AppFonts.paragraph.copyWith(
                      fontSize: 16,
                      color: AppColors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMMM d, yyyy').format(order.createdAt.toLocal()),
                    style: AppFonts.paragraph.copyWith(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
              _buildStatusChip(order.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
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
            'Order Items',
            style: AppFonts.paragraph.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            itemBuilder: (context, index) {
              final item = order.items[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == order.items.length - 1 ? 0 : 16,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _getItemImage(item),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title.isNotEmpty ? item.title : item.product.name,
                                style: AppFonts.paragraph.copyWith(
                                  fontSize: 14,
                                  color: AppColors.black,
                                ),
                              ),
                              if (item.product.brand.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.product.brand,
                                  style: AppFonts.paragraph.copyWith(
                                    fontSize: 12,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              if (_getItemColor(item).isNotEmpty) ...[
                                Text(
                                  'Color: ${_getItemColor(item)}',
                                  style: AppFonts.paragraph.copyWith(
                                    fontSize: 12,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                              if (item.variant != null) ...[
                                Text(
                                  'Price: ₹${item.variant!.price.toStringAsFixed(2)}',
                                  style: AppFonts.paragraph.copyWith(
                                    fontSize: 12,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                              Text(
                                'Qty: ${item.quantity}',
                                style: AppFonts.paragraph.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textGrey,
                                ),
                              ),
                              if (item.isGift) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryRed.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Gift Item',
                                    style: AppFonts.paragraph.copyWith(
                                      fontSize: 10,
                                      color: AppColors.primaryRed,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                              if (order.status.toLowerCase() == 'delivered') ...[
                                const SizedBox(height: 8),
                                if (item.myRating != null)
                                  Row(
                                    children: [
                                      Text(
                                        'Your Rating: ',
                                        style: AppFonts.paragraph.copyWith(
                                          fontSize: 12,
                                          color: AppColors.textGrey,
                                        ),
                                      ),
                                      ...List.generate(5, (index) => Icon(
                                        index < (item.myRating ?? 0)
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 16,
                                        color: AppColors.primaryRed,
                                      )),
                                    ],
                                  )
                                else
                                  TextButton(
                                    onPressed: () => _showRatingDialog(context, item.productId),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      backgroundColor: AppColors.primaryRed.withOpacity(0.1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star_outline,
                                          size: 16,
                                          color: AppColors.primaryRed,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Rate Product',
                                          style: AppFonts.paragraph.copyWith(
                                            fontSize: 12,
                                            color: AppColors.primaryRed,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          '₹${(item.price).toStringAsFixed(2)}',
                          style: AppFonts.paragraph.copyWith(
                            fontSize: 14,
                            color: AppColors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: List.generate(
                50,
                (index) => Expanded(
                  child: Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    color: Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: AppFonts.paragraph.copyWith(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),
              Text(
                '₹${order.totalAmount.toStringAsFixed(2)}',
                style: AppFonts.paragraph.copyWith(
                  fontSize: 14,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Discount Applied',
                style: AppFonts.paragraph.copyWith(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),
              Text(
                '-₹${order.discount.toStringAsFixed(2)}',
                style: AppFonts.paragraph.copyWith(
                  fontSize: 14,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Final Amount',
                style: AppFonts.paragraph.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
              Text(
                '₹${order.priceToPay.toStringAsFixed(2)}',
                style: AppFonts.paragraph.copyWith(
                  fontSize: 16,
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    if (order.deliveryAddress == null) {
      return Container(
        width: double.infinity,
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
            const SizedBox(height: 16),
            Text(
              'Address information not available',
              style: AppFonts.paragraph.copyWith(
                fontSize: 14,
                color: AppColors.textGrey,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    final address = order.deliveryAddress!;
    return Container(
      width: double.infinity,
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
          const SizedBox(height: 16),
          if (address.name.isNotEmpty) ...[
            Text(
              address.name,
              style: AppFonts.paragraph.copyWith(
                fontSize: 14,
                color: AppColors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (address.phoneNumber.isNotEmpty) ...[
            Text(
              address.phoneNumber,
              style: AppFonts.paragraph.copyWith(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            [
              if (address.addressLine1.isNotEmpty) address.addressLine1,
              if (address.addressLine2.isNotEmpty) address.addressLine2,
              if (address.city.isNotEmpty && address.state.isNotEmpty) '${address.city}, ${address.state}',
              if (address.country.isNotEmpty && address.pincode.isNotEmpty) '${address.country} - ${address.pincode}',
            ].where((line) => line.isNotEmpty).join('\n'),
            style: AppFonts.paragraph.copyWith(
              fontSize: 14,
              color: AppColors.textGrey,
              height: 1.5,
            ),
          ),
          if (address.addressType.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                address.addressType,
                style: AppFonts.paragraph.copyWith(
                  fontSize: 12,
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
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
            'Payment Details',
            style: AppFonts.paragraph.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Method',
                style: AppFonts.paragraph.copyWith(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),
              Text(
                'Online Payment',
                style: AppFonts.paragraph.copyWith(
                  fontSize: 14,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Status',
                style: AppFonts.paragraph.copyWith(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),
              _buildPaymentStatusChip(order.paymentStatus),
            ],
          ),
          if (order.razorpayOrderId.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction ID',
                  style: AppFonts.paragraph.copyWith(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
                Expanded(
                  child: Text(
                    order.razorpayOrderId,
                    style: AppFonts.paragraph.copyWith(
                      fontSize: 12,
                      color: AppColors.black,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = const Color(0xFFFFF4E5);
        textColor = const Color(0xFFFF9800);
        displayText = 'Pending';
        break;
      case 'placed':
        backgroundColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF2196F3);
        displayText = 'Placed';
        break;
      case 'shipped':
        backgroundColor = const Color(0xFFF3E5F5);
        textColor = const Color(0xFF9C27B0);
        displayText = 'Shipped';
        break;
      case 'delivered':
        backgroundColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF4CAF50);
        displayText = 'Delivered';
        break;
      case 'cancelled':
        backgroundColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFE53935);
        displayText = 'Cancelled';
        break;
      default:
        backgroundColor = const Color(0xFFEFEFEF);
        textColor = const Color(0xFF757575);
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: AppFonts.paragraph.copyWith(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPaymentStatusChip(String paymentStatus) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (paymentStatus.toLowerCase()) {
      case 'paid':
        backgroundColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF4CAF50);
        displayText = 'Paid';
        break;
      case 'pending':
        backgroundColor = const Color(0xFFFFF4E5);
        textColor = const Color(0xFFFF9800);
        displayText = 'Pending';
        break;
      case 'failed':
        backgroundColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFE53935);
        displayText = 'Failed';
        break;
      default:
        backgroundColor = const Color(0xFFEFEFEF);
        textColor = const Color(0xFF757575);
        displayText = paymentStatus;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        displayText,
        style: AppFonts.paragraph.copyWith(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context, String productId) {
    int selectedRating = 0;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Rate Product',
                  style: AppFonts.paragraph.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRating = index + 1;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          index < selectedRating ? Icons.star : Icons.star_border,
                          size: 32,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: isLoading ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppFonts.paragraph.copyWith(
                            fontSize: 14,
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: selectedRating == 0 || isLoading
                            ? null
                            : () async {
                                setState(() {
                                  isLoading = true;
                                });
                                
                                try {
                                  await OrderService().rateProduct(
                                    productId,
                                    selectedRating,
                                  );
                                  
                                  if (context.mounted) {
                                    // Close dialog and update UI
                                    Navigator.pop(context, selectedRating);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to rate product: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.primaryRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor: AppColors.primaryRed.withOpacity(0.5),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Rate',
                                style: AppFonts.paragraph.copyWith(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((rating) {
      if (rating != null) {
        // Update the order item's rating immediately in the UI
        setState(() {
          final item = order.items.firstWhere((item) => item.product.id == productId);
          item.myRating = rating;
        });
      }
    });
  }

  Widget _getItemImage(OrderItem item) {
    String? imageUrl;
    
    // Priority: variant images > item images > product images
    if (item.variant != null && item.variant!.images.isNotEmpty) {
      imageUrl = item.variant!.images.first;
    } else if (item.images.isNotEmpty) {
      imageUrl = item.images.first;
    } else if (item.product.images.isNotEmpty) {
      imageUrl = item.product.images.first;
    }

    if (imageUrl != null) {
      return Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey[200],
            child: const Icon(Icons.image_not_supported),
          );
        },
      );
    } else {
      return Container(
        width: 60,
        height: 60,
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported),
      );
    }
  }

  String _getItemColor(OrderItem item) {
    // Priority: variant color > item color
    if (item.variant != null && item.variant!.color.isNotEmpty) {
      return item.variant!.color;
    } else if (item.color.isNotEmpty) {
      return item.color;
    }
    return '';
  }
}