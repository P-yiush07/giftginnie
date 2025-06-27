// models/cart_model.dart
import 'package:flutter/foundation.dart';

class CartModel {
  final List<CartItem> items;
  final double totalPrice;
  final int totalItems;
  final double? discountAmount;
  final double? finalPrice;
  final String? appliedCouponCode;

  CartModel({
    required this.items,
    required this.totalPrice,
    required this.totalItems,
    this.discountAmount,
    this.finalPrice,
    this.appliedCouponCode,
  });

  // New parsing logic for the updated API response
  factory CartModel.fromJson(dynamic jsonData) {
    // Check if the response contains a list of items or a more complex structure
    if (jsonData is List) {
      // Filter out null values from the list
      final itemsList = jsonData.where((item) => item != null).toList();
      
      // Map each non-null item to a CartItem
      final cartItems = itemsList.map((item) => CartItem.fromJson(item)).toList();
      
      // Calculate total price and total items
      double totalPrice = 0;
      cartItems.forEach((item) {
        totalPrice += item.variantPrice * item.quantity;
      });
      
      return CartModel(
        items: cartItems,
        totalPrice: totalPrice,
        totalItems: cartItems.length,
      );
    } else if (jsonData is Map<String, dynamic>) {
      // This is the case when we have a complex structure with discount info
      final List<CartItem> cartItems = [];
      double totalPrice = 0;
      double? discountAmount;
      double? finalPrice;
      String? appliedCouponCode;
      
      // Parse items
      if (jsonData['items'] != null && jsonData['items'] is List) {
        final itemsList = (jsonData['items'] as List).where((item) => item != null).toList();
        cartItems.addAll(itemsList.map((item) => CartItem.fromJson(item)));
      }
      
      // Calculate total or get it from response
      if (jsonData['totalAmount'] != null) {
        totalPrice = (jsonData['totalAmount'] is int) 
            ? (jsonData['totalAmount'] as int).toDouble() 
            : (jsonData['totalAmount'] as double);
      } else {
        cartItems.forEach((item) {
          totalPrice += item.variantPrice * item.quantity;
        });
      }
      
      // Get discount info if available
      if (jsonData['discount'] != null) {
        discountAmount = (jsonData['discount'] is int) 
            ? (jsonData['discount'] as int).toDouble() 
            : (jsonData['discount'] as double);
      }
      
      // Get final price if available
      if (jsonData['priceToPay'] != null) {
        finalPrice = (jsonData['priceToPay'] is int) 
            ? (jsonData['priceToPay'] as int).toDouble() 
            : (jsonData['priceToPay'] as double);
      }
      
      // Get applied coupon code if available
      if (jsonData['appliedCoupon'] != null) {
        appliedCouponCode = jsonData['appliedCoupon'] as String;
      }
      
      return CartModel(
        items: cartItems,
        totalPrice: totalPrice,
        totalItems: cartItems.length,
        discountAmount: discountAmount,
        finalPrice: finalPrice,
        appliedCouponCode: appliedCouponCode,
      );
    } else {
      // Fallback to empty cart if the response format is unexpected
      return CartModel(
        items: [],
        totalPrice: 0,
        totalItems: 0,
      );
    }
  }
}

class CartItem {
  final String productId;
  final String title;
  final String description;
  final List<String> productImages;
  final String variantId;
  final String variantDescription;
  final double variantPrice;
  final String variantColor;
  final int variantStock;
  final List<String> variantImages;
  final bool isGift;
  final int quantity;

  CartItem({
    required this.productId,
    required this.title,
    required this.description,
    required this.productImages,
    required this.variantId,
    required this.variantDescription,
    required this.variantPrice,
    required this.variantColor,
    required this.variantStock,
    required this.variantImages,
    required this.isGift,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      productImages: List<String>.from(json['productImages'] ?? []),
      variantId: json['variantId'] ?? '',
      variantDescription: json['variantDescription'] ?? '',
      variantPrice: (json['variantPrice'] ?? 0).toDouble(),
      variantColor: json['variantColor'] ?? '',
      variantStock: json['variantStock'] ?? 0,
      variantImages: List<String>.from(json['variantImages'] ?? []),
      isGift: json['isGift'] ?? false,
      quantity: json['quantity'] ?? 0,
    );
  }
}