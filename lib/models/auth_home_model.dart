class AuthHomeModel {
  final String welcomeTitle;
  final String welcomeDescription;
  final String signInButtonText;
  final String facebookButtonText;
  final String googleButtonText;
  final String noAccountText;
  final String signUpButtonText;

  AuthHomeModel({
    this.welcomeTitle = 'Welcome to Gift Ginnie',
    this.welcomeDescription = 'Get ready to discover and order delicious meals from your favorite Gift with Gift Ginnie.',
    this.signInButtonText = 'Sign in',
    this.facebookButtonText = 'Continue with Facebook',
    this.googleButtonText = 'Continue with Google',
    this.noAccountText = 'Don\'t have an account? ',
    this.signUpButtonText = 'Sign up',
  });
}