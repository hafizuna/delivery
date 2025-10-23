import 'package:customer/controllers/onboarding_controller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<OnboardingController>(
      init: OnboardingController(),
      builder: (controller) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  controller.currentPage.value == 0
                      ? "assets/images/image_1.png"
                      : controller.currentPage.value == 1
                          ? "assets/images/image_2.png"
                          : "assets/images/image_3.png",
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skip button
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: controller.skipOnboarding,
                      child: Text(
                        "Skip".tr,
                        style: TextStyle(
                          color: AppThemeData.primary300,
                          fontSize: 16,
                          fontFamily: AppThemeData.semiBold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: controller.pageController,
                      itemCount: controller.pages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                "assets/images/ic_logo.png",
                                width: 72,
                                height: 72,
                              ),
                              Text(
                                "Foodie".tr,
                                style: TextStyle(
                                  color: AppThemeData.grey50,
                                  fontSize: 24,
                                  fontFamily: AppThemeData.bold,
                                ),
                              ),
                              const SizedBox(height: 30),
                              Text(
                                controller.pages[index].title.tr,
                                style: TextStyle(
                                  color: AppThemeData.primary300,
                                  fontSize: 28,
                                  fontFamily: AppThemeData.bold,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                controller.pages[index].description.tr,
                                style: TextStyle(
                                  color: AppThemeData.grey300,
                                  fontSize: 16,
                                  fontFamily: AppThemeData.regular,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      controller.pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: controller.currentPage.value == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: controller.currentPage.value == index
                              ? AppThemeData.primary300
                              : AppThemeData.grey400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  RoundedButtonFill(
                    title: controller.isLastPage.value ? "Get Started".tr : "Next".tr,
                    color: AppThemeData.primary300,
                    textColor: AppThemeData.grey50,
                    onPress: controller.nextPage,
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
