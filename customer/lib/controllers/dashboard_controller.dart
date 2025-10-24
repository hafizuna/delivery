import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  RxInt selectedIndex = 0.obs;
  final PageController pageController = PageController();
  
  // Double press to exit
  DateTime? currentBackPressTime;
  RxBool canPopNow = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  bool onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || 
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Get.showSnackbar(
        GetSnackBar(
          message: "Press back again to exit".tr,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.black87,
        ),
      );
      return false;
    }
    return true;
  }

  void onBottomNavTap(int index) {
    selectedIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void onPageChanged(int index) {
    selectedIndex.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
