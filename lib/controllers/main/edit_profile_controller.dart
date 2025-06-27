import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:giftginnie_ui/controllers/main/user_controller.dart';
import 'package:giftginnie_ui/services/User/user_service.dart';
import 'package:dio/dio.dart';
import 'package:giftginnie_ui/widgets/Snackbar/snackbar_widget.dart';
import 'package:giftginnie_ui/services/Cache/cache_service.dart';

enum Gender { male, female, other }

class EditProfileController extends ChangeNotifier {
  final UserService _userService = UserService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  Gender _selectedGender = Gender.male;
  Gender get selectedGender => _selectedGender;

  void initializeWithUserProfile(UserController userController) {
    if (userController.userProfile != null) {
      final profile = userController.userProfile!;
      
      nameController.text = profile.fullName;
      emailController.text = profile.email ?? '';
      phoneController.text = profile.phoneNumber;
      countryCodeController.text = profile.countryCode;
      
      // Set default gender as we don't have gender info in new API
      _selectedGender = Gender.other;
      notifyListeners();
    } else {
      // If no profile is available, try to get phone number from cache
      _loadPhoneFromCache();
    }
  }

  Future<void> _loadPhoneFromCache() async {
    final cacheService = CacheService();
    final userData = cacheService.userData;
    if (userData != null && userData['phone_number'] != null) {
      phoneController.text = userData['phone_number'].toString();
      countryCodeController.text = '91'; // Default country code for India
      notifyListeners();
    }
  }

  void setGender(Gender gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  Future<void> saveProfile(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('EditProfileController: Starting profile update');
      debugPrint('Name: ${nameController.text}');
      debugPrint('Phone: ${phoneController.text}');
      debugPrint('Country Code: ${countryCodeController.text}');

      final updatedProfile = await _userService.updateUserProfile(
        // Email is now read-only, so we're not sending it for update
        // email: emailController.text,
        fullName: nameController.text,
        phoneNumber: phoneController.text,
        countryCode: countryCodeController.text,
        // Gender removed from edit options
        isWholesaleCustomer: false,
      );

      debugPrint('EditProfileController: Profile update successful, updating UserController');

      // Update the UserController with new data
      final userController = Provider.of<UserController>(context, listen: false);
      userController.updateUserProfile(updatedProfile);

      debugPrint('EditProfileController: UserController updated successfully');

      if (context.mounted) {
        CustomSnackbar.show(context, 'Profile updated successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('EditProfileController: Error occurred: $e');
      debugPrint('EditProfileController: Error type: ${e.runtimeType}');
      
      if (context.mounted) {
        CustomSnackbar.show(
          context, 
          e is Exception ? e.toString().replaceAll('Exception: ', '') : 'Failed to update profile'
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Image picking functionality removed

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    countryCodeController.dispose();
    super.dispose();
  }
}