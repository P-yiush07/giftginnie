class AddressModel {
  final int id;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String country;
  final String pincode;

  AddressModel({
    required this.id,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      addressLine1: json['address_line_1'],
      addressLine2: json['address_line_2'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      pincode: json['pincode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
    };
  }

  String get fullAddress {
    final List<String> parts = [
      addressLine1,
      if (addressLine2.isNotEmpty) addressLine2,
      city,
      state,
      country,
      pincode,
    ];
    return parts.where((part) => part.isNotEmpty).join(', ');
  }

  String getAddressLabel() {
    if (addressLine1.toLowerCase().contains('home')) return 'Home';
    if (addressLine1.toLowerCase().contains('work')) return 'Work';
    if (addressLine1.toLowerCase().contains('office')) return 'Office';
    return 'Other';
  }
}