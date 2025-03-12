import 'package:flutter/material.dart';
import '../models/auth_home_model.dart';
import '../views/onboarding_screen.dart';
import '../views/Auth Screen/sign_in_screen.dart';

class AuthController extends ChangeNotifier {
  final AuthHomeModel _model = AuthHomeModel();
  
  // Getter
  AuthHomeModel get model => _model;

  Future<void> handleFacebookSignIn() async {
    // TODO: Implement Facebook sign in logic
  }

  Future<void> handleGoogleSignIn() async {
    // TODO: Implement Google sign in logic
  }
}