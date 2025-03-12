// lib/models/popular_category_model.dart
class PopularCategory {
  final int categoryId;
  final String image;
  final String categoryName;
  final double averageRating;
  final int totalReviews;
  final String categoryDescription;

  PopularCategory({
    required this.categoryId,
    required this.image,
    required this.categoryName,
    required this.averageRating,
    required this.totalReviews,
    required this.categoryDescription,
  });

  factory PopularCategory.fromJson(Map<String, dynamic> json) {
    return PopularCategory(
      categoryId: json['category_id'],
      image: json['image'],
      categoryName: json['category_name'],
      averageRating: json['average_rating']?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      categoryDescription: json['category_description'] ?? '',
    );
  }
}