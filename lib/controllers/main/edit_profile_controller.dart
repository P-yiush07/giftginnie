import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:giftginnie_ui/controllers/main/user_controller.dart';
import 'package:giftginnie_ui/services/User/user_service.dart';
import 'package:file_picker/file_picker.dart';
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
  File? selectedImageFile;
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
      emailController.text = profile.email;
      phoneController.text = profile.phoneNumber;
      countryCodeController.text = profile.countryCode;
      
      // Set gender based on user profile
      if (profile.gender != null) {
        switch (profile.gender!.toLowerCase()) {
          case 'm':
          case 'male':
            _selectedGender = Gender.male;
            break;
          case 'f':
          case 'female':
            _selectedGender = Gender.female;
            break;
          default:
            _selectedGender = Gender.other;
        }
      }
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

  Future<void> updateProfileImage(File imageFile) async {
    selectedImageFile = imageFile;
    notifyListeners();
  }

  Future<void> saveProfile(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updatedProfile = await _userService.updateUserProfile(
        email: emailController.text,
        fullName: nameController.text,
        phoneNumber: phoneController.text,
        countryCode: countryCodeController.text,
        gender: _selectedGender == Gender.male ? 'M' : 
                _selectedGender == Gender.female ? 'F' : 'O',
        isWholesaleCustomer: false,
        imageFile: selectedImageFile,
      );

      // Update the UserController with new data
      final userController = Provider.of<UserController>(context, listen: false);
      userController.updateUserProfile(updatedProfile);

      if (context.mounted) {
        CustomSnackbar.show(context, 'Profile updated successfully');
        Navigator.pop(context);
      }
    } catch (e) {
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

  Future<void> pickImage() async {
    try {
      debugPrint('Picking image...');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      debugPrint('Pick result: $result');
      if (result != null && result.files.single.path != null) {
        selectedImageFile = File(result.files.single.path!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    countryCodeController.dispose();
    super.dispose();
  }
}