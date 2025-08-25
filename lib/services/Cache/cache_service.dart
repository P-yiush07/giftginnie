import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class CacheService {
  // Private constructor
  CacheService._privateConstructor();

  // Singleton instance
  static final CacheService _instance = CacheService._privateConstructor();

  // Factory constructor to return the singleton instance
  factory CacheService() => _instance;

  late SharedPreferences _prefs;
  String? _token;
  Map<String, dynamic>? _userData;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String searchHistoryKey = 'search_history';
  static const String _isGuestKey = 'is_guest';

  // Initialize method that needs to be called at app startup
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadFromCache();
  }

  bool get isGuest => _prefs.getBool("isGuest") ?? false;

  Future<void> _loadFromCache() async {
    try {
      _token = _prefs.getString(_tokenKey);
      final userStr = _prefs.getString(_userKey);
      if (userStr != null) {
        // Parse the JSON string to Map
        _userData = json.decode(userStr) as Map<String, dynamic>;
      }
      debugPrint('Loaded from cache - Token: $_token, User: $_userData');
    } catch (e) {
      debugPrint('Error loading from cache: $e');
      // Clear potentially corrupted data
      await _prefs.remove(_tokenKey);
      await _prefs.remove(_userKey);
      _token = null;
      _userData = null;
    }
  }

  // Auth Data Management
  Future<void> saveAuthData({
    required String token,
    Map<String, dynamic>? userData,
  }) async {
    await _prefs.setString(_tokenKey, token);
    if (userData != null) {
      final userStr = json.encode(userData);
      await _prefs.setString(_userKey, userStr);
    }
    _token = token;
    _userData = userData;
  }

  Future<void> clearAuthData() async {
    await Future.wait([
      _prefs.remove(_tokenKey),
      _prefs.remove(_userKey),
    ]);
    _token = null;
    _userData = null;
  }

  // Getters
  String? get token => _token;
  Map<String, dynamic>? get userData {
    if (_userData != null) return _userData;
    
    final userStr = _prefs.getString(_userKey);
    if (userStr != null) {
      try {
        _userData = json.decode(userStr) as Map<String, dynamic>;
        return _userData;
      } catch (e) {
        debugPrint('Error decoding user data: $e');
        // Clear corrupted data
        _prefs.remove(_userKey);
        _userData = null;
      }
    }
    return null;
  }
  bool get isAuthenticated => _token != null;

  // Generic Storage Methods
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  Future<void> saveDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  Future<void> saveStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  String? getString(String key) => _prefs.getString(key);
  bool? getBool(String key) => _prefs.getBool(key);
  int? getInt(String key) => _prefs.getInt(key);
  double? getDouble(String key) => _prefs.getDouble(key);
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
    _token = null;
    _userData = null;
  }
}