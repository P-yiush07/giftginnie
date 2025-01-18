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