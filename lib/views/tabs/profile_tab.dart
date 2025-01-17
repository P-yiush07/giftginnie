import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/config/route_transitions.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:provider/provider.dart';
import '../../../controllers/main/tabs/profile_tab_controller.dart';
import '../../../views/edit_profile_screen.dart';
import '../../../views/favourite_gifts_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: ChangeNotifierProvider(
        create: (_) => ProfileTabController(),
        child: const ProfileTabView(),
      ),
    );
  }
}

class ProfileTabView extends StatelessWidget {
  const ProfileTabView({super.key});

  Widget _buildProfileOption({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.paragraph.copyWith(
                      fontSize: 16,
                      color: AppColors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppFonts.paragraph.copyWith(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textGrey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Profile',
                      style: AppFonts.paragraph.copyWith(
                        fontSize: 24,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your account details, payment methods, and personal preferences all in one place.',
                      style: AppFonts.paragraph.copyWith(
                        fontSize: 15,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Info Section
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Profile Image
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.grey300,
                          width: 1,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://img-cdn.pixlr.com/image-generator/history/65bb506dcb310754719cf81f/ede935de-1138-4f66-8ed7-44bd16efc709/medium.webp',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Albert Flores',
                            style: AppFonts.heading1.copyWith(
                              fontSize: 18,
                              color: AppColors.black,
                            ),
                          ),
                          Text(
                            '6391 Elgin St, Delaware 10299',
                            style: AppFonts.paragraph.copyWith(
                              fontSize: 14,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Edit Button
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          SlidePageRoute(
                            page: const EditProfileScreen(),
                            direction: SlideDirection.right,
                          ),
                        );
                      },
                      child: Text(
                        'Edit',
                        style: AppFonts.paragraph.copyWith(
                          fontSize: 14,
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Profile Options
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _buildProfileOption(
                      title: 'My Favourite Gift',
                      subtitle: 'Manage your favourite Gift.',
                      onTap: () {
                        Navigator.push(
                          context,
                          SlidePageRoute(
                            page: const FavouriteGiftsScreen(),
                            direction: SlideDirection.right,
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const Divider(height: 1, thickness: 0.5),
                    ),
                    _buildProfileOption(
                      title: 'Addresses',
                      subtitle: 'Share, edit and add a new Address.',
                      onTap: () {
                        // Handle addresses
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const Divider(height: 1, thickness: 0.5),
                    ),
                    _buildProfileOption(
                      title: 'Orders',
                      subtitle: 'Manage your ongoing and past orders.',
                      onTap: () {
                        // Handle orders
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const Divider(height: 1, thickness: 0.5),
                    ),
                    _buildProfileOption(
                      title: 'Settings',
                      subtitle: 'Set the all notifications',
                      onTap: () {
                        // Handle settings
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const Divider(height: 1, thickness: 0.5),
                    ),
                    _buildProfileOption(
                      title: 'About',
                      subtitle: 'Know more about the service and policy.',
                      onTap: () {
                        // Handle about
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: OutlinedButton(
                  onPressed: () async {
                    context.read<ProfileTabController>().handleLogout(context);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    side: BorderSide(
                      color: AppColors.primaryRed,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'Log Out',
                    style: AppFonts.paragraph.copyWith(
                      fontSize: 16,
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}