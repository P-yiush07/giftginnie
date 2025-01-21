class Product {
  final String id;
  final String name;
  final String description;
  final double originalPrice;
  final double sellingPrice;
  final List<String> images;
  final String brand;
  final String productType;
  bool isLiked;
  final double rating;
  final bool inStock;

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
    this.isLiked = false,
    this.rating = 0.0,
  });
}