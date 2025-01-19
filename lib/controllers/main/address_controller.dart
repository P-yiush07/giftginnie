import 'package:flutter/material.dart';
import '../../models/address_model.dart';
import '../../services/user_service.dart';

class AddressController extends ChangeNotifier {
  final UserService _userService = UserService();
  List<AddressModel> addresses = [];
  bool isLoading = true;
  String? error;

  AddressController() {
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();
      
      final fetchedAddresses = await _userService.getUserAddresses();
      addresses = fetchedAddresses;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = 'Failed to load addresses. Please try again.';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAddress(int addressId) async {
    try {
      // TODO: Implement delete address API call in UserService
      // await _userService.deleteAddress(addressId);
      addresses.removeWhere((address) => address.id == addressId);
      notifyListeners();
    } catch (e) {
      error = 'Failed to delete address. Please try again.';
      notifyListeners();
    }
  }

  Future<void> editAddress(AddressModel address) async {
    try {
      // TODO: Implement edit address API call in UserService
      // await _userService.updateAddress(address);
      final index = addresses.indexWhere((a) => a.id == address.id);
      if (index != -1) {
        addresses[index] = address;
        notifyListeners();
      }
    } catch (e) {
      error = 'Failed to update address. Please try again.';
      notifyListeners();
    }
  }

  String getAddressLabel(AddressModel address) {
    if (address.addressLine1.toLowerCase().contains('home')) return 'Home';
    if (address.addressLine1.toLowerCase().contains('work')) return 'Work';
    if (address.addressLine1.toLowerCase().contains('office')) return 'Office';
    return 'Other';
  }
}