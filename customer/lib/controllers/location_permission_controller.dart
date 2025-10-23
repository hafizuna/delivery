import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/services/api_service.dart';
import 'package:customer/services/storage_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPermissionController extends GetxController {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  RxBool isLoading = false.obs;
  Rx<LatLng> currentLocation = const LatLng(9.0320, 38.7469).obs; // Default: Addis Ababa
  RxString currentAddress = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        await _getCurrentLocation();
      } else {
        ShowToastDialog.showToast('Location permission is required');
      }
    } catch (e) {
      print('Error checking location permission: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      isLoading.value = true;
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentLocation.value = LatLng(position.latitude, position.longitude);
      
      // Get address from coordinates
      await _getAddressFromCoordinates(position.latitude, position.longitude);
      
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print('Error getting current location: $e');
      ShowToastDialog.showToast('Could not get current location');
    }
  }

  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        currentAddress.value = '${place.street}, ${place.locality}, ${place.country}';
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  Future<void> saveLocationAndContinue() async {
    if (currentAddress.value.isEmpty) {
      ShowToastDialog.showToast('Please select a location');
      return;
    }

    try {
      isLoading.value = true;
      ShowToastDialog.showLoader('Saving location...');

      // Create shipping address
      final addressData = {
        'address': currentAddress.value,
        'addressAs': 'Home',
        'locality': currentAddress.value,
        'latitude': currentLocation.value.latitude,
        'longitude': currentLocation.value.longitude,
        'isDefault': true,
      };

      // Save address via API (you'll need to implement this endpoint)
      // For now, we'll save it locally and update user data
      
      // Update user data in storage
      final userData = await _storageService.getUserData();
      if (userData != null) {
        // Add address to user data
        if (userData['shippingAddresses'] == null) {
          userData['shippingAddresses'] = [];
        }
        userData['shippingAddresses'].add(addressData);
        
        await _storageService.saveUserData(userData);
        
        // Update constant
        Constant.userModel = UserModel.fromJson(userData);
        
        if (Constant.userModel?.shippingAddresses != null && 
            Constant.userModel!.shippingAddresses!.isNotEmpty) {
          Constant.selectedLocation = Constant.userModel!.shippingAddresses!.first;
        }
      }

      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Location saved successfully!');

      // Navigate to dashboard
      Get.offAll(() => const DashBoardScreen());
    } catch (e) {
      ShowToastDialog.closeLoader();
      print('Error saving location: $e');
      ShowToastDialog.showToast('Failed to save location');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestLocationPermission() async {
    await _checkLocationPermission();
  }

  void updateLocation(LatLng location) {
    currentLocation.value = location;
    _getAddressFromCoordinates(location.latitude, location.longitude);
  }
}
