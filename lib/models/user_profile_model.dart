import 'package:giftginnie_ui/models/address_model.dart';

class UserProfileModel {
  final int id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String countryCode;
  final bool isActive;
  final String? profileImage;
  final bool isWholesaleCustomer;
  final String? gender;
  final DateTime dateJoined;
  final List<AddressModel> addresses;

  UserProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.countryCode,
    required this.isActive,
    this.profileImage,
    required this.isWholesaleCustomer,
    this.gender,
    required this.dateJoined,
    required this.addresses,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      countryCode: json['country_code'],
      isActive: json['is_active'],
      profileImage: json['profile_image'],
      isWholesaleCustomer: json['is_wholesale_customer'],
      gender: json['gender'],
      dateJoined: DateTime.parse(json['date_joined']),
      addresses: (json['addresses'] as List)
          .map((addr) => AddressModel.fromJson(addr))
          .toList(),
    );
  }
}