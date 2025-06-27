import 'package:flutter/material.dart';

class ProductVariant {
  final String id;
  final String description;
  final String descriptionSecond;
  final double price;
  final String color;
  final int stock;
  final List<String> images;
  final bool isGift;

  ProductVariant({
    required this.id,
    required this.description,
    required this.descriptionSecond,
    required this.price,
    required this.color,
    required this.stock,
    required this.images,
    required this.isGift,
  });

  bool get inStock => stock > 0;

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['_id'] ?? '',
      description: json['description'] ?? '',
      descriptionSecond: json['descriptionsecond'] ?? '',
      price: double.tryParse('${json['price']}') ?? 0.0,
      color: json['color'] ?? '',
      stock: json['stock'] ?? 0,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      isGift: json['isGift'] ?? false,
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double originalPrice;
  final double sellingPrice;
  final List<String> images;
  final String brand;
  final String productType;
  final List<ProductVariant> variants;
  bool isLiked;
  final double rating;
  final bool inStock;
  
  // Currently selected variant index
  int _selectedVariantIndex = 0;
  
  // Getter for the selected variant
  ProductVariant? get selectedVariant => 
      variants.isNotEmpty ? variants[_selectedVariantIndex] : null;
  
  // Method to change the selected variant
  void selectVariant(int index) {
    if (index >= 0 && index < variants.length) {
      _selectedVariantIndex = index;
    }
  }

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.originalPrice,
    required this.sellingPrice,
    required this.images,
    required this.brand,
    required this.productType,
    required this.inStock,
    this.variants = const [],
    this.isLiked = false,
    this.rating = 0.0,
  });
  
  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle different possible fields from the API
    String id = json['_id'] ?? json['id'] ?? '';
    String title = json['title'] ?? json['name'] ?? '';
    String description = json['description'] ?? '';
    
    // Default values
    double originalPrice = 0.0;
    double sellingPrice = 0.0;
    List<String> images = [];
    bool inStock = true;
    List<ProductVariant> variants = [];
    
    // Try to extract images
    if (json['images'] != null && json['images'] is List) {
      images = List<String>.from(json['images']);
    }
    
    // Try to extract variants
    if (json['variants'] != null && json['variants'] is List) {
      for (var variantJson in json['variants']) {
        if (variantJson is Map<String, dynamic>) {
          final variant = ProductVariant.fromJson(variantJson);
          variants.add(variant);
        }
      }
    }
    
    // If we have variants, use the first one's data as default
    if (variants.isNotEmpty) {
      final firstVariant = variants.first;
      originalPrice = firstVariant.price;
      sellingPrice = firstVariant.price; // Use exact price from variant
      inStock = firstVariant.inStock;
      
      // Add variant images to the product images
      if (firstVariant.images.isNotEmpty) {
        images.addAll(firstVariant.images);
      }
    }
    
    // Make sure we have unique images
    images = images.toSet().toList();
    
    debugPrint('Parsed product: $title with ${images.length} images and ${variants.length} variants');
    
    return Product(
      id: id,
      name: title,
      description: description,
      originalPrice: originalPrice,
      sellingPrice: sellingPrice,
      images: images,
      brand: "Brand", // Default since API doesn't provide brand
      productType: "Product", // Default since API doesn't provide type
      inStock: inStock,
      variants: variants,
      isLiked: false,
      rating: 4.5, // Default rating
    );
  }
}