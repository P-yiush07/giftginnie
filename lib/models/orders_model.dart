class OrderModel {
  final int id;
  final String status;
  final double totalPrice;
  final double discountApplied;
  final double finalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DeliveryAddress deliveryAddress;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.status,
    required this.totalPrice,
    required this.discountApplied,
    required this.finalPrice,
    required this.createdAt,
    required this.updatedAt,
    required this.deliveryAddress,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      status: json['status'],
      totalPrice: double.parse(json['total_price']),
      discountApplied: double.parse(json['discount_applied']),
      finalPrice: double.parse(json['final_price']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deliveryAddress: DeliveryAddress.fromJson(json['delivery_address']),
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}

class DeliveryAddress {
  final int id;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String addressType;

  DeliveryAddress({
    required this.id,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.addressType,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: json['id'],
      addressLine1: json['address_line_1'],
      addressLine2: json['address_line_2'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      pincode: json['pincode'],
      addressType: json['address_type'],
    );
  }
}

class OrderItem {
  final int id;
  final OrderProduct product;
  final int quantity;
  final double price;
  int? myRating;

  OrderItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
    this.myRating,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      product: OrderProduct.fromJson(json['product']),
      quantity: json['quantity'],
      price: double.parse(json['price']),
      myRating: json['my_rating']?.toInt(),
    );
  }
}

class OrderProduct {
  final int id;
  final String name;
  final String description;
  final List<String> images;
  final bool inStock;
  final double? rating;
  final double originalPrice;
  final double sellingPrice;
  final String brand;
  final String productType;
  final bool isLiked;

  OrderProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.inStock,
    this.rating,
    required this.originalPrice,
    required this.sellingPrice,
    required this.brand,
    required this.productType,
    required this.isLiked,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      images: (json['images'] as List)
          .map((img) => img['image'].toString())
          .toList(),
      inStock: json['in_stock'],
      rating: json['rating']?.toDouble(),
      originalPrice: double.parse(json['original_price']),
      sellingPrice: double.parse(json['selling_price']),
      brand: json['brand'],
      productType: json['product_type'],
      isLiked: json['is_liked'],
    );
  }
}

enum OrderStatus {
  inProgress,
  delivered,
  cancelled,
  refunded
}