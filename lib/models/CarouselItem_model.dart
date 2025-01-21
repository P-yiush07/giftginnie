class CarouselItem {
  final int id;
  final String title;
  final String description;
  final String image;
  final String? link;
  final bool isActive;

  CarouselItem({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    this.link,
    required this.isActive,
  });

  factory CarouselItem.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['image'];
    // Convert AVIF URLs to WebP or JPEG format
    if (imageUrl.toLowerCase().endsWith('.avif')) {
      imageUrl = imageUrl.replaceAll('.avif', '.webp'); // or '.jpg'
    }
    
    return CarouselItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: imageUrl,
      link: json['link'],
      isActive: json['is_active'],
    );
  }
}