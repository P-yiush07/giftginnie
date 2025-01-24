import 'package:flutter/material.dart';
import 'package:giftginnie_ui/constants/colors.dart';
import 'package:giftginnie_ui/services/auth_service.dart';
import 'package:giftginnie_ui/views/home_screen.dart';
import 'package:giftginnie_ui/views/onboarding_screen.dart';
import 'package:giftginnie_ui/constants/fonts.dart';
import 'package:giftginnie_ui/services/connectivity_service.dart';
import 'package:giftginnie_ui/widgets/no_internet_widget.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final connectivityService = context.read<ConnectivityService>();
    
    // Add a slight delay to show splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    if (!connectivityService.isConnected) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => NoInternetWidget(
            onRetry: () async {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const SplashScreen(),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    final authService = AuthService();
    final isAuthenticated = await authService.isAuthenticated();
    
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => isAuthenticated 
          ? const HomeScreen() 
          : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Coral/salmon color from image
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Gift Ginnie',
              style: AppFonts.heading1.copyWith(
                color: Colors.white,
                fontSize: 32,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}