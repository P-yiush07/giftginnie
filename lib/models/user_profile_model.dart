import 'package:giftginnie_ui/models/address_model.dart';

class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final bool isVerified;
  final String role;
  final List<AddressModel> addresses;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isVerified,
    required this.role,
    required this.addresses,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      isVerified: json['isVerified'] ?? false,
      role: json['role'] ?? 'user',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      addresses: json['addresses'] != null 
          ? (json['addresses'] as List).map<AddressModel>((addr) {
              // Handle both address objects and address IDs
              if (addr is String) {
                // If it's just an ID, create a minimal address object
                return AddressModel(
                  id: addr,
                  fullName: '',
                  addressLine1: '',
                  addressLine2: '',
                  city: '',
                  state: '',
                  country: 'India',
                  zipCode: '',
                  phone: 0,
                  isDefault: false,
                  createdAt: '',
                  updatedAt: '',
                );
              } else {
                // If it's a full address object, parse it normally
                return AddressModel.fromJson(addr);
              }
            }).toList()
          : [],
    );
  }
  
  // Add compatibility getters for existing code
  String get fullName => name;
  String get phoneNumber => phone;
  DateTime get dateJoined => createdAt;
  String get countryCode => '91'; // Default country code
  bool get isActive => isVerified;
  String? get gender => null; // No gender info in new API
  bool get isWholesaleCustomer => false; // No wholesale info in new API
  String? get profileImage => null; // No profile image in new API
}