import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';

class CouponSuccessDialog extends StatelessWidget {
  final String code;
  final double savedAmount;
  final bool isLoading;

  const CouponSuccessDialog({
    super.key,
    required this.code,
    required this.savedAmount,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success/Loading Icon
            if (isLoading)
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  color: Color(0xFFFF7B7B),
                  strokeWidth: 3,
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF7B7B).withOpacity(0.1),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Color(0xFFFF7B7B),
                    size: 32,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            
            // Status Text
            Text(
              isLoading ? 'Applying coupon...' : '$code applied',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
            
            if (!isLoading) ...[
              const SizedBox(height: 12),
              // Saved Amount Text
              Text(
                'You Saved \₹${savedAmount.toStringAsFixed(2)} on this order',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 8),
              
              // Subtitle Text
              const Text(
                'with this coupon code',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 24),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7B7B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}