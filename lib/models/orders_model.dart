class OrderModel {
  final String id;
  final String status;
  final String paymentStatus;
  final double totalAmount;
  final double priceToPay;
  final double discount;
  final String razorpayOrderId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DeliveryAddress? deliveryAddress;
  final List<OrderItem> items;
  final String? couponId;

  OrderModel({
    required this.id,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.priceToPay,
    required this.discount,
    required this.razorpayOrderId,
    required this.createdAt,
    required this.updatedAt,
    this.deliveryAddress,
    required this.items,
    this.couponId,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse delivery address safely
      DeliveryAddress? deliveryAddress;
      print('=== ORDER MODEL ADDRESS PARSING ===');
      print('Address field exists: ${json['address'] != null}');
      print('Address field type: ${json['address']?.runtimeType}');
      print('Address field value: ${json['address']}');
      
      if (json['address'] != null) {
        try {
          if (json['address'] is Map) {
            print('Converting address to Map<String, dynamic>');
            final addressMap = Map<String, dynamic>.from(json['address']);
            print('Address map keys: ${addressMap.keys.toList()}');
            deliveryAddress = DeliveryAddress.fromJson(addressMap);
            print('Successfully parsed delivery address');
          } else {
            print('Address is not a Map, type: ${json['address'].runtimeType}');
          }
        } catch (e) {
          print('Error parsing delivery address: $e');
          print('Stack trace: ${StackTrace.current}');
        }
      } else {
        print('No address field in order JSON');
      }
      print('=== END ORDER MODEL ADDRESS PARSING ===');

      // Parse items safely
      List<OrderItem> items = [];
      if (json['products'] != null && json['products'] is List) {
        for (var item in json['products']) {
          try {
            if (item is Map) {
              items.add(OrderItem.fromJson(Map<String, dynamic>.from(item)));
            }
          } catch (e) {
            print('Error parsing order item: $e');
          }
        }
      }

      return OrderModel(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        status: json['status']?.toString() ?? 'Pending',
        paymentStatus: json['paymentStatus']?.toString() ?? 'Pending',
        totalAmount: _parseDouble(json['totalAmount']),
        priceToPay: _parseDouble(json['priceToPay']),
        discount: _parseDouble(json['discount']),
        razorpayOrderId: json['razorpayOrderId']?.toString() ?? '',
        createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
        updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']),
        deliveryAddress: deliveryAddress,
        items: items,
        couponId: json['coupon'] is Map ? json['coupon']['_id']?.toString() : json['coupon']?.toString(),
      );
    } catch (e) {
      print('Error in OrderModel.fromJson: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}

class DeliveryAddress {
  final String id;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String addressType;
  final String name;
  final String phoneNumber;

  DeliveryAddress({
    required this.id,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.addressType,
    required this.name,
    required this.phoneNumber,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    print('=== PARSING DELIVERY ADDRESS ===');
    print('JSON keys: ${json.keys.toList()}');
    print('JSON data: $json');
    
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    final addressLine1 = json['addressLine1']?.toString() ?? json['address_line_1']?.toString() ?? '';
    final addressLine2 = json['addressLine2']?.toString() ?? json['address_line_2']?.toString() ?? '';
    final city = json['city']?.toString() ?? '';
    final state = json['state']?.toString() ?? '';
    final country = json['country']?.toString() ?? '';
    final pincode = json['zipCode']?.toString() ?? json['zipcode']?.toString() ?? json['zip_code']?.toString() ?? json['pincode']?.toString() ?? json['pin_code']?.toString() ?? '';
    final addressType = json['addressType']?.toString() ?? json['address_type']?.toString() ?? json['type']?.toString() ?? '';
    final name = json['fullName']?.toString() ?? json['name']?.toString() ?? '';
    final phoneNumber = json['phone']?.toString() ?? json['phoneNumber']?.toString() ?? json['phone_number']?.toString() ?? '';
    
    print('Parsed values:');
    print('  - id: "$id"');
    print('  - name: "$name"');
    print('  - phoneNumber: "$phoneNumber"');
    print('  - addressLine1: "$addressLine1"');
    print('  - addressLine2: "$addressLine2"');
    print('  - city: "$city"');
    print('  - state: "$state"');
    print('  - country: "$country"');
    print('  - zipcode/pincode: "$pincode"');
    print('  - addressType: "$addressType"');
    print('=== END PARSING DELIVERY ADDRESS ===');
    
    return DeliveryAddress(
      id: id,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      state: state,
      country: country,
      pincode: pincode,
      addressType: addressType,
      name: name,
      phoneNumber: phoneNumber,
    );
  }
}

class OrderItem {
  final String productId;
  final String variantId;
  final OrderProduct product;
  final ProductVariant? variant;
  final int quantity;
  final double price;
  final String title;
  final String description;
  final String color;
  final List<String> images;
  final bool isGift;
  int? myRating;

  OrderItem({
    required this.productId,
    required this.variantId,
    required this.product,
    this.variant,
    required this.quantity,
    required this.price,
    required this.title,
    required this.description,
    required this.color,
    required this.images,
    required this.isGift,
    this.myRating,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    try {
      // Parse product ID safely
      String productId = '';
      if (json['product'] is Map) {
        productId = json['product']['_id']?.toString() ?? '';
      } else if (json['product'] is String) {
        productId = json['product'];
      }

      // Parse variant ID safely
      String variantId = '';
      ProductVariant? variant;
      if (json['variant'] is Map) {
        final variantData = Map<String, dynamic>.from(json['variant']);
        variantId = variantData['_id']?.toString() ?? '';
        variant = ProductVariant.fromJson(variantData);
      } else if (json['variant'] is String) {
        variantId = json['variant'];
      }

      // Parse images safely
      List<String> images = [];
      if (json['images'] is List) {
        images = (json['images'] as List).map((img) => img.toString()).toList();
      }

      return OrderItem(
        productId: productId,
        variantId: variantId,
        product: OrderProduct.fromJson(json),
        variant: variant,
        quantity: _parseInt(json['quantity']),
        price: _parseDouble(json['price']),
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        color: json['color']?.toString() ?? '',
        images: images,
        isGift: json['isGift'] == true,
        myRating: _parseInt(json['my_rating']),
      );
    } catch (e) {
      print('Error in OrderItem.fromJson: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}

class OrderProduct {
  final String id;
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
    try {
      // Handle both direct product data and nested product data
      final productData = json['product'] is Map ? Map<String, dynamic>.from(json['product']) : json;
      
      // Parse images safely
      List<String> images = [];
      if (json['images'] is List) {
        images = (json['images'] as List).map((img) => img.toString()).toList();
      } else if (productData['images'] is List) {
        images = (productData['images'] as List).map((img) => img.toString()).toList();
      }

      return OrderProduct(
        id: productData['_id']?.toString() ?? productData['id']?.toString() ?? '',
        name: json['title']?.toString() ?? productData['name']?.toString() ?? '',
        description: json['description']?.toString() ?? productData['description']?.toString() ?? '',
        images: images,
        inStock: productData['in_stock'] == true || productData['inStock'] == true,
        rating: _parseDouble(productData['rating']),
        originalPrice: _parseDouble(json['price'] ?? productData['original_price'] ?? productData['originalPrice']),
        sellingPrice: _parseDouble(json['price'] ?? productData['selling_price'] ?? productData['sellingPrice']),
        brand: productData['brand']?.toString() ?? '',
        productType: productData['product_type']?.toString() ?? productData['productType']?.toString() ?? '',
        isLiked: productData['is_liked'] == true || productData['isLiked'] == true,
      );
    } catch (e) {
      print('Error in OrderProduct.fromJson: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}

class ProductVariant {
  final String id;
  final String color;
  final double price;
  final double originalPrice;
  final int stock;
  final List<String> images;
  final bool isActive;

  ProductVariant({
    required this.id,
    required this.color,
    required this.price,
    required this.originalPrice,
    required this.stock,
    required this.images,
    required this.isActive,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['_id']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      price: _parseDouble(json['price']),
      originalPrice: _parseDouble(json['originalPrice']),
      stock: _parseInt(json['stock']),
      images: (json['images'] as List? ?? []).map((img) => img.toString()).toList(),
      isActive: json['isActive'] == true,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}

enum OrderStatus {
  inProgress,
  delivered,
  cancelled,
  refunded
}