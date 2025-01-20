import 'package:flutter/material.dart';
import './tabs/orders_tab_controller.dart';

class HomeController extends ChangeNotifier {
  final OrdersTabController ordersController = OrdersTabController();
  int _currentIndex = 0;
  DateTime? _lastCartRefresh;

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    if (_currentIndex == index) {
      return;
    }
    
    _currentIndex = index;
    if (index == 3) { // Orders tab index
      ordersController.loadOrders();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    ordersController.dispose();
    super.dispose();
  }
}