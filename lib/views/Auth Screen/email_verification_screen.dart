import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giftginnie_ui/views/Auth Screen/sign_in_screen.dart';
import 'package:giftginnie_ui/views/Auth Screen/authHome_screen.dart';
import 'package:giftginnie_ui/views/success_screen.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../controllers/email_verification_controller.dart';
import '../../../models/success_model.dart';

class EmailVerificationScreen extends StatelessWidget {
  final String? email;
  final String? authToken;
  
  const EmailVerificationScreen({
    super.key, 
    this.email,
    this.authToken,
  });

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
          create: (_) => EmailVerificationController(
            email: email,
            authToken: authToken,
          ),
          child: const EmailVerificationView(),
        ),
      ),
    );
  }
}

class EmailVerificationView extends StatelessWidget {
  const EmailVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<EmailVerificationController>(context);
    final model = controller.model;

    return Scaffold(
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
                    const SizedBox(height: 16),
                    
                    // Email notification
                    if (controller.email != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.email_outlined, color: Colors.blue.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Code sent to: ${controller.email}',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                    
                    _buildOTPInput(controller),
                    const SizedBox(height: 16),
                    
                    // Display error message if there's any
                    if (controller.error != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.error!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    _buildVerifyButton(controller),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOTPInput(EmailVerificationController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              fontSize: 20,
              color: Colors.black87,
              letterSpacing: 8,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '• • • • • •',
              hintStyle: TextStyle(
                fontSize: 24,
                color: Colors.black.withOpacity(0.3),
                letterSpacing: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton(EmailVerificationController controller) {
    return Builder(
      builder: (context) => FilledButton(
        onPressed: controller.isLoading
            ? null
            : () async {
                // Dismiss keyboard
                FocusScope.of(context).unfocus();
                final success = await controller.verifyEmail();
                if (success && context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuccessScreen(
                        model: SuccessModel(
                          title: 'Email Verified',
                          message:
                              'Your email has been successfully verified. Please sign in to access your account.',
                          buttonText: 'Continue to Sign In',
                          showBackButton: false,
                        ),
                        onButtonPressed: () {
                          // First pop back to the auth home screen
                          Navigator.of(context).popUntil(
                            (route) => route.isFirst || route.settings.name == '/'
                          );
                          
                          // Then push the sign-in screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInScreen(),
                            ),
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
                controller.model.verifyButtonText,
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