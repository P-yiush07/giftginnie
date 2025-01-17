import '../models/orders_model.dart';

final List<OrderModel> mockOrders = [
  OrderModel(
    id: '1',
    storeName: 'Gift Paradise',
    giftName: 'Personalized Photo Frame with Custom Engraving',
    price: 29.99,
    orderDate: DateTime(2022, 10, 27, 4, 18),
    status: OrderStatus.inProgress,
  ),
  OrderModel(
    id: '2',
    storeName: 'Luxury Gifts Co.',
    giftName: 'Premium Gift Hamper with Chocolates',
    price: 89.99,
    orderDate: DateTime(2022, 10, 27, 14, 45),
    status: OrderStatus.refunded,
  ),
  OrderModel(
    id: '3',
    storeName: "Artisan Gift Gallery",
    giftName: 'Handcrafted Wooden Music Box',
    price: 59.99,
    orderDate: DateTime(2022, 10, 27, 9, 51),
    status: OrderStatus.delivered,
  ),
];