class CouponModel {
  final String code;
  final String discount;
  final String description;
  final String condition;
  final bool isValid;
  final DateTime? expiryDate;

  CouponModel({
    required this.code,
    required this.discount,
    required this.description,
    required this.condition,
    this.isValid = true,
    this.expiryDate,
  });
}