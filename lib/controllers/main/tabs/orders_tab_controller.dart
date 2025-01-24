import 'package:flutter/material.dart';
import '../../../models/orders_model.dart';
import '../../../services/Order/order_service.dart';

class OrdersTabController extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initializeData() async {
    await loadOrders();
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      _orders = await _orderService.getOrders();
    } catch (e) {
      _error = 'Failed to load orders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> trackOrder(String orderId) async {
  //   await _orderService.trackOrder(orderId);
  // }

  Future<void> rateOrder(String orderId, int rating) async {
    await _orderService.rateOrder(orderId, rating);
  }

  Future<void> reorderItems(String orderId) async {
    await _orderService.reorderItems(orderId);
  }
}