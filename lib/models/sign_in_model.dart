class SignInModel {
  final String title;
  final String subtitle;
  final String emailLabel;
  final String passwordLabel;
  final String loginButtonText;
  final String orText;
  final String facebookButtonText;
  final String googleButtonText;
  final String forgotPasswordText;

  SignInModel({
    this.title = 'Welcome 😉',
    this.subtitle = 'Log in to your account to start gifting joy and surprises to your loved ones.',
    this.emailLabel = 'Email',
    this.passwordLabel = 'Password',
    this.loginButtonText = 'Log in',
    this.orText = 'OR',
    this.facebookButtonText = 'Continue with Facebook',
    this.googleButtonText = 'Continue with Google',
    this.forgotPasswordText = 'Forgot Password?',
  });
}