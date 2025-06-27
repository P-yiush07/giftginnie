import 'package:flutter/material.dart';
import 'package:giftginnie_ui/config/route_transitions.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/main/edit_profile_controller.dart';
import '../../controllers/main/user_controller.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the existing UserController instance
    final userController = Provider.of<UserController>(context, listen: false);
    
    return ChangeNotifierProvider(
      create: (_) {
        final controller = EditProfileController();
        // Initialize with user data
        controller.initializeWithUserProfile(userController);
        return controller;
      },
      child: const EditProfileView(),
    );
  }
}

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: AppFonts.paragraph.copyWith(
            fontSize: 18,
            color: AppColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Consumer<UserController>(
        builder: (context, userController, _) {
          if (userController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 24),

                const SizedBox(height: 8),

                // Form Fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Consumer<EditProfileController>(
                    builder: (context, controller, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormField(
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            controller: controller.nameController,
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: 'Email Address',
                            icon: Icons.email_outlined,
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            enabled: false,
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: 'Phone Number',
                            icon: Icons.phone_outlined,
                            controller: controller.phoneController,
                            keyboardType: TextInputType.phone,
                            enabled: true, // Allow phone number editing
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Save Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Consumer<EditProfileController>(
                    builder: (context, controller, _) {
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: controller.isLoading 
                              ? null 
                              : () => controller.saveProfile(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.isLoading 
                                ? AppColors.grey500 
                                : AppColors.primaryRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: controller.isLoading
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
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.paragraph.copyWith(
            fontSize: 15,
            color: AppColors.labelGrey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: enabled ? Colors.white : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(26),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: enabled,
            style: const TextStyle(
              color: AppColors.authSocialButtonText,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Icon(
                  icon,
                  color: AppColors.textGrey,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption({
    required String label,
    required Gender value,
    required Gender groupValue,
    required ValueChanged<Gender> onChanged,
  }) {
    return Row(
      children: [
        Radio<Gender>(
          value: value,
          groupValue: groupValue,
          onChanged: (Gender? newValue) {
            if (newValue != null) onChanged(newValue);
          },
          activeColor: AppColors.primaryRed,
        ),
        Text(
          label,
          style: AppFonts.paragraph.copyWith(
            fontSize: 14,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}