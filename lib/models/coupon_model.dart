class CouponModel {
  final int id;
  final String code;
  final String? title;
  final String? description;
  final String discountType;
  final double discountValue;
  final int? maxUsage;
  final int? maxUsagePerUser;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;

  CouponModel({
    required this.id,
    required this.code,
    this.title,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.maxUsage,
    this.maxUsagePerUser,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'],
      code: json['code'],
      title: json['title'],
      description: json['description'],
      discountType: json['discount_type'],
      discountValue: double.parse(json['discount_value']),
      maxUsage: json['max_usage'],
      maxUsagePerUser: json['max_usage_per_user'],
      validFrom: DateTime.parse(json['valid_from']),
      validUntil: DateTime.parse(json['valid_until']),
      isActive: json['is_active'],
    );
  }

  String get displayDiscount {
    if (discountType == 'FLAT') {
      return '₹${discountValue.toStringAsFixed(0)} OFF';
    } else {
      return '${discountValue.toStringAsFixed(0)}% OFF';
    }
  }

  String get displayTitle {
    if (discountType == 'FLAT') {
      return '₹${discountValue.toStringAsFixed(0)} OFF';
    } else {
      return 'Get ${discountValue.toStringAsFixed(0)}% Off';
    }
  }

  String get displayDescription {
    return description ?? 'Use code $code to get discount on your order';
  }

  String get displayCondition {
    final validUntilStr = '${validUntil.day}/${validUntil.month}/${validUntil.year}';
    return 'Valid till $validUntilStr';
  }
}