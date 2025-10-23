import 'package:customer/app/auth/login_screen.dart';
import 'package:customer/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  RxInt currentPage = 0.obs;
  RxBool isLastPage = false.obs;

  // Onboarding pages data
  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Discover Restaurants',
      description: 'Find the best restaurants near you with just a few taps',
      image: 'assets/images/onboarding_1.png',
    ),
    OnboardingPage(
      title: 'Order Your Favorite Food',
      description: 'Browse menus and order delicious food from your favorite restaurants',
      image: 'assets/images/onboarding_2.png',
    ),
    OnboardingPage(
      title: 'Fast Delivery',
      description: 'Get your food delivered quickly and safely to your doorstep',
      image: 'assets/images/onboarding_3.png',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    pageController.addListener(() {
      currentPage.value = pageController.page?.round() ?? 0;
      isLastPage.value = currentPage.value == pages.length - 1;
    });
  }

  void nextPage() {
    if (isLastPage.value) {
      finishOnboarding();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipOnboarding() {
    finishOnboarding();
  }

  void finishOnboarding() async {
    // Mark onboarding as completed
    await Preferences.setBoolean(Preferences.isFinishOnBoardingKey, true);
    
    // Navigate to login screen
    Get.offAll(() => const LoginScreen());
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
  });
}
