import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:giftginnie_ui/constants/texts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            AppTexts.privacyPolicy.title,
            style: AppFonts.paragraph.copyWith(
              fontSize: 18,
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          surfaceTintColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                'Introduction',
                AppTexts.privacyPolicy.introduction,
              ),
              _buildSection(
                '1. Information We Collect',
                '''We collect the following types of information:
• Personal information (name, email, phone number)
• Delivery addresses
• Payment information
• Gift preferences and browsing history
• Device information and usage data''',
              ),
              _buildSection(
                '2. How We Use Your Information',
                '''Your information is used to:
• Process and deliver your orders
• Personalize your gifting experience
• Send order updates and notifications
• Improve our services
• Provide customer support
• Prevent fraud and ensure security''',
              ),
              _buildSection(
                '3. Information Sharing',
                '''We may share your information with:
• Delivery partners to fulfill orders
• Payment processors for transactions
• Service providers who assist our operations
• Legal authorities when required by law''',
              ),
              _buildSection(
                '4. Data Security',
                'We implement appropriate security measures to protect your personal information from unauthorized access, alteration, or disclosure.',
              ),
              _buildSection(
                '5. Your Rights',
                '''You have the right to:
• Access your personal data
• Correct inaccurate information
• Request deletion of your data
• Opt-out of marketing communications
• Export your data''',
              ),
              _buildSection(
                '6. Cookies and Tracking',
                'We use cookies and similar technologies to improve your experience and analyze app usage patterns.',
              ),
              _buildSection(
                '7. Children\'s Privacy',
                'Our services are not intended for children under 13. We do not knowingly collect information from children.',
              ),
              _buildSection(
                '8. Updates to Policy',
                'We may update this policy periodically. We will notify you of any material changes.',
              ),
              const SizedBox(height: 32),
              Text(
                'Last updated: March 2024',
                style: AppFonts.paragraph.copyWith(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppFonts.paragraph.copyWith(
              fontSize: 16,
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppFonts.paragraph.copyWith(
              fontSize: 14,
              color: AppColors.textGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}