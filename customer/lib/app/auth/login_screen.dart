import 'package:customer/app/auth/signup_screen.dart';
import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/app/location_permission_screen/location_permission_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/login_controller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/themes/text_field_widget.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<LoginController>(
      init: LoginController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            actions: [
              InkWell(
                onTap: () async {
                  LocationPermission permission = await Geolocator.checkPermission();
                  if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
                    if (Constant.selectedLocation.latitude == 0.0) {
                      Get.offAll(const LocationPermissionScreen());
                    } else {
                      Get.offAll(const DashBoardScreen());
                    }
                  } else {
                    Get.offAll(const LocationPermissionScreen());
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Skip".tr,
                    style: TextStyle(
                      color: AppThemeData.primary300,
                      fontSize: 18,
                      fontFamily: AppThemeData.semiBold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Back! 👋".tr,
                    style: TextStyle(
                      color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                      fontSize: 22,
                      fontFamily: AppThemeData.semiBold,
                    ),
                  ),
                  Text(
                    "Log in to continue enjoying delicious food delivered to your doorstep.".tr,
                    style: TextStyle(
                      color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                      fontSize: 16,
                      fontFamily: AppThemeData.regular,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Phone Number with Country Code
                  Text(
                    'Phone Number'.tr,
                    style: TextStyle(
                      fontFamily: AppThemeData.medium,
                      fontSize: 14,
                      color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      border: Border.all(
                        color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Country Code Selector
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Select Country Code'.tr),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      title: const Text('+251 (Ethiopia)'),
                                      onTap: () {
                                        controller.changeCountryCode('+251');
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      title: const Text('+1 (USA)'),
                                      onTap: () {
                                        controller.changeCountryCode('+1');
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      title: const Text('+44 (UK)'),
                                      onTap: () {
                                        controller.changeCountryCode('+44');
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Row(
                              children: [
                                Text(
                                  controller.selectedCountryCode.value,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: AppThemeData.medium,
                                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 48,
                          color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                        ),
                        // Phone Number Input
                        Expanded(
                          child: TextField(
                            controller: controller.phoneController,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: AppThemeData.regular,
                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter phone number'.tr,
                              hintStyle: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                fontSize: 16,
                                fontFamily: AppThemeData.regular,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Password Field
                  TextFieldWidget(
                    title: 'Password'.tr,
                    controller: controller.passwordController,
                    hintText: 'Enter password'.tr,
                    obscureText: !controller.isPasswordVisible.value,
                    prefix: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(
                        "assets/icons/ic_lock.svg",
                        colorFilter: ColorFilter.mode(
                          themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    suffix: InkWell(
                      onTap: controller.togglePasswordVisibility,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          controller.isPasswordVisible.value
                              ? "assets/icons/ic_password_show.svg"
                              : "assets/icons/ic_password_close.svg",
                          colorFilter: ColorFilter.mode(
                            themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Login Button
                  RoundedButtonFill(
                    title: "Login".tr,
                    color: AppThemeData.primary300,
                    textColor: AppThemeData.grey50,
                    onPress: controller.loginWithPhoneAndPassword,
                  ),
                  const SizedBox(height: 24),
                  
                  // Sign Up Link
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Don't have an account? ".tr,
                        style: TextStyle(
                          color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                          fontSize: 16,
                          fontFamily: AppThemeData.regular,
                        ),
                        children: [
                          TextSpan(
                            text: "Sign up".tr,
                            style: TextStyle(
                              color: AppThemeData.primary300,
                              fontSize: 16,
                              fontFamily: AppThemeData.semiBold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.to(() => const SignupScreen());
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
