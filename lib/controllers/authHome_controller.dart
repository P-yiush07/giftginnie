import 'package:flutter/material.dart';
import '../models/auth_home_model.dart';
import '../views/onboarding_screen.dart';
import '../views/sign_in_screen.dart';

class AuthController extends ChangeNotifier {
  final AuthHomeModel model = AuthHomeModel();

  void navigateToOnboarding(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0);
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

  void handleEmailSignIn(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SignInScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  Future<void> handleFacebookSignIn() async {
    // TODO: Implement Facebook sign in logic
  }

  Future<void> handleGoogleSignIn() async {
    // TODO: Implement Google sign in logic
  }

  void navigateToSignUp(BuildContext context) {
    // TODO: Implement navigation to sign up screen
  }
}