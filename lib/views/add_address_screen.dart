import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  String selectedType = 'Home';
  bool isForSelf = true;
  TextEditingController otherAddressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

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
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Who are you ordering for?',
                  style: AppFonts.paragraph.copyWith(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildRadioOption(
                        value: true,
                        groupValue: isForSelf,
                        label: 'My Self',
                      ),
                      const SizedBox(width: 24),
                      _buildRadioOption(
                        value: false,
                        groupValue: isForSelf,
                        label: 'Someone else',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (!isForSelf) ...[
                  _buildTextField(
                    label: 'Name',
                    hint: 'Enter full name',
                    required: true,
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Phone Number',
                    hint: '12345 67890',
                    required: true,
                    prefixIcon: Icons.phone_outlined,
                    controller: phoneController,
                    isPhoneNumber: true,
                  ),
                  const SizedBox(height: 16),
                ],
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
                if (selectedType == 'Other') ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Save as',
                    hint: 'Enter address type',
                    required: true,
                    controller: otherAddressController,
                  ),
                ],
                const SizedBox(height: 24),
                _buildTextField(
                  label: 'Address',
                  hint: 'Enter Flat / house no / floor / building',
                  required: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Area, Sector, Locality',
                  hint: 'Enter area, sector, locality',
                  required: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Landmark',
                  hint: 'Nearby Landmark (Optional)',
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
            onPressed: () {
              // Handle save address
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(
              'Save Details',
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

  Widget _buildRadioOption({
    required bool value,
    required bool groupValue,
    required String label,
  }) {
    return InkWell(
      onTap: () => setState(() => isForSelf = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: value == groupValue ? AppColors.primary : Colors.grey,
                  width: 2,
                ),
              ),
              child: value == groupValue
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppFonts.paragraph.copyWith(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
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
          controller: controller,
          keyboardType: isPhoneNumber ? TextInputType.number : TextInputType.text,
          maxLength: isPhoneNumber ? 10 : null,
          inputFormatters: isPhoneNumber ? [
            FilteringTextInputFormatter.digitsOnly,
          ] : null,
          style: AppFonts.paragraph.copyWith(
            fontSize: 14,
            color:AppColors.black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppFonts.paragraph.copyWith(
              fontSize: 14,
              color: Colors.grey,
            ),
            filled: true,
            fillColor: Colors.white,
            counterText: '',
            prefixIcon: prefixIcon != null 
                ? Icon(prefixIcon, color: Colors.grey, size: 20)
                : null,
            prefixText: isPhoneNumber ? '+91 ' : null,
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
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: isPhoneNumber ? (value) {
            if (value == null || value.isEmpty) {
              return 'Phone number is required';
            }
            if (value.length != 10) {
              return 'Phone number must be 10 digits';
            }
            return null;
          } : null,
        ),
      ],
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    otherAddressController.dispose();
    super.dispose();
  }
}