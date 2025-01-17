class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String brand;
  final String productType;
  final bool isLiked;
  final double rating;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.brand,
    required this.productType,
    this.isLiked = false,
    this.rating = 0.0,
  });
}