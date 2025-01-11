import 'package:flutter/material.dart';
import '../models/onboarding_model.dart';
import '../constants/colors.dart';
import '../constants/images.dart';

class OnboardingController extends ChangeNotifier {
  int currentPage = 0;
  
  List<OnboardingModel> onboardingPages = [
    OnboardingModel(
      title: 'Browse Best Gift',
      description: 'Explore a variety of nearby Gift and their mouthwatering menus right at your fingertips.',
      imagePath: AppImages.onboardingPhone,
      bgColor: AppColors.primaryBg
    ),
    OnboardingModel(
      title: 'Real Time Tracking',
      description: 'Track the status of your order in real-time, from preparation to delivery.',
      imagePath: AppImages.onboardingPhone,
      bgColor: AppColors.secondaryBg
    ),
    OnboardingModel(
      title: 'Secure Payments',
      description: 'Enjoy hassle-free and secure payment options for a seamless checkout experience.',
      imagePath: AppImages.onboardingPhone,
      bgColor: AppColors.tertiaryBg
    ),
  ];

  void nextPage() {
    if (currentPage < onboardingPages.length - 1) {
      currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      currentPage--;
      notifyListeners();
    }
  }

  void skipOnboarding() {
    currentPage = onboardingPages.length - 1;
    notifyListeners();
  }
}