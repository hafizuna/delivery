import 'package:customer/app/home/home_screen.dart';
import 'package:customer/app/orders/orders_screen.dart';
import 'package:customer/controllers/dashboard_controller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<DashboardController>(
      init: DashboardController(),
      builder: (controller) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (!didPop) {
              if (controller.onWillPop()) {
                // Exit app
              }
            }
          },
          child: Scaffold(
            body: PageView(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const HomeScreen(),
                _buildPlaceholderScreen("Favourites", themeChange),
                const OrdersScreen(),
                _buildPlaceholderScreen("Profile", themeChange),
              ],
            ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: controller.selectedIndex.value,
              onTap: controller.onBottomNavTap,
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppThemeData.primary300,
              unselectedItemColor: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
              selectedLabelStyle: TextStyle(
                fontFamily: AppThemeData.semiBold,
                fontSize: 12,
              ),
              unselectedLabelStyle: TextStyle(
                fontFamily: AppThemeData.regular,
                fontSize: 12,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    "assets/icons/ic_home.svg",
                    colorFilter: ColorFilter.mode(
                      controller.selectedIndex.value == 0
                          ? AppThemeData.primary300
                          : (themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600),
                      BlendMode.srcIn,
                    ),
                    height: 24,
                  ),
                  label: "Home".tr,
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    "assets/icons/ic_fav.svg",
                    colorFilter: ColorFilter.mode(
                      controller.selectedIndex.value == 1
                          ? AppThemeData.primary300
                          : (themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600),
                      BlendMode.srcIn,
                    ),
                    height: 24,
                  ),
                  label: "Favourites".tr,
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    "assets/icons/ic_order.svg",
                    colorFilter: ColorFilter.mode(
                      controller.selectedIndex.value == 2
                          ? AppThemeData.primary300
                          : (themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600),
                      BlendMode.srcIn,
                    ),
                    height: 24,
                  ),
                  label: "Orders".tr,
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    "assets/icons/ic_profile.svg",
                    colorFilter: ColorFilter.mode(
                      controller.selectedIndex.value == 3
                          ? AppThemeData.primary300
                          : (themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600),
                      BlendMode.srcIn,
                    ),
                    height: 24,
                  ),
                  label: "Profile".tr,
                ),
              ],
            ),
          ),
        ),
        );
      },
    );
  }

  Widget _buildPlaceholderScreen(String title, DarkThemeProvider themeChange) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
        title: Text(
          title.tr,
          style: TextStyle(
            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
            fontFamily: AppThemeData.semiBold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
            ),
            const SizedBox(height: 16),
            Text(
              "$title Screen",
              style: TextStyle(
                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                fontSize: 20,
                fontFamily: AppThemeData.semiBold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Coming soon...",
              style: TextStyle(
                color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                fontSize: 16,
                fontFamily: AppThemeData.regular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
