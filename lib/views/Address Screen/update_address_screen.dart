import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/colors.dart';
import '../../constants/fonts.dart';
import '../../services/User/user_service.dart';
import '../../models/address_model.dart';
import 'package:provider/provider.dart';
import '../../controllers/main/address_controller.dart';
import '../../constants/texts.dart';

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
  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  bool isLoading = false;
  bool isDefault = false;
  final List<String> indianStates = AddressTexts.indianStates;
  List<String> filteredStates = [];

  @override
  void initState() {
    super.initState();
    // Initialize values from existing address
    isDefault = widget.address.isDefault;
    fullNameController.text = widget.address.fullName?.toString() ?? '';
    phoneController.text = widget.address.phone?.toString() ?? '';
    addressController.text = widget.address.addressLine1;
    areaController.text = widget.address.addressLine2 ?? '';
    cityController.text = widget.address.city;
    stateController.text = widget.address.state;
    pincodeController.text = widget.address.zipCode;

    // Add listeners to all required controllers
    fullNameController.addListener(() => setState(() {}));
    phoneController.addListener(() => setState(() {}));
    addressController.addListener(() => setState(() {}));
    areaController.addListener(() => setState(() {}));
    cityController.addListener(() => setState(() {}));
    stateController.addListener(() => setState(() {}));
    pincodeController.addListener(() => setState(() {}));
  }

  // No longer needed but keeping for reference
  String _getAddressTypeFromCode(String? code) {
    // We'll just return Home for default addresses and Other for non-default
    return 'Home';
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
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  required: true,
                  controller: fullNameController,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  required: true,
                  controller: phoneController,
                  isPhoneNumber: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: isDefault,
                      onChanged: (value) {
                        setState(() {
                          isDefault = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    Text(
                      'Save as default address',
                      style: AppFonts.paragraph.copyWith(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
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
                _buildStateDropdown(),
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
            onPressed: isLoading || !_isFormValid() 
                ? null 
                : _handleUpdateAddress,
            style: FilledButton.styleFrom(
              backgroundColor: _isFormValid() 
                  ? AppColors.primary 
                  : Colors.grey.shade300,
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
                      color: _isFormValid() ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // Address type removed

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

  Widget _buildStateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'State*',
          style: AppFonts.paragraph.copyWith(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: stateController,
          onChanged: (value) {
            setState(() {
              filteredStates = indianStates
                  .where((state) => state.toLowerCase().contains(value.toLowerCase()))
                  .toList();
            });
          },
          onTap: () {
            setState(() {
              filteredStates = indianStates;
            });
          },
          style: AppFonts.paragraph.copyWith(
            fontSize: 14,
            color: AppColors.black,
          ),
          decoration: InputDecoration(
            hintText: 'Select state',
            hintStyle: AppFonts.paragraph.copyWith(
              fontSize: 14,
              color: Colors.grey,
            ),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: const Icon(Icons.arrow_drop_down),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        if (filteredStates.isNotEmpty && stateController.text.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredStates.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    filteredStates[index],
                    style: AppFonts.paragraph.copyWith(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      stateController.text = filteredStates[index];
                      filteredStates = [];
                    });
                    FocusScope.of(context).unfocus();
                  },
                );
              },
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
      await userService.updateAddress(
        addressId: widget.address.id,
        fullName: fullNameController.text,
        phone: phoneController.text,
        addressLine1: addressController.text,
        addressLine2: areaController.text,
        city: cityController.text,
        state: stateController.text,
        pincode: pincodeController.text,
        isDefault: isDefault,
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

  // Add this method to check if all required fields are filled
  bool _isFormValid() {
    return fullNameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty && 
        phoneController.text.length == 10 &&
        addressController.text.isNotEmpty &&
        areaController.text.isNotEmpty &&
        cityController.text.isNotEmpty &&
        stateController.text.isNotEmpty &&
        pincodeController.text.length == 6;
  }

  @override
  void dispose() {
    fullNameController.removeListener(() => setState(() {}));
    phoneController.removeListener(() => setState(() {}));
    addressController.removeListener(() => setState(() {}));
    areaController.removeListener(() => setState(() {}));
    cityController.removeListener(() => setState(() {}));
    stateController.removeListener(() => setState(() {}));
    pincodeController.removeListener(() => setState(() {}));
    
    fullNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    areaController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    super.dispose();
  }
}
