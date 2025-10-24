import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/services/api_service.dart';
import 'package:customer/services/storage_service.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class AddressController extends GetxController {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // Observables
  RxList<ShippingAddress> addresses = <ShippingAddress>[].obs;
  RxBool isLoading = false.obs;
  Rx<ShippingAddress> selectedAddress = ShippingAddress().obs;
  
  // For Add Address Screen
  Rx<LatLng> selectedLocation = const LatLng(9.0320, 38.7469).obs; // Default: Addis Ababa
  RxString currentAddress = ''.obs;
  RxString selectedAddressType = 'Home'.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  /// Load all addresses from API or local storage
  Future<void> loadAddresses() async {
    try {
      isLoading.value = true;
      
      // First try to get from local storage
      final userData = await _storageService.getUserData();
      if (userData != null && userData['shippingAddresses'] != null) {
        List<ShippingAddress> localAddresses = (userData['shippingAddresses'] as List)
            .map((e) => ShippingAddress.fromJson(e))
            .toList();
        addresses.value = localAddresses;
        
        // Set default selected address
        if (localAddresses.isNotEmpty) {
          var defaultAddr = localAddresses.firstWhere(
            (addr) => addr.isDefault,
            orElse: () => localAddresses.first,
          );
          selectedAddress.value = defaultAddr;
          Constant.selectedLocation = defaultAddr;
        }
      }
      
      // TODO: Sync with API when available
      // await _syncWithAPI();
      
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print('Error loading addresses: $e');
      ShowToastDialog.showToast('Failed to load addresses');
    }
  }

  /// Add new address
  Future<void> addAddress({
    required String address,
    required String addressAs,
    required String locality,
    String? landmark,
    required double latitude,
    required double longitude,
    bool isDefault = false,
  }) async {
    try {
      isLoading.value = true;
      ShowToastDialog.showLoader('Saving address...');

      // Create new address
      ShippingAddress newAddress = ShippingAddress(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
        userId: Constant.userModel?.id,
        address: address,
        addressAs: addressAs,
        locality: locality,
        landmark: landmark,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
        createdAt: DateTime.now().toIso8601String(),
      );

      // If this is set as default, unset others
      if (isDefault) {
        for (var addr in addresses) {
          addr.isDefault = false;
        }
      }

      // Add to list
      addresses.add(newAddress);

      // Save to local storage
      await _saveToLocalStorage();

      // TODO: Save to API when available
      // await _apiService.createAddress(newAddress);

      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Address saved successfully!');
      
      // Set as selected if it's the only address or default
      if (addresses.length == 1 || isDefault) {
        selectedAddress.value = newAddress;
        Constant.selectedLocation = newAddress;
      }

      Get.back(); // Close add address screen
    } catch (e) {
      ShowToastDialog.closeLoader();
      print('Error adding address: $e');
      ShowToastDialog.showToast('Failed to save address');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update existing address
  Future<void> updateAddress({
    required String addressId,
    required String address,
    required String addressAs,
    required String locality,
    String? landmark,
    required double latitude,
    required double longitude,
    bool isDefault = false,
  }) async {
    try {
      isLoading.value = true;
      ShowToastDialog.showLoader('Updating address...');

      // Find address to update
      int index = addresses.indexWhere((addr) => addr.id == addressId);
      if (index == -1) {
        ShowToastDialog.showToast('Address not found');
        return;
      }

      // If this is set as default, unset others
      if (isDefault) {
        for (var addr in addresses) {
          addr.isDefault = false;
        }
      }

      // Update address
      addresses[index] = ShippingAddress(
        id: addressId,
        userId: addresses[index].userId,
        address: address,
        addressAs: addressAs,
        locality: locality,
        landmark: landmark,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
        createdAt: addresses[index].createdAt,
      );

      // Save to local storage
      await _saveToLocalStorage();

      // TODO: Update via API when available
      // await _apiService.updateAddress(addressId, addresses[index]);

      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Address updated successfully!');
      
      // Update selected address if it's the one being edited
      if (selectedAddress.value.id == addressId || isDefault) {
        selectedAddress.value = addresses[index];
        Constant.selectedLocation = addresses[index];
      }

      Get.back(); // Close edit screen
    } catch (e) {
      ShowToastDialog.closeLoader();
      print('Error updating address: $e');
      ShowToastDialog.showToast('Failed to update address');
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete address
  Future<void> deleteAddress(String addressId) async {
    try {
      isLoading.value = true;

      // Don't allow deleting the only address
      if (addresses.length <= 1) {
        ShowToastDialog.showToast('Cannot delete the only address');
        return;
      }

      // Remove from list
      int index = addresses.indexWhere((addr) => addr.id == addressId);
      if (index == -1) return;

      ShippingAddress addressToDelete = addresses[index];
      addresses.removeAt(index);

      // If deleted address was default, set first remaining as default
      if (addressToDelete.isDefault && addresses.isNotEmpty) {
        addresses.first.isDefault = true;
        selectedAddress.value = addresses.first;
        Constant.selectedLocation = addresses.first;
      }

      // Save to local storage
      await _saveToLocalStorage();

      // TODO: Delete via API when available
      // await _apiService.deleteAddress(addressId);

      ShowToastDialog.showToast('Address deleted successfully');
    } catch (e) {
      print('Error deleting address: $e');
      ShowToastDialog.showToast('Failed to delete address');
    } finally {
      isLoading.value = false;
    }
  }

  /// Set address as default
  Future<void> setAsDefault(String addressId) async {
    try {
      // Unset all defaults
      for (var addr in addresses) {
        addr.isDefault = false;
      }

      // Set selected as default
      int index = addresses.indexWhere((addr) => addr.id == addressId);
      if (index != -1) {
        addresses[index].isDefault = true;
        selectedAddress.value = addresses[index];
        Constant.selectedLocation = addresses[index];

        // Save to local storage
        await _saveToLocalStorage();

        // TODO: Update via API when available
        // await _apiService.setDefaultAddress(addressId);

        ShowToastDialog.showToast('Default address updated');
      }
    } catch (e) {
      print('Error setting default address: $e');
      ShowToastDialog.showToast('Failed to update default address');
    }
  }

  /// Select address (for cart screen)
  void selectAddress(ShippingAddress address) {
    selectedAddress.value = address;
    Constant.selectedLocation = address;
    
    // Return selected address to previous screen
    Get.back(result: address);
  }

  /// Save addresses to local storage
  Future<void> _saveToLocalStorage() async {
    try {
      final userData = await _storageService.getUserData();
      if (userData != null) {
        userData['shippingAddresses'] = addresses.map((e) => e.toJson()).toList();
        await _storageService.saveUserData(userData);
        
        // Update constant
        Constant.userModel = UserModel.fromJson(userData);
      }
    } catch (e) {
      print('Error saving addresses to local storage: $e');
    }
  }

  /// Get address from coordinates (reverse geocoding)
  Future<void> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        currentAddress.value = '${place.street}, ${place.locality}, ${place.country}';
      }
    } catch (e) {
      print('Error getting address from coordinates: $e');
      currentAddress.value = 'Unknown location';
    }
  }

  /// Update selected location (for add/edit address map)
  void updateSelectedLocation(LatLng location) {
    selectedLocation.value = location;
    getAddressFromCoordinates(location.latitude, location.longitude);
  }

  /// Set address type
  void setAddressType(String type) {
    selectedAddressType.value = type;
  }

  /// Get default address
  ShippingAddress? get defaultAddress {
    if (addresses.isEmpty) return null;
    return addresses.firstWhere(
      (addr) => addr.isDefault,
      orElse: () => addresses.first,
    );
  }

  /// Check if addresses are loaded
  bool get hasAddresses => addresses.isNotEmpty;

  /// Get address by ID
  ShippingAddress? getAddressById(String id) {
    try {
      return addresses.firstWhere((addr) => addr.id == id);
    } catch (e) {
      return null;
    }
  }
}