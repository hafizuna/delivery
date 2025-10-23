import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  RxInt selectedIndex = 0.obs;
  final PageController pageController = PageController();

  @override
  void onInit() {
    super.onInit();
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
