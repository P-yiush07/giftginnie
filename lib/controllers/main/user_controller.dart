import 'package:flutter/material.dart';
import 'package:giftginnie_ui/models/user_profile_model.dart';
import 'package:giftginnie_ui/services/services.dart';

class UserController extends ChangeNotifier {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  UserProfileModel? _userProfile;
  bool _isLoading = false;
  String? _error;

  UserProfileModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserProfile() async {
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      debugPrint('Authentication status: $isAuthenticated');
      
      if (!isAuthenticated) {
        debugPrint('User not authenticated, skipping profile fetch');
        return;
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      final profile = await _userService.getUserProfile();
      _userProfile = profile;
      
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Call this after successful login
  Future<void> onLoginSuccess() async {
    await loadUserProfile();
  }

  // Call this on logout
  void onLogout() {
    _userProfile = null;
    notifyListeners();
  }

  void updateUserProfile(UserProfileModel updatedProfile) {
    _userProfile = updatedProfile;
    _isLoading = false;
    notifyListeners();
  }
}