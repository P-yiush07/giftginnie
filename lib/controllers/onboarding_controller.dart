import 'package:flutter/material.dart';
import '../models/onboarding_model.dart';
import '../constants/colors.dart';
import '../constants/images.dart';
import '../views/authHome_screen.dart';

class OnboardingController extends ChangeNotifier {
  int _currentPage = 0;
  final List<OnboardingModel> _onboardingPages = [
    OnboardingModel(
      title: 'Browse Best Gift',
      description: 'Explore a variety of nearby Gift and their mouthwatering menus right at your fingertips.',
      imagePath: AppImages.webp_onboardingPhone,
      bgColor: AppColors.primaryBg
    ),
    OnboardingModel(
      title: 'Real Time Tracking',
      description: 'Track the status of your order in real-time, from preparation to delivery.',
      imagePath: AppImages.webp_onboardingPhone,
      bgColor: AppColors.secondaryBg
    ),
    OnboardingModel(
      title: 'Secure Payments',
      description: 'Enjoy hassle-free and secure payment options for a seamless checkout experience.',
      imagePath: AppImages.webp_onboardingPhone,
      bgColor: AppColors.tertiaryBg
    ),
  ];

  // Getters
  int get currentPage => _currentPage;
  List<OnboardingModel> get onboardingPages => _onboardingPages;

  // Setter
  set currentPage(int value) {
    _currentPage = value;
    notifyListeners();
  }

  void nextPage(BuildContext context) {
    if (_currentPage < _onboardingPages.length - 1) {
      currentPage = _currentPage + 1;
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
            const AuthHomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      currentPage = _currentPage - 1;
    }
  }

  void skipOnboarding() {
    currentPage = _onboardingPages.length - 1;
  }
}