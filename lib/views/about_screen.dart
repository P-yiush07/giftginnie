import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:giftginnie_ui/views/terms_of_service_screen.dart';
import 'package:giftginnie_ui/config/route_transitions.dart';
import 'package:giftginnie_ui/views/privacy_policy_screen.dart';
import 'package:giftginnie_ui/views/contact_us_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
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
            'About',
            style: AppFonts.paragraph.copyWith(
              fontSize: 18,
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          surfaceTintColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About GiftGinnie',
                      style: AppFonts.paragraph.copyWith(
                        fontSize: 24,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your trusted platform for discovering and sending perfect gifts.',
                      style: AppFonts.paragraph.copyWith(
                        fontSize: 15,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Content Sections
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      title: 'Terms of Service',
                      content: 'Read our terms and conditions for using GiftGinnie services.',
                      onTap: () {
                        Navigator.push(
                          context,
                          SlidePageRoute(
                            page: const TermsOfServiceScreen(),
                            direction: SlideDirection.right,
                          ),
                        );
                      },
                    ),
                    const Divider(height: 24),
                    _buildSection(
                      title: 'Privacy Policy',
                      content: 'Learn how we handle and protect your personal information.',
                      onTap: () {
                        Navigator.push(
                          context,
                          SlidePageRoute(
                            page: const PrivacyPolicyScreen(),
                            direction: SlideDirection.right,
                          ),
                        );
                      },
                    ),
                    const Divider(height: 24),
                    _buildSection(
                      title: 'Contact Us',
                      content: 'Get in touch with our support team for assistance.',
                      onTap: () {
                        Navigator.push(
                          context,
                          SlidePageRoute(
                            page: const ContactUsScreen(),
                            direction: SlideDirection.right,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Version Info
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Version 1.0.0',
                  style: AppFonts.paragraph.copyWith(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
                  content,
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
    );
  }
}