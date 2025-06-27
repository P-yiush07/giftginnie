import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/config/route_transitions.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:giftginnie_ui/views/Address%20Screen/address_selection_screen.dart';
import 'package:provider/provider.dart';
import '../../../controllers/main/tabs/profile_tab_controller.dart';
import '../Profile Screen/edit_profile_screen.dart';
import '../Profile Screen/favourite_gifts_screen.dart';
import '../../../controllers/main/user_controller.dart';
import '../../../services/image_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Profile Screen/about_screen.dart';
import '../../widgets/Internet/connectivity_wrapper.dart';
import '../../../services/connectivity_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      onRetry: () {
        if (context.read<ConnectivityService>().isConnected) {
          context.read<UserController>().loadUserProfile();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: ChangeNotifierProvider(
          create: (_) => ProfileTabController(),
          child: const ProfileTabView(),
        ),
      ),
    );
  }
}

class ProfileTabView extends StatefulWidget {
  const ProfileTabView({super.key});

  @override
  State<ProfileTabView> createState() => _ProfileTabViewState();
}

class _ProfileTabViewState extends State<ProfileTabView> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final userController = Provider.of<UserController>(context, listen: false);
    await userController.loadUserProfile();
  }

  Widget _buildProfileOption({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Consumer<UserController>(
      builder: (context, userController, _) {
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
                      userController.isLoading
                          ? Shimmer.fromColors(
                              baseColor: AppColors.grey300,
                              highlightColor: AppColors.grey100,
                              child: Container(
                                width: 180,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            )
                          : Text(
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
      },
    );
  }

  String _formatJoinDate(DateTime date) {
    // Format date as "Joined January 16, 2025"
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return 'Joined ${months[date.month - 1]} ${date.day}, ${date.year}';
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
                    const SizedBox(width: 8),
                    // User Info
                    Expanded(
                      child: Consumer<UserController>(
                        builder: (context, userController, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              userController.isLoading
                                  ? Shimmer.fromColors(
                                      baseColor: AppColors.grey300,
                                      highlightColor: AppColors.grey100,
                                      child: Container(
                                        width: 120,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      userController.userProfile?.fullName ?? '',
                                      style: AppFonts.heading1.copyWith(
                                        fontSize: 18,
                                        color: AppColors.black,
                                      ),
                                    ),
                            ],
                          );
                        },
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
                        Navigator.push(
                          context,
                          SlidePageRoute(
                            page: const AddressSelectionScreen(),
                            direction: SlideDirection.right,
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const Divider(height: 1, thickness: 0.5),
                    ),
                    // Removed Settings Option
                    // _buildProfileOption(
                    //   title: 'Settings',
                    //   subtitle: 'Set the all notifications',
                    //   onTap: () {
                    //     // Handle settings
                    //   },
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    //   child: const Divider(height: 1, thickness: 0.5),
                    // ),
                    _buildProfileOption(
                      title: 'About',
                      subtitle: 'Know more about the service and policy.',
                      onTap: () {
                        Navigator.push(
                          context,
                          SlidePageRoute(
                            page: const AboutScreen(),
                            direction: SlideDirection.right,
                          ),
                        );
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

              // Join Date
              Consumer<UserController>(
                builder: (context, userController, _) {
                  if (userController.userProfile?.dateJoined != null) {
                    return Column(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _formatJoinDate(userController.userProfile!.dateJoined),
                              style: AppFonts.paragraph.copyWith(
                                fontSize: 14,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Social Media Buttons
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSocialMediaButton(
                                icon: FontAwesomeIcons.instagram,
                                url: 'https://www.instagram.com/giftginnie1/profilecard/?igsh=MnowdXowaXk3OWRu',
                                color: const Color(0xFFE4405F),
                              ),
                              const SizedBox(width: 32),
                              _buildSocialMediaButton(
                                icon: FontAwesomeIcons.facebook,
                                url: 'https://www.facebook.com/profile.php?id=61566517247110',
                                color: const Color(0xFF1877F2),
                              ),
                              const SizedBox(width: 32),
                              _buildSocialMediaButton(
                                icon: FontAwesomeIcons.youtube,
                                url: 'https://youtube.com/@giftginnie?si=oloUJ-NgEC5ickPJ',
                                color: const Color(0xFFFF0000),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMediaButton({
    required IconData icon,
    required String url,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: FaIcon(
        icon,
        size: 28,
        color: color,
      ),
    );
  }
}