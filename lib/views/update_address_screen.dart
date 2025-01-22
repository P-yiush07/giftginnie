import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../services/user_service.dart';
import '../models/address_model.dart';
import 'package:provider/provider.dart';
import '../controllers/main/address_controller.dart';

class UpdateAddressScreen extends StatefulWidget {
  final AddressModel address;
  
  const UpdateAddressScreen({
    super.key,
    required this.address,
  });

  @override
  State<UpdateAddressScreen> createState() => _UpdateAddressScreenState();
}

class _UpdateAddressScreenState extends State<UpdateAddressScreen> {
  String selectedType = '';
  TextEditingController addressController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedType = _getAddressTypeFromCode(widget.address.addressType);
    addressController.text = widget.address.addressLine1;
    areaController.text = widget.address.addressLine2;
    cityController.text = widget.address.city;
    stateController.text = widget.address.state;
    pincodeController.text = widget.address.pincode;
  }

  String _getAddressTypeFromCode(String code) {
    switch (code.toLowerCase()) {
      case 'h':
        return 'Home';
      case 'b':
        return 'Work';
      case 'o':
        return 'Other';
      default:
        return 'Home';
    }
  }

  @override
  Widget build(BuildContext context) {
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
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Update Address',
            style: AppFonts.paragraph.copyWith(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          surfaceTintColor: Colors.white,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Save Address as*',
                  style: AppFonts.paragraph.copyWith(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildAddressTypeChip('Home'),
                      _buildAddressTypeChip('Work'),
                      _buildAddressTypeChip('Other'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  label: 'Address',
                  hint: 'Enter Flat / house no / floor / building',
                  required: true,
                  controller: addressController,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Area, Sector, Locality',
                  hint: 'Enter area',
                  required: true,
                  controller: areaController,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'City',
                  hint: 'Enter city name',
                  required: true,
                  controller: cityController,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Landmark',
                  hint: 'Nearby Landmark (Optional)',
                  controller: landmarkController,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'State',
                  hint: 'Enter state',
                  required: true,
                  controller: stateController,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Country',
                  hint: 'India',
                  enabled: false,
                  initialValue: 'India',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Pincode',
                  hint: 'Enter 6-digit pincode',
                  required: true,
                  controller: pincodeController,
                  isPhoneNumber: true,
                  maxLength: 6,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            MediaQuery.of(context).padding.bottom + 32,
          ),
          child: FilledButton(
            onPressed: isLoading ? null : _handleUpdateAddress,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Update Address',
                    style: AppFonts.paragraph.copyWith(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // Reuse the widget building methods from AddAddressScreen
  Widget _buildAddressTypeChip(String type) {
    final isSelected = selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: GestureDetector(
        onTap: () => setState(() => selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIconForType(type),
                size: 16,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                type,
                style: AppFonts.paragraph.copyWith(
                  fontSize: 14,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Home':
        return Icons.home_outlined;
      case 'Work':
        return Icons.work_outline;
      case 'Hotel':
        return Icons.hotel_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    bool required = false,
    IconData? prefixIcon,
    TextEditingController? controller,
    bool isPhoneNumber = false,
    int? maxLength,
    bool enabled = true,
    String? initialValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          required ? '$label*' : label,
          style: AppFonts.paragraph.copyWith(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: initialValue != null ? null : controller,
          initialValue: initialValue,
          enabled: enabled,
          keyboardType: isPhoneNumber ? TextInputType.number : TextInputType.text,
          maxLength: maxLength ?? (isPhoneNumber ? 10 : null),
          inputFormatters: isPhoneNumber
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          style: AppFonts.paragraph.copyWith(
            fontSize: 14,
            color: enabled ? AppColors.black : Colors.grey,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppFonts.paragraph.copyWith(
              fontSize: 14,
              color: Colors.grey,
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            counterText: '',
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey, size: 20)
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Future<void> _handleUpdateAddress() async {
    final userService = UserService();
    
    setState(() {
      isLoading = true;
    });

    try {
      String addressType = selectedType == 'Home' ? 'H' : 
                          selectedType == 'Work' ? 'B' : 'O';

      await userService.updateAddress(
        addressId: widget.address.id,
        addressLine1: addressController.text,
        addressLine2: areaController.text,
        city: cityController.text,
        state: stateController.text,
        pincode: pincodeController.text,
        addressType: addressType,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Address updated successfully',
                  style: AppFonts.paragraph.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 16,
              right: 16,
            ),
          ),
        );
        
        // Refresh the address list before popping
        context.read<AddressController>().loadAddresses();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    addressController.dispose();
    areaController.dispose();
    cityController.dispose();
    landmarkController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    super.dispose();
  }
}
