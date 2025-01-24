import 'package:flutter/material.dart';
import '../../models/address_model.dart';
import '../../services/User/user_service.dart';
import '../../services/Cache/cache_service.dart';

class AddressController extends ChangeNotifier {
  final UserService _userService = UserService();
  final CacheService _cacheService = CacheService();
  List<AddressModel> addresses = [];
  bool isLoading = true;
  String? error;
  AddressModel? selectedAddress;
  static const String _selectedAddressKey = 'selected_address_id';

  AddressController() {
    loadAddresses();
  }

  void selectAddress(AddressModel address) {
    selectedAddress = address;
    _saveSelectedAddressId(address.id);
    notifyListeners();
  }

  bool isAddressSelected(AddressModel address) {
    return selectedAddress?.id == address.id;
  }

  Future<void> loadAddresses() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();
      
      final fetchedAddresses = await _userService.getUserAddresses();
      addresses = fetchedAddresses;
      isLoading = false;
      
      // Load saved address after fetching addresses
      await loadSavedAddress();
      
      notifyListeners();
    } catch (e) {
      error = 'Failed to load addresses. Please try again.';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAddress(int addressId) async {
    try {
      // First remove from local state
      final addressToDelete = addresses.firstWhere((address) => address.id == addressId);
      final addressIndex = addresses.indexOf(addressToDelete);
      
      // Remove from list
      addresses.removeAt(addressIndex);
      
      // If the deleted address was selected, clear selection
      if (selectedAddress?.id == addressId) {
        selectedAddress = null;
        await _saveSelectedAddressId(null);
      }
      
      // Notify UI of changes
      notifyListeners();

      // Then make the API call
      await _userService.deleteAddress(addressId);
    } catch (e) {
      debugPrint('Error in deleteAddress: $e');
      // Don't revert the UI state since the delete was successful on the backend
      // Just notify about any error silently
      error = 'Failed to sync deletion. Please refresh the list.';
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

  Future<void> _saveSelectedAddressId(int? addressId) async {
    if (addressId != null) {
      await _cacheService.saveInt(_selectedAddressKey, addressId);
    } else {
      await _cacheService.remove(_selectedAddressKey);
    }
  }

  Future<void> loadSavedAddress() async {
    final savedAddressId = await _cacheService.getInt(_selectedAddressKey);
    
    if (savedAddressId != null && addresses.isNotEmpty) {
      final savedAddress = addresses.firstWhere(
        (address) => address.id == savedAddressId,
        orElse: () => addresses.first,
      );
      selectedAddress = savedAddress;
      notifyListeners();
    }
  }
}