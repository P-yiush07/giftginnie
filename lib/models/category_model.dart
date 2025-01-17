class CategoryModel {
  final String categoryName;
  final String categoryIcon;
  final String description;
  final List<GiftItem> gifts;

  CategoryModel({
    required this.categoryName,
    required this.categoryIcon,
    required this.description,
    required this.gifts,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryName: json['categoryName'] ?? '',
      categoryIcon: json['categoryIcon'] ?? '',
      description: json['description'] ?? '',
      gifts: (json['gifts'] as List?)
              ?.map((gift) => GiftItem.fromJson(gift))
              .toList() ??
          [],
    );
  }
}

class GiftItem {
  final String name;
  final String image;
  final String? subtitle;
  final String? category;
  final double rating;
  final String duration;
  final String discount;
  final double price;
  bool isLiked;

  GiftItem({
    required this.name,
    required this.image,
    this.subtitle,
    this.category,
    required this.rating,
    required this.duration,
    required this.discount,
    required this.price,
    this.isLiked = false,
  });

  factory GiftItem.fromJson(Map<String, dynamic> json) {
    return GiftItem(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      subtitle: json['subtitle'],
      category: json['category'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      duration: json['duration'] ?? '',
      discount: json['discount'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      isLiked: json['isLiked'] ?? false,
    );
  }
}