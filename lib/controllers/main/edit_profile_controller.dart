import 'package:flutter/material.dart';

enum Gender { male, female, other }

class EditProfileController extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  
  Gender _selectedGender = Gender.male;
  Gender get selectedGender => _selectedGender;

  EditProfileController() {
    // Initialize controllers with existing user data
    nameController.text = 'Jenny Wilson';
    emailController.text = 'user@test.com';
    phoneController.text = '+91 12345 67890';
  }

  void setGender(Gender gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void saveProfile(BuildContext context) {
    // Implement save profile logic here
    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}