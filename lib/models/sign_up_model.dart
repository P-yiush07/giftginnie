class SignUpModel {
  final String title;
  final String subtitle;
  final String phoneLabel;
  final String otpLabel;
  final String loginButtonText;
  final String orText;
  final String facebookButtonText;
  final String googleButtonText;
  final String resendOtpText;

  SignUpModel({
    this.title = 'Welcome',
    this.subtitle = 'Create an account to unlock exclusive gifts and offers for your loved ones.',
    this.phoneLabel = 'Phone Number',
    this.otpLabel = 'OTP Verification',
    this.loginButtonText = 'Sign Up',
    this.orText = 'OR',
    this.facebookButtonText = 'Sign Up with Facebook',
    this.googleButtonText = 'Sign Up with Google',
    this.resendOtpText = 'Resend OTP',
  });
}