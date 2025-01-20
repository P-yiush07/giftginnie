// models/cart_model.dart
class CartModel {
  final int id;
  final int userId;
  final List<CartItem> items;
  final double originalPrice;
  final double discountedPrice;
  final double discountPercentage;
  final int totalItems;

  CartModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercentage,
    required this.totalItems,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'],
      userId: json['user'],
      items: (json['items'] as List).map((item) => CartItem.fromJson(item)).toList(),
      originalPrice: json['original_price'].toDouble(),
      discountedPrice: json['discounted_price'].toDouble(),
      discountPercentage: json['discount_percentage'].toDouble(),
      totalItems: json['total_items'],
    );
  }
}

class CartItem {
  final int id;
  final CartProduct product;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      product: CartProduct.fromJson(json['product']),
      quantity: json['quantity'],
      price: double.parse(json['price']),
    );
  }
}

class CartProduct {
  final int id;
  final String name;
  final String description;
  final List<String> images;
  final double price;
  final String brand;
  final String productType;
  final double rating;

  CartProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.price,
    required this.brand,
    required this.productType,
    required this.rating,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      images: (json['images'] as List).map((img) => img['image'].toString()).toList(),
      price: double.parse(json['price']),
      brand: json['brand'],
      productType: json['product_type'],
      rating: json['rating'].toDouble(),
    );
  }
}