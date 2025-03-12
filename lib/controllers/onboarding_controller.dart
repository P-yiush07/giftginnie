import 'package:flutter/material.dart';
import '../models/onboarding_model.dart';
import '../constants/colors.dart';
import '../constants/images.dart';
import '../views/Auth Screen/authHome_screen.dart';

class OnboardingController extends ChangeNotifier {
  int _currentPage = 0;
  final List<OnboardingModel> _onboardingPages = [
    OnboardingModel(
      title: 'Browse Best Gift',
      description: 'Explore a variety of nearby Gift and their mouthwatering menus right at your fingertips.',
      imagePath: AppImages.webp_onboardingPhone1,
      bgColor: AppColors.primaryBg
    ),
    OnboardingModel(
      title: 'Track Your Orders',
      description: 'Stay updated with real-time tracking of your gift orders from purchase to delivery.',
      imagePath: AppImages.webp_onboardingPhone2,
      bgColor: AppColors.secondaryBg
    ),
    OnboardingModel(
      title: 'Secure Payments',
      description: 'Enjoy hassle-free and secure payment options for a seamless checkout experience.',
      imagePath: AppImages.webp_onboardingPhone3,
      bgColor: AppColors.tertiaryBg
    ),
  ];

  final PageController pageController = PageController();

  // Getters
  int get currentPage => _currentPage;
  List<OnboardingModel> get onboardingPages => _onboardingPages;

  // Setter
  set currentPage(int value) {
    _currentPage = value;
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void nextPage(BuildContext context) {
    if (_currentPage < _onboardingPages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipOnboarding(BuildContext context) {
    Navigator.pushAndRemoveUntil(
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
      (route) => false,
    );
  }

  void onPageChanged(int page) {
    _currentPage = page;
    notifyListeners();
  }
}