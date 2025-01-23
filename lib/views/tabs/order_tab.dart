import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../constants/fonts.dart';
import '../../controllers/main/tabs/orders_tab_controller.dart';
import '../../models/orders_model.dart';
import '../../widgets/shimmer/orders_shimmer.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: const OrdersTabView(),
    );
  }
}

class OrdersTabView extends StatelessWidget {
  const OrdersTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Static header that doesn't shimmer
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Orders',
                      style: AppFonts.paragraph.copyWith(
                        fontSize: 24,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'View the details and status of your past and current orders.',
                      style: AppFonts.paragraph.copyWith(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Dynamic content with shimmer
            SliverToBoxAdapter(
              child: Consumer<OrdersTabController>(
                builder: (context, controller, _) {
                  if (controller.isLoading) {
                    return const OrdersShimmer();
                  }

                  if (controller.error != null) {
                    return Center(child: Text(controller.error!));
                  }

                  return Container(
                    color: Colors.white,
                    child: Column(
                      children: List.generate(
                        controller.orders.length,
                        (index) => _OrderCard(order: controller.orders[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id}',
                  style: AppFonts.paragraph.copyWith(
                    fontSize: 16,
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
          ),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.product.images.isNotEmpty
                    ? Image.network(
                        item.product.images.first,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 40,
                            height: 40,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported, 
                              color: Colors.grey, 
                              size: 20,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.image_not_supported, 
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.quantity}x ${item.product.name}',
                        style: AppFonts.paragraph.copyWith(
                          fontSize: 14,
                          color: AppColors.black,
                        ),
                      ),
                      if (item.product.brand.isNotEmpty)
                        Text(
                          item.product.brand,
                          style: AppFonts.paragraph.copyWith(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${order.finalPrice.toStringAsFixed(2)}',
                      style: AppFonts.paragraph.copyWith(
                        fontSize: 14,
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (order.discountApplied > 0)
                      Text(
                        'You saved ₹${order.discountApplied.toStringAsFixed(2)}',
                        style: AppFonts.paragraph.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                  ],
                ),
                if (!_hasRating() && order.status == 'DELIVERED')
                  TextButton(
                    onPressed: () => _showRatingDialog(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          'Rate Order',
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
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              DateFormat('MMMM d, yyyy, h:mm a').format(order.createdAt.toLocal()),
              style: AppFonts.paragraph.copyWith(
                fontSize: 12,
                color: AppColors.textGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasRating() {
    // Check if any product in the order has a rating
    return order.items.any((item) => item.product.rating != null);
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RatingDialog(orderId: order.id.toString()),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status) {
      case 'PENDING':
        backgroundColor = const Color(0xFFFFF4E5);
        textColor = const Color(0xFFFF9800);
        displayText = 'Pending';
        break;
      case 'DELIVERED':
        backgroundColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF4CAF50);
        displayText = 'Delivered';
        break;
      case 'CANCELLED':
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
}

class RatingDialog extends StatefulWidget {
  final String orderId;

  const RatingDialog({
    super.key,
    required this.orderId,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rate Your Order',
              style: AppFonts.paragraph.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: AppColors.primaryRed,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: AppFonts.paragraph.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _rating == 0
                        ? null
                        : () {
                            context
                                .read<OrdersTabController>()
                                .rateOrder(widget.orderId, _rating);
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
