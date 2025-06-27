class CarouselItem {
  final String id;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? link; // Keep for backward compatibility

  CarouselItem({
    required this.id,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    this.link,
  });

  factory CarouselItem.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['image'] ?? '';
    
    // Convert AVIF URLs to WebP or JPEG format if needed
    if (imageUrl.toLowerCase().endsWith('.avif')) {
      imageUrl = imageUrl.replaceAll('.avif', '.webp');
    }
    
    return CarouselItem(
      id: json['_id'] ?? '',
      image: imageUrl,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      link: null, // No link in banner API, set to null
    );
  }

  // Backward compatibility getters
  String get title => ''; // No title in banner API
  String get description => ''; // No description in banner API
  bool get isActive => true; // Assume all banners are active
}