import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/colors.dart';
import '../../constants/fonts.dart';
import '../../models/address_model.dart';
import '../../services/User/user_service.dart';
import 'add_address_screen.dart';
import '../../config/route_transitions.dart';
import '../../controllers/main/address_controller.dart';
import 'package:provider/provider.dart';
import '../../widgets/shimmer/address_shimmer.dart';
import 'update_address_screen.dart';

class AddressSelectionScreen extends StatelessWidget {
  const AddressSelectionScreen({super.key});

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
    required String addressId,
  }) {
    final addressModel = controller.addresses.firstWhere((a) => a.id == addressId);
    final isSelected = controller.isAddressSelected(addressModel);
    
    // Get address label based on isDefault flag
    String getAddressLabel() {
      return addressModel.isDefault ? 'Home' : 'Other';
    }

    return GestureDetector(
      onTap: () {
        controller.selectAddress(addressModel);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
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
                    Text(
                      getAddressLabel(),
                      style: AppFonts.paragraph.copyWith(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                        onTap: () {
                          // First close the popup menu
                          Navigator.pop(context);
                          // Then navigate to update screen
                          Navigator.push(
                            context,
                            SlidePageRoute(
                              page: UpdateAddressScreen(address: addressModel),
                              direction: SlideDirection.right,
                            ),
                          ).then((_) {
                            // Refresh addresses when returning from update screen
                            controller.loadAddresses();
                          });
                        },
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
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      SlidePageRoute(
                        page: UpdateAddressScreen(address: addressModel),
                        direction: SlideDirection.right,
                      ),
                    ).then((_) {
                      // Refresh addresses when returning from update screen
                      controller.loadAddresses();
                    });
                  } else if (value == 'delete') {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          'Delete Address',
                          style: AppFonts.heading1.copyWith(
                            fontSize: 18,
                            color: AppColors.black,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to delete this address?',
                          style: AppFonts.paragraph.copyWith(
                            fontSize: 14,
                            color: AppColors.textGrey,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textGrey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: Text(
                              'Cancel',
                              style: AppFonts.paragraph.copyWith(
                                fontSize: 14,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              try {
                                // Show loading indicator
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.white24,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Deleting address...',
                                              style: AppFonts.paragraph.copyWith(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      backgroundColor: AppColors.primary,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: EdgeInsets.only(
                                        bottom: MediaQuery.of(context).padding.bottom + 16,
                                        left: 16,
                                        right: 16,
                                      ),
                                      duration: const Duration(seconds: 1),
                                      elevation: 4,
                                    ),
                                  );
                                }

                                await controller.deleteAddress(addressId);

                                if (context.mounted) {
                                  // Clear any existing snackbars
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.white24,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'Address deleted successfully',
                                                style: AppFonts.paragraph.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFF4CAF50),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: EdgeInsets.only(
                                        bottom: MediaQuery.of(context).padding.bottom + 16,
                                        left: 16,
                                        right: 16,
                                      ),
                                      duration: const Duration(seconds: 2),
                                      elevation: 4,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  // Don't show error if it was just a sync issue
                                  if (e.toString().contains('Failed to sync deletion')) {
                                    return;
                                  }
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.white24,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.error_outline,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'Failed to delete address. Please try again.',
                                                style: AppFonts.paragraph.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFFE53935),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: EdgeInsets.only(
                                        bottom: MediaQuery.of(context).padding.bottom + 16,
                                        left: 16,
                                        right: 16,
                                      ),
                                      duration: const Duration(seconds: 3),
                                      elevation: 4,
                                    ),
                                  );
                                }
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: Text(
                              'Delete',
                              style: AppFonts.paragraph.copyWith(
                                fontSize: 14,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                        actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                        titlePadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                        elevation: 8,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}