class AddressModel {
  final String id;
  final String fullName;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String country;
  final String zipCode;
  final int phone;
  final bool isDefault;
  final String? addressType;  // We'll keep this for backward compatibility
  final String createdAt;
  final String updatedAt;

  AddressModel({
    required this.id,
    required this.fullName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.zipCode,
    required this.phone,
    required this.isDefault,
    this.addressType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? 'India',
      zipCode: json['zipCode'] ?? '',
      phone: json['phone'] is int ? json['phone'] : int.tryParse(json['phone'].toString()) ?? 0,
      isDefault: json['isDefault'] ?? false,
      addressType: 'O',  // Default to "Other" since new API doesn't have address type
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'zipCode': zipCode,
      'phone': phone,
      'isDefault': isDefault,
    };
  }

  String get fullAddress {
    final List<String> parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2!,
      city,
      state,
      country,
      zipCode,
    ];
    return parts.where((part) => part.isNotEmpty).join(', ');
  }

  String getAddressLabel() {
    // Since we don't have address type in the new API, we'll return "Home" for default addresses
    // and "Other" for non-default addresses
    return isDefault ? 'Home' : 'Other';
  }
}