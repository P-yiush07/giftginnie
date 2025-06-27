class CouponModel {
  final String id;
  final String code;
  final String discountType;
  final double discountValue;
  final double minimumPurchase;
  final DateTime validFrom;
  final DateTime validTo;
  final int usageLimit;
  final int currentUsage;
  final double? maxDiscountAmount;
  final bool isActive;

  CouponModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minimumPurchase,
    required this.validFrom,
    required this.validTo,
    required this.usageLimit,
    required this.currentUsage,
    this.maxDiscountAmount,
    required this.isActive,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['_id'],
      code: json['code'],
      discountType: json['discountType'],
      discountValue: json['discountValue'] is int 
          ? json['discountValue'].toDouble() 
          : double.parse(json['discountValue'].toString()),
      minimumPurchase: json['minimumPurchase'] is int 
          ? json['minimumPurchase'].toDouble() 
          : double.parse(json['minimumPurchase'].toString()),
      validFrom: DateTime.parse(json['validFrom']),
      validTo: DateTime.parse(json['validTo']),
      usageLimit: json['usageLimit'],
      currentUsage: json['currentUsage'],
      maxDiscountAmount: json['maxDiscountAmount'] != null 
          ? (json['maxDiscountAmount'] is int 
              ? json['maxDiscountAmount'].toDouble() 
              : double.parse(json['maxDiscountAmount'].toString())) 
          : null,
      isActive: json['isActive'],
    );
  }

  String get displayDiscount {
    if (discountType == 'fixed') {
      return '₹${discountValue.toStringAsFixed(0)} OFF';
    } else {
      return '${discountValue.toStringAsFixed(0)}% OFF';
    }
  }

  String get displayTitle {
    if (discountType == 'fixed') {
      return '₹${discountValue.toStringAsFixed(0)} OFF';
    } else {
      return 'Get ${discountValue.toStringAsFixed(0)}% Off';
    }
  }

  String get displayDescription {
    String description = 'Use code $code to get discount on your order';
    if (minimumPurchase > 0) {
      description += '\nMin. purchase: ₹${minimumPurchase.toStringAsFixed(0)}';
    }
    if (maxDiscountAmount != null) {
      description += '\nMax discount: ₹${maxDiscountAmount!.toStringAsFixed(0)}';
    }
    return description;
  }

  String get displayCondition {
    final validToStr = '${validTo.day}/${validTo.month}/${validTo.year}';
    return 'Valid till $validToStr';
  }
  
  // Method to check if coupon is valid (matches backend logic)
  bool isValid() {
    final now = DateTime.now();
    return isActive && validFrom.isBefore(now) && validTo.isAfter(now);
  }
}