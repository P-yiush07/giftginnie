class CategoryModel {
  final int id;
  final String categoryName;
  final String description;
  final String image;
  final List<GiftItem> gifts;

  CategoryModel({
    required this.id,
    required this.categoryName,
    required this.description,
    required this.image,
    required this.gifts,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      categoryName: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      gifts: (json['gifts'] as List?)
              ?.map((gift) => GiftItem.fromJson(gift))
              .toList() ??
          [],
    );
  }
}

class GiftItem {
  final String id;
  final String name;
  final String description;
  final List<String>? images;
  final String brand;
  final String productType;
  final double rating;
  final double originalPrice;
  final double sellingPrice;
  final bool inStock;
  bool isLiked;

  GiftItem({
    required this.id,
    required this.name,
    required this.description,
    this.images,
    required this.brand,
    required this.productType,
    required this.rating,
    required this.originalPrice,
    required this.sellingPrice,
    required this.inStock,
    this.isLiked = false,
  });

  factory GiftItem.fromJson(Map<String, dynamic> json) {
    return GiftItem(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      images: (json['images'] as List?)?.map((img) => img['image'].toString()).toList(),
      brand: json['brand'] ?? '',
      productType: json['product_type'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      originalPrice: double.parse(json['original_price']?.toString() ?? '0.0'),
      sellingPrice: double.parse(json['selling_price']?.toString() ?? '0.0'),
      inStock: json['in_stock'] ?? true,
      isLiked: json['isLiked'] ?? false,
    );
  }
}