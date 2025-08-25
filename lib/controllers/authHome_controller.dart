import 'package:flutter/material.dart';
import 'package:giftginnie_ui/services/Cache/cache_service.dart';
import '../models/auth_home_model.dart';

class AuthController extends ChangeNotifier {
  final AuthHomeModel _model = AuthHomeModel();
  final CacheService _cache = CacheService();


   bool _isGuest = true;
  bool get isGuest => _isGuest;

  void login() {
    _isGuest = false;
    notifyListeners(); // rebuild UI
  }

  
  // Getter
  AuthHomeModel get model => _model;
  // bool get isGuest => _isGuest;

  Future<void> init() async {
    _isGuest = _cache.isGuest;
    notifyListeners();
  }

  Future<void> guestLogin() async {
    
    // Save guest login flag
    await _cache.saveBool("isGuest", true);
    _isGuest = true;
    notifyListeners();
  }

}