class OrderModel {
  final String id;
  final String storeName;
  final String giftName;
  final double price;
  final DateTime orderDate;
  final OrderStatus status;

  OrderModel({
    required this.id,
    required this.storeName,
    required this.giftName,
    required this.price,
    required this.orderDate,
    required this.status,
  });
}

enum OrderStatus {
  inProgress,
  delivered,
  cancelled,
  refunded
}