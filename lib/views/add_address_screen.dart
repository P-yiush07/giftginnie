import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../services/user_service.dart';
import '../constants/texts.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  String selectedType = 'Home';
  TextEditingController otherAddressController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  bool isLoading = false;

  final List<String> indianStates = AddressTexts.indianStates;

  List<String> filteredStates = [];

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
            'Enter Address Details',
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
                  hint: 'Enter area, sector, locality',
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
            MediaQuery.of(context).padding.bottom + 16,
          ),
          child: FilledButton(
            onPressed: isLoading || !_isFormValid() 
                ? null 
                : _handleAddAddress,
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
                    'Save Details',
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
          inputFormatters: isPhoneNumber ? [
            FilteringTextInputFormatter.digitsOnly,
          ] : null,
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
            prefixText: isPhoneNumber && maxLength == 10 ? '+91 ' : null,
            prefixStyle: AppFonts.paragraph.copyWith(
              fontSize: 14,
              color: Colors.black87,
            ),
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
                    style: AppFonts.paragraph.copyWith(fontSize: 14),
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

  Future<void> _handleAddAddress() async {
    final userService = UserService();
    
    setState(() {
      isLoading = true;
    });

    try {
      String addressType = selectedType == 'Home' ? 'H' : 
                          selectedType == 'Work' ? 'B' : 'O';

      await userService.addAddress(
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
                  'Address added successfully',
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
  void initState() {
    super.initState();
    addressController.addListener(() => setState(() {}));
    areaController.addListener(() => setState(() {}));
    cityController.addListener(() => setState(() {}));
    stateController.addListener(() => setState(() {}));
    pincodeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    addressController.removeListener(() => setState(() {}));
    areaController.removeListener(() => setState(() {}));
    cityController.removeListener(() => setState(() {}));
    stateController.removeListener(() => setState(() {}));
    pincodeController.removeListener(() => setState(() {}));
    
    addressController.dispose();
    areaController.dispose();
    cityController.dispose();
    landmarkController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    otherAddressController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return addressController.text.isNotEmpty &&
        areaController.text.isNotEmpty &&
        cityController.text.isNotEmpty &&
        stateController.text.isNotEmpty &&
        pincodeController.text.length == 6;
  }
}