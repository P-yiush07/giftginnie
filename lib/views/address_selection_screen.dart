import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../models/address_model.dart';
import '../services/user_service.dart';
import 'add_address_screen.dart';
import '../config/route_transitions.dart';
import '../controllers/main/address_controller.dart';
import 'package:provider/provider.dart';
import '../widgets/shimmer/address_shimmer.dart';

class AddressSelectionScreen extends StatelessWidget {
  const AddressSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddressController(),
      child: const AddressSelectionView(),
    );
  }
}

class AddressSelectionView extends StatelessWidget {
  const AddressSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddressController>(
      builder: (context, controller, _) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFF9F9F9),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Select an Address',
                style: AppFonts.paragraph.copyWith(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: controller.loadAddresses,
              child: controller.isLoading
                  ? const AddressShimmer()
                  : controller.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                controller.error!,
                                style: AppFonts.paragraph.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: controller.loadAddresses,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          children: [
                            _buildAddAddressButton(context),
                            const SizedBox(height: 24),
                            if (controller.addresses.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  'Saved Address',
                                  style: AppFonts.heading1.copyWith(
                                    fontSize: 16,
                                    color: const Color(0xFF656565),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...controller.addresses.map((address) => _buildAddressItem(
                                    context,
                                    controller,
                                    label: controller.getAddressLabel(address),
                                    address: address.fullAddress,
                                    addressId: address.id,
                                    distance: '2km',
                                  )),
                            ],
                          ],
                        ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddAddressButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          await Navigator.push(
            context,
            SlidePageRoute(
              page: const AddAddressScreen(),
              direction: SlideDirection.right,
            ),
          );
          // Refresh addresses when returning from add address screen
          context.read<AddressController>().loadAddresses();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.add,
                  color: const Color(0xFFFF6B6B),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add Address',
                  style: AppFonts.paragraph.copyWith(
                    fontSize: 16,
                    color: const Color(0xFFFF6B6B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF656565),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressItem(BuildContext context, AddressController controller, {
    required String label,
    required String address,
    required String distance,
    required int addressId,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        distance,
                        style: AppFonts.paragraph.copyWith(
                          fontSize: 14,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '|',
                        style: AppFonts.paragraph.copyWith(
                          fontSize: 14,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: AppFonts.paragraph.copyWith(
                          fontSize: 14,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: AppFonts.paragraph.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: Color(0xFF656565),
              ),
              color: Colors.white,
              offset: const Offset(-10, 5),
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.2),
              shape: TooltipShape(arrowArc: 0.0),
              position: PopupMenuPosition.under,
              constraints: const BoxConstraints(
                minWidth: 120,
                maxWidth: 150,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () => Navigator.pop(context, 'edit'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.edit,
                            color: Color(0xFF656565),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Edit',
                            style: AppFonts.paragraph.copyWith(
                              fontSize: 14,
                              color: const Color(0xFF656565),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () => Navigator.pop(context, 'delete'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.delete,
                            color: Color(0xFF656565),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: AppFonts.paragraph.copyWith(
                              fontSize: 14,
                              color: const Color(0xFF656565),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              onSelected: (value) {
                // Handle menu item selection
                if (value == 'edit') {
                  // Handle edit action
                } else if (value == 'delete') {
                  // Handle delete action
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TooltipShape extends ShapeBorder {
  final double arrowWidth = 12.0;
  final double arrowHeight = 6.0;
  final double arrowArc;
  final double radius = 8.0;

  const TooltipShape({this.arrowArc = 0.0});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(top: arrowHeight);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(
      rect.topLeft + Offset(0, arrowHeight),
      rect.bottomRight,
    );
    
    double x = rect.right - 15;
    
    return Path()
      ..moveTo(x - arrowWidth / 2, rect.top)
      ..lineTo(x, rect.top - arrowHeight)
      ..lineTo(x + arrowWidth / 2, rect.top)
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3);
    
    canvas.drawPath(getOuterPath(rect), shadowPaint);
  }

  @override
  ShapeBorder scale(double t) => this;
}