import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService extends ChangeNotifier {
  bool _isConnected = true;
  final Connectivity _connectivity = Connectivity();

  bool get isConnected => _isConnected;

  ConnectivityService() {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results.first);
    });
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result.first);
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
      _isConnected = false;
      notifyListeners();
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    _isConnected = result != ConnectivityResult.none;
    notifyListeners();
  }
}