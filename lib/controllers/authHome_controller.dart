import 'package:flutter/material.dart';
import 'package:giftginnie_ui/services/Cache/cache_service.dart';
import '../models/auth_home_model.dart';

class AuthController extends ChangeNotifier {
  final AuthHomeModel _model = AuthHomeModel();
  final CacheService _cache = CacheService();

  bool? _isGuest; // nullable, so we know if it's not loaded yet
  bool get isGuest => _isGuest ?? true;

  AuthController() {
    init(); // load from cache automatically
  }
  
  void login() async {
    await _cache.saveBool("isGuest", false);
    _isGuest = false;
    notifyListeners(); // rebuild UI
  }

  // Getter
  AuthHomeModel get model => _model;
  // bool get isGuest => _isGuest;

  Future<void> init() async {
    final storedValue = await _cache.getBool("isGuest");
    _isGuest = storedValue ?? true;
    debugPrint("AuthController init - isGuest = $_isGuest");
    notifyListeners();
  }

  Future<void> guestLogin() async {
    // Save guest login flag
    await _cache.saveBool("isGuest", true);

    final guestValue = await _cache.getBool("isGuest");
    debugPrint("Guest login set. isGuest = $guestValue");

    _isGuest = true;
    notifyListeners();
  }
}
