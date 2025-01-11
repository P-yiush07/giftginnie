import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:giftginnie_ui/models/auth_home_model.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/icons.dart';
import '../constants/images.dart';
import '../controllers/authHome_controller.dart';
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
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Container(
        color: Colors.black,
        child: ChangeNotifierProvider(
          create: (_) => AuthController(),
          child: const AuthHomeView(),
        ),
      ),
    );
  }
}

class AuthHomeView extends StatelessWidget {
  const AuthHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AuthController>(context);
    final model = controller.model;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(AppImages.authBackground),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(200),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Back button
              Positioned(
                top: 10,
                left: 4,
                child: IconButton(
                  onPressed: () => controller.navigateToOnboarding(context),
                  icon: SvgPicture.asset(
                    AppIcons.authBackIcon,
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Text(
                      model.welcomeTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      model.welcomeDescription,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    _buildAuthButtons(context, controller, model),
                    const SizedBox(height: 48),
                  ],
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
          onPressed: () => controller.handleEmailSignIn(context),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: Text(
            model.signInButtonText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildSocialButton(
          text: model.facebookButtonText,
          icon: AppIcons.facebookIcon,
          onPressed: controller.handleFacebookSignIn,
        ),
        const SizedBox(height: 16),
        _buildSocialButton(
          text: model.googleButtonText,
          icon: AppIcons.googleIcon,
          onPressed: controller.handleGoogleSignIn,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              model.noAccountText,
              style: const TextStyle(color: Colors.white70),
            ),
            TextButton(
              onPressed: () => controller.navigateToSignUp(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                model.signUpButtonText,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String text,
    required String icon,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            icon,
            height: 24,
            width: 24,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}