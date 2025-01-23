import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../controllers/main/home_controller.dart';
import 'package:provider/provider.dart';

class OrderFailedScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool showBackButton;

  const OrderFailedScreen({
    super.key,
    this.message = 'Your order could not be placed. Please try again.',
    required this.onRetry,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: showBackButton ? AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ) : null,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.primaryRed,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Order Failed!',
                  style: AppFonts.heading1.copyWith(
                    color: AppColors.primaryRed,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Message
                if (message.isNotEmpty && message != 'undefined') 
                  Text(
                    message,
                    style: AppFonts.paragraph.copyWith(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),

                // Back to Home Button
                Consumer<HomeController>(
                  builder: (context, homeController, _) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          homeController.setCurrentIndex(0);
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'Back to Home',
                          style: AppFonts.paragraph.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}