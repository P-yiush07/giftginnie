import 'package:flutter/material.dart';
import '../controllers/onboarding_controller.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import 'package:flutter/services.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
        statusBarBrightness: Brightness.light, // For iOS (dark icons)
      ),
      child: ChangeNotifierProvider(
        create: (_) => OnboardingController(),
        child: const OnboardingView(),
      ),
    );
  }
}

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: Consumer<OnboardingController>(
        builder: (context, controller, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Background color
              Container(
                decoration: BoxDecoration(
                  color: controller.onboardingPages[controller.currentPage].bgColor != null
                      ? Color(controller.onboardingPages[controller.currentPage].bgColor!)
                      : Colors.white,
                ),
              ),
              
              // Swipeable content area
              GestureDetector(
                onHorizontalDragEnd: (DragEndDetails details) {
                  if (details.primaryVelocity! > 0) {
                    // Swiped right
                    controller.previousPage();
                  } else if (details.primaryVelocity! < 0) {
                    // Swiped left
                    controller.nextPage();
                  }
                },
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.1),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Image.asset(
                          controller.onboardingPages[controller.currentPage].imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Fixed bottom white container overlapping the content
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 58),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.onboardingPages[controller.currentPage].title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.onboardingPages[controller.currentPage].description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      // Pagination dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          controller.onboardingPages.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: index == controller.currentPage ? 32 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: index == controller.currentPage
                                  ? AppColors.primary
                                  : AppColors.dotInactive,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Navigation buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: controller.skipOnboarding,
                            style: TextButton.styleFrom(
                              minimumSize: const Size(150, 48),
                              foregroundColor: AppColors.textGrey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          FilledButton(
                            onPressed: () {
                              controller.nextPage();
                            },
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(120, 48),
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
