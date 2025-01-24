import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:giftginnie_ui/constants/texts.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
            AppTexts.termsOfService.title,
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
                AppTexts.termsOfService.welcomeTitle,
                AppTexts.termsOfService.welcomeContent,
              ),
              _buildSection(
                AppTexts.termsOfService.acceptanceTitle,
                AppTexts.termsOfService.acceptanceContent,
              ),
              _buildSection(
                AppTexts.termsOfService.userAccountTitle,
                AppTexts.termsOfService.userAccountContent,
              ),
              _buildSection(
                AppTexts.termsOfService.giftServicesTitle,
                AppTexts.termsOfService.giftServicesContent,
              ),
              _buildSection(
                AppTexts.termsOfService.paymentTermsTitle,
                AppTexts.termsOfService.paymentTermsContent,
              ),
              _buildSection(
                AppTexts.termsOfService.deliveryPolicyTitle,
                AppTexts.termsOfService.deliveryPolicyContent,
              ),
              _buildSection(
                AppTexts.termsOfService.refundPolicyTitle,
                AppTexts.termsOfService.refundPolicyContent,
              ),
              _buildSection(
                AppTexts.termsOfService.privacyDataTitle,
                AppTexts.termsOfService.privacyDataContent,
              ),
              _buildSection(
                AppTexts.termsOfService.prohibitedActivitiesTitle,
                AppTexts.termsOfService.prohibitedActivitiesContent,
              ),
              _buildSection(
                AppTexts.termsOfService.modificationsTitle,
                AppTexts.termsOfService.modificationsContent,
              ),
              _buildSection(
                AppTexts.termsOfService.contactInformationTitle,
                AppTexts.termsOfService.contactInformationContent,
              ),
              const SizedBox(height: 32),
              Text(
                AppTexts.termsOfService.lastUpdated,
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