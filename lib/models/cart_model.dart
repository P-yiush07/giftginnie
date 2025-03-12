// models/cart_model.dart
import 'package:giftginnie_ui/models/coupon_model.dart';

class CartModel {
  final int id;
  final int userId;
  final List<CartItem> items;
  final double originalPrice;
  final double discountedPrice;
  final double discountPercentage;
  final int totalItems;
  final CouponModel? coupon;

  CartModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercentage,
    required this.totalItems,
    this.coupon,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'],
      userId: json['user'],
      items: (json['items'] as List).map((item) => CartItem.fromJson(item)).toList(),
      originalPrice: json['original_price']?.toDouble() ?? 0.0,
      discountedPrice: json['discounted_price']?.toDouble() ?? 0.0,
      discountPercentage: json['discount_percentage']?.toDouble() ?? 0.0,
      totalItems: json['total_items'] ?? 0,
      coupon: json['coupon'] != null ? CouponModel.fromJson(json['coupon']) : null,
    );
  }
}

class CartItem {
  final int id;
  final CartProduct product;
  final int quantity;
  final double originalPrice;
  final double sellingPrice;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.originalPrice,
    required this.sellingPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      product: CartProduct.fromJson(json['product']),
      quantity: json['quantity'],
      originalPrice: double.parse(json['product']['original_price']),
      sellingPrice: double.parse(json['product']['selling_price']),
    );
  }
}

class CartProduct {
  final int id;
  final String name;
  final String description;
  final List<String> images;
  final double originalPrice;
  final double sellingPrice;
  final String brand;
  final String productType;
  final double? rating;

  CartProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.originalPrice,
    required this.sellingPrice,
    required this.brand,
    required this.productType,
    this.rating,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      images: (json['images'] as List).map((img) => img['image'].toString()).toList(),
      originalPrice: double.parse(json['original_price']),
      sellingPrice: double.parse(json['selling_price']),
      brand: json['brand'],
      productType: json['product_type'],
      rating: json['rating']?.toDouble(),
    );
  }
}