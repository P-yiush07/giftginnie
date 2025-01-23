import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:giftginnie_ui/constants/texts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: AppTexts.contactUs.emailAddress,
    );
    
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      debugPrint('Could not launch email');
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneLaunchUri = Uri(
      scheme: 'tel',
      path: AppTexts.contactUs.phoneNumber.replaceAll(RegExp(r'[^\d+]'), ''),
    );
    
    if (await canLaunchUrl(phoneLaunchUri)) {
      await launchUrl(phoneLaunchUri);
    } else {
      debugPrint('Could not launch phone');
    }
  }

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
            AppTexts.contactUs.title,
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
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTexts.contactUs.headerTitle,
                      style: AppFonts.paragraph.copyWith(
                        fontSize: 24,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppTexts.contactUs.headerDescription,
                      style: AppFonts.paragraph.copyWith(
                        fontSize: 15,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildContactOption(
                      icon: Icons.email_outlined,
                      title: AppTexts.contactUs.emailTitle,
                      subtitle: AppTexts.contactUs.emailAddress,
                      onTap: _launchEmail,
                    ),
                    const Divider(height: 24),
                    _buildContactOption(
                      icon: Icons.phone_outlined,
                      title: AppTexts.contactUs.phoneTitle,
                      subtitle: AppTexts.contactUs.phoneNumber,
                      onTap: _launchPhone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTexts.contactUs.businessHoursTitle,
                      style: AppFonts.paragraph.copyWith(
                        fontSize: 16,
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBusinessHours(
                      AppTexts.contactUs.weekdayHours,
                      AppTexts.contactUs.weekdayTiming
                    ),
                    const SizedBox(height: 8),
                    _buildBusinessHours(
                      AppTexts.contactUs.saturdayHours,
                      AppTexts.contactUs.saturdayTiming
                    ),
                    const SizedBox(height: 8),
                    _buildBusinessHours(
                      AppTexts.contactUs.sundayHours,
                      AppTexts.contactUs.sundayTiming
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.textGrey, size: 24),
          const SizedBox(width: 16),
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
    );
  }

  Widget _buildBusinessHours(String day, String hours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: AppFonts.paragraph.copyWith(
            fontSize: 14,
            color: AppColors.textGrey,
          ),
        ),
        Text(
          hours,
          style: AppFonts.paragraph.copyWith(
            fontSize: 14,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}