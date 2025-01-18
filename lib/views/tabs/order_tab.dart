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
        child: Consumer<OrdersTabController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return const OrdersShimmer();
            }

            if (controller.error != null) {
              return Center(child: Text(controller.error!));
            }

            return CustomScrollView(
              slivers: [
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
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: List.generate(
                        controller.orders.length,
                        (index) => _OrderCard(order: controller.orders[index]),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.storeName,
                    style: AppFonts.paragraph.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.authSocialButtonText
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                order.giftName,
                style: AppFonts.paragraph.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.authSocialButtonText
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${order.price.toStringAsFixed(2)}',
                style: AppFonts.paragraph.copyWith(
                  fontSize: 14,
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: const Divider(height: 1),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              DateFormat('dd MMM yyyy h:mm a').format(order.orderDate),
              style: AppFonts.paragraph.copyWith(
                fontSize: 12,
                color: AppColors.textGrey,
              ),
            ),
          ),
        ),
        _buildActionButtons(context, order.status),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case OrderStatus.inProgress:
        backgroundColor = const Color(0xFFFFF4E5);
        textColor = const Color(0xFFFF9800);
        text = 'In Progress';
        break;
      case OrderStatus.delivered:
        backgroundColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF4CAF50);
        text = 'Delivered';
        break;
      case OrderStatus.cancelled:
        backgroundColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFE53935);
        text = 'Cancelled';
        break;
      case OrderStatus.refunded:
        backgroundColor = const Color(0xFFEFEFEF);
        textColor = const Color(0xFF757575);
        text = 'Refunded';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: AppFonts.paragraph.copyWith(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, OrderStatus status) {
    Widget primaryButton;
    Widget? secondaryButton;

    switch (status) {
      case OrderStatus.inProgress:
        primaryButton = _buildButton(
          text: 'Track Order',
          isPrimary: true,
          onTap: () => context.read<OrdersTabController>().trackOrder(order.id),
        );
        secondaryButton = _buildButton(
          text: 'Cancel',
          isPrimary: false,
          onTap: () {},
        );
        break;
      case OrderStatus.delivered:
        primaryButton = _buildButton(
          text: 'RATE THE ORDER',
          isPrimary: true,
          onTap: () =>
              context.read<OrdersTabController>().rateOrder(order.id, 5),
        );
        secondaryButton = _buildButton(
          text: 'REORDER',
          isPrimary: false,
          onTap: () =>
              context.read<OrdersTabController>().reorderItems(order.id),
        );
        break;
      default:
        primaryButton = _buildButton(
          text: 'REORDER',
          isPrimary: true,
          onTap: () =>
              context.read<OrdersTabController>().reorderItems(order.id),
        );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (secondaryButton != null) ...[
            Expanded(child: secondaryButton),
            const SizedBox(width: 12),
          ],
          Expanded(child: primaryButton),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isPrimary ? AppColors.primaryRed : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: isPrimary
              ? null
              : BoxDecoration(
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(24),
                ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppFonts.paragraph.copyWith(
              fontSize: 14,
              color: isPrimary ? Colors.white : AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
