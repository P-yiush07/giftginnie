class OnboardingModel {
  final String title;
  final String description;
  final String imagePath;
  final int? bgColor;

  OnboardingModel({
    required this.title,
    required this.description,
    required this.imagePath,
    this.bgColor,
  });
}
