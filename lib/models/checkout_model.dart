class CheckoutModel {
  final String orderId;
  final List<CheckoutItem> items;
  final double originalPrice;
  final double discountedPrice;
  final String? couponCode;
  final String deliveryAddress;
  final String paymentMethod;

  CheckoutModel({
    required this.orderId,
    required this.items,
    required this.originalPrice,
    required this.discountedPrice,
    this.couponCode,
    required this.deliveryAddress,
    required this.paymentMethod,
  });
}

class CheckoutItem {
  final int id;
  final String name;
  final String brand;
  final double price;
  final int quantity;
  final String? imageUrl;

  CheckoutItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });
}