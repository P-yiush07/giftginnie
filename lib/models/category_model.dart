class CategoryModel {
  final String id;
  final String categoryName;
  final String description;
  final String? image;
  final List<String> subCategories;
  final List<GiftItem> gifts;

  CategoryModel({
    required this.id,
    required this.categoryName,
    required this.description,
    this.image,
    required this.subCategories,
    required this.gifts,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] as String,
      categoryName: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String?,
      // Handle both string IDs and full subCategory objects
      subCategories: (json['subCategories'] as List?)?.map((subCat) {
        if (subCat is String) {
          return subCat;
        } else if (subCat is Map<String, dynamic>) {
          return subCat['_id'] as String;
        }
        return subCat.toString();
      }).toList() ?? [],
      gifts: [], // No gifts in the new API response
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