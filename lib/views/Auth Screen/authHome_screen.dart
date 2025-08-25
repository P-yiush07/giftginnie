import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:giftginnie_ui/models/auth_home_model.dart';
import 'package:giftginnie_ui/views/home_screen.dart';
import 'package:giftginnie_ui/views/onboarding_screen.dart';
import 'package:giftginnie_ui/views/Auth%20Screen/sign_in_screen.dart';
import 'package:giftginnie_ui/views/Auth%20Screen/sign_up_screen.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../constants/icons.dart';
import '../../../constants/images.dart';
import '../../../controllers/authHome_controller.dart';
import 'package:flutter/services.dart';

class AuthHomeScreen extends StatelessWidget {
  const AuthHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Container(
        child: const AuthHomeView(),
      ),
    );
  }
}

class AuthHomeView extends StatelessWidget {
  const AuthHomeView({super.key});

  void navigateToSignIn(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          const SignInScreen(),
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
  
  void navigateToSignUp(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          const SignUpScreen(),
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

void handleGuestLogin(BuildContext context, AuthController controller) async {
    await controller.guestLogin();

    if (!context.mounted) return;

   Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const HomeScreen()),
  );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AuthController>(context);
    final model = controller.model;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(AppImages.webp_authBackground),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              AppColors.authBackgroundOverlay,
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
        child: Stack(
          children: [
            /// Main content (center/bottom part)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const Spacer(),
                    Text(
                      model.welcomeTitle,
                      style: AppFonts.heading1.copyWith(
                        fontSize: 24,
                        color: AppColors.authTitleText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      model.welcomeDescription,
                      style: AppFonts.paragraph.copyWith(
                        fontSize: 16,
                        color: AppColors.authDescriptionText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    _buildAuthButtons(context, controller, model),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  ],
                ),
              ),
            ),

            /// Guest Login Button (TOP RIGHT fixed)
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
               onPressed: () => handleGuestLogin(context, controller),
                child: const Text(
                  "Guest Login",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white, // or AppColors.primary
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildAuthButtons(BuildContext context, AuthController controller, AuthHomeModel model) {
    return Column(
      children: [
        FilledButton(
          onPressed: () => navigateToSignIn(context),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: Text(
            model.signInButtonText,
            style: AppFonts.paragraph.copyWith(
              fontSize: 16,
              color: AppColors.authTitleText,
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => navigateToSignUp(context),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            side: BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: Text(
            "Sign Up",
            style: AppFonts.paragraph.copyWith(
              fontSize: 16,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}