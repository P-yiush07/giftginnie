class SignInModel {
  final String title;
  final String subtitle;
  final String phoneLabel;
  final String otpLabel;
  final String loginButtonText;
  final String orText;
  final String facebookButtonText;
  final String googleButtonText;
  final String resendOtpText;

  SignInModel({
    this.title = 'Welcome 😉',
    this.subtitle = 'Log in to your account to continue enjoying delicious meals and exclusive offers.',
    this.phoneLabel = 'Phone Number',
    this.otpLabel = 'OTP Verification',
    this.loginButtonText = 'Log in',
    this.orText = 'OR',
    this.facebookButtonText = 'Continue with Facebook',
    this.googleButtonText = 'Continue with Google',
    this.resendOtpText = 'Resend OTP',
  });
}