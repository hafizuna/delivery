import 'package:customer/app/location_permission_screen/location_permission_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/services/api_service.dart';
import 'package:customer/services/socket_service.dart';
import 'package:customer/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final SocketService _socketService = SocketService();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  RxString selectedCountryCode = '+251'.obs;
  RxBool isPasswordVisible = false.obs;
  RxBool isConfirmPasswordVisible = false.obs;
  RxBool isLoading = false.obs;

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void changeCountryCode(String code) {
    selectedCountryCode.value = code;
  }

  bool _validateEmail(String email) {
    if (email.isEmpty) return true; // Email is optional
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Helper function to normalize phone number (remove leading zeros and non-digits)
  String _normalizePhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    // Remove leading zeros
    cleaned = cleaned.replaceAll(RegExp(r'^0+'), '');
    
    return cleaned;
  }

  // Alias method for signup screen compatibility
  Future<void> signUpWithPhoneAndPassword() async {
    return registerWithPhoneAndPassword();
  }

  Future<void> registerWithPhoneAndPassword() async {
    // Validate inputs
    if (firstNameController.text.trim().isEmpty) {
      ShowToastDialog.showToast('Please enter first name');
      return;
    }

    if (lastNameController.text.trim().isEmpty) {
      ShowToastDialog.showToast('Please enter last name');
      return;
    }

    if (emailController.text.trim().isNotEmpty && !_validateEmail(emailController.text.trim())) {
      ShowToastDialog.showToast('Please enter a valid email address');
      return;
    }

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

    if (confirmPasswordController.text.isEmpty) {
      ShowToastDialog.showToast('Please confirm password');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ShowToastDialog.showToast('Passwords do not match');
      return;
    }

    try {
      isLoading.value = true;
      ShowToastDialog.showLoader('Creating account...');

      // No FCM token needed for Node.js backend
      String? fcmToken;

      // Normalize phone number before sending to API
      String normalizedPhone = _normalizePhoneNumber(phoneController.text.trim());
      
      // Call register API
      final response = await _apiService.register(
        phoneNumber: normalizedPhone,
        countryCode: selectedCountryCode.value,
        password: passwordController.text,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
        fcmToken: fcmToken,
      );

      ShowToastDialog.closeLoader();

      // Check if registration was successful
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

        ShowToastDialog.showToast('Account created successfully!');

        // Navigate to location permission (new users need to add address)
        Get.offAll(() => const LocationPermissionScreen());
      } else {
        ShowToastDialog.showToast('Registration failed. Please try again.');
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      print('Signup error: $e');
      
      // Handle specific error messages
      String errorMessage = 'Registration failed. Please try again.';
      if (e.toString().contains('409') || e.toString().contains('already exists')) {
        errorMessage = 'Phone number already registered. Please login.';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Invalid data. Please check your information.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection.';
      }
      
      ShowToastDialog.showToast(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }
}
