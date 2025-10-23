import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/app/location_permission_screen/location_permission_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/services/api_service.dart';
import 'package:customer/services/socket_service.dart';
import 'package:customer/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final SocketService _socketService = SocketService();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  RxString selectedCountryCode = '+251'.obs;
  RxBool isPasswordVisible = false.obs;
  RxBool isLoading = false.obs;

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void changeCountryCode(String code) {
    selectedCountryCode.value = code;
  }

  Future<void> loginWithPhoneAndPassword() async {
    // Validate inputs
    if (phoneController.text.trim().isEmpty) {
      ShowToastDialog.showToast('Please enter phone number');
      return;
    }

    if (phoneController.text.trim().length < 9) {
      ShowToastDialog.showToast('Please enter a valid phone number');
      return;
    }

    if (passwordController.text.isEmpty) {
      ShowToastDialog.showToast('Please enter password');
      return;
    }

    if (passwordController.text.length < 6) {
      ShowToastDialog.showToast('Password must be at least 6 characters');
      return;
    }

    try {
      isLoading.value = true;
      ShowToastDialog.showLoader('Logging in...');

      // No FCM token needed for Node.js backend
      String? fcmToken;

      // Call login API
      final response = await _apiService.login(
        phoneNumber: phoneController.text.trim(),
        countryCode: selectedCountryCode.value,
        password: passwordController.text,
        fcmToken: fcmToken,
      );

      ShowToastDialog.closeLoader();

      // Check if login was successful
      if (response['token'] != null && response['user'] != null) {
        // Save tokens
        await _storageService.saveAuthTokens(
          token: response['token'],
          refreshToken: response['refreshToken'] ?? '',
        );

        // Save user data
        await _storageService.saveUserData(response['user']);

        // Set user in constant
        Constant.userModel = UserModel.fromJson(response['user']);

        // Connect Socket.IO
        await _socketService.connect();

        ShowToastDialog.showToast('Login successful!');

        // Navigate based on user data
        if (Constant.userModel?.shippingAddresses != null &&
            Constant.userModel!.shippingAddresses!.isNotEmpty) {
          // User has addresses, go to dashboard
          Get.offAll(() => const DashBoardScreen());
        } else {
          // No addresses, go to location permission
          Get.offAll(() => const LocationPermissionScreen());
        }
      } else {
        ShowToastDialog.showToast('Login failed. Please try again.');
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      print('Login error: $e');
      
      // Handle specific error messages
      String errorMessage = 'Login failed. Please check your credentials.';
      if (e.toString().contains('404')) {
        errorMessage = 'User not found. Please sign up first.';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Invalid phone number or password.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection.';
      }
      
      ShowToastDialog.showToast(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }
}
