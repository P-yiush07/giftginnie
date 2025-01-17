import 'package:flutter/material.dart';
import './tabs/orders_tab_controller.dart';

class HomeController extends ChangeNotifier {
  final OrdersTabController ordersController = OrdersTabController();
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
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