import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/icons.dart';
import '../controllers/sign_in_controller.dart';
import '../views/authHome_screen.dart';

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
        if (controller.isPhoneVerified) {
          controller.backToPhoneInput();
          return false;
        }
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
                      if (!controller.isPhoneVerified) ...[
                        _buildPhoneInput(controller),
                        const SizedBox(height: 24),
                        _buildVerifyButton(controller),
                        const SizedBox(height: 24),
                        _buildDivider(model.orText),
                        const SizedBox(height: 24),
                        _buildSocialButtons(controller),
                      ] else ...[
                        _buildOTPInput(controller),
                      ],
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

  Widget _buildPhoneInput(SignInController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.model.phoneLabel,
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
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.call_outlined,
                color: Colors.black54,
                size: 22,
              ),
              prefixText: '+91 ',
              prefixStyle: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
              hintText: '1234567890',
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOTPInput(SignInController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // OTP Input Group
        Text(
          controller.model.otpLabel,
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
            controller: controller.otpController,
            keyboardType: TextInputType.number,
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
              hintText: 'Enter OTP',
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              'OTP sent to ${controller.formattedPhone}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: controller.backToPhoneInput,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Change',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        
        // Spacer between groups
        const SizedBox(height: 32),
        
        // Action Buttons Group
        _buildLoginButton(controller),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: controller.resendOTP,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              controller.model.resendOtpText,
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

  Widget _buildLoginButton(SignInController controller) {
    return FilledButton(
      onPressed: controller.handlePhoneLogin,
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
    );
  }

  Widget _buildDivider(String text) {
    return Row(
      children: [
        const Spacer(flex: 1),
        Expanded(
          flex: 2,
          child: Divider(
            color: Colors.grey.withOpacity(0.5),
            thickness: 0.5,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Divider(
            color: Colors.grey.withOpacity(0.5),
            thickness: 0.5,
          ),
        ),
        const Spacer(flex: 1),
      ],
    );
  }

  Widget _buildSocialButton({
    required String text,
    required String icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          elevation: 0,
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
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButtons(SignInController controller) {
    return Column(
      children: [
        _buildSocialButton(
          text: controller.model.facebookButtonText,
          icon: AppIcons.svg_facebookIcon,
          onPressed: controller.handleFacebookLogin,
        ),
        const SizedBox(height: 16),
        _buildSocialButton(
          text: controller.model.googleButtonText,
          icon: AppIcons.svg_googleIcon,
          onPressed: controller.handleGoogleLogin,
        ),
      ],
    );
  }

  Widget _buildVerifyButton(SignInController controller) {
    return FilledButton(
      onPressed: controller.verifyPhone,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      child: controller.isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'Verify Phone',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
    );
  }
}