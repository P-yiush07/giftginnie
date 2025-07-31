import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:giftginnie_ui/views/home_screen.dart';
import 'package:giftginnie_ui/views/success_screen.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../constants/icons.dart';
import '../../../controllers/sign_in_controller.dart';
import 'authHome_screen.dart';
import '../../../models/success_model.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Container(
        color: AppColors.white,
        child: ChangeNotifierProvider(
          create: (_) => SignInController(),
          child: const SignInView(),
        ),
      ),
    );
  }
}

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SignInController>(context);
    final model = controller.model;

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        model.subtitle,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildEmailInput(controller),
                      const SizedBox(height: 16),
                      _buildPasswordInput(context, controller),
                      const SizedBox(height: 24),
                      _buildLoginButton(controller),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailInput(SignInController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.model.emailLabel,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: Colors.black54,
                size: 22,
              ),
              hintText: 'example@email.com',
              hintStyle: TextStyle(
                fontSize: 16,
                color: Colors.black.withOpacity(0.5),
                fontWeight: FontWeight.w400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPasswordInput(BuildContext context, SignInController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.model.passwordLabel,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller.passwordController,
            obscureText: controller.obscurePassword,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Colors.black54,
                size: 22,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscurePassword 
                    ? Icons.visibility_outlined 
                    : Icons.visibility_off_outlined,
                  color: Colors.black54,
                  size: 22,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
              hintText: '••••••••',
              hintStyle: TextStyle(
                fontSize: 16,
                color: Colors.black.withOpacity(0.5),
                fontWeight: FontWeight.w400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        if (controller.error != null) ...[
          const SizedBox(height: 8),
          Text(
            controller.error!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
          ),
        ],
        // Forgot password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => controller.handleForgotPassword(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              controller.model.forgotPasswordText,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // OTP functionality removed - now using email/password authentication

  Widget _buildLoginButton(SignInController controller) {
    return Builder(
      builder: (context) => FilledButton(
        onPressed: controller.isLoading
            ? null
            : () async {
                // Dismiss keyboard
                FocusScope.of(context).unfocus();
                final success = await controller.handleEmailLogin();
                if (success && context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuccessScreen(
                        model: SuccessModel(
                          title: 'Login Successful',
                          message:
                              'Welcome back! You\'ve successfully logged into your Gift Ginnie account.',
                          buttonText: 'Continue to Home',
                          showBackButton: false,
                        ),
                        onButtonPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ),
                  );
                }
              },
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: controller.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                controller.model.loginButtonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

}
