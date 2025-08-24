class EmailVerificationModel {
  final String title;
  final String subtitle;
  final String otpLabel;
  final String verifyButtonText;
  final String resendOtpText;

  EmailVerificationModel({
    this.title = 'Verify Your Email',
    this.subtitle = 'We\'ve sent a verification code to your email. Please enter it below to complete your registration.',
    this.otpLabel = 'Email Verification Code',
    this.verifyButtonText = 'Verify Email',
    this.resendOtpText = 'Resend Code',
  });
}