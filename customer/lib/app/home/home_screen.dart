import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/home_controller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/app/home/widgets/restaurant_card.dart';
import 'package:customer/app/home/widgets/category_card.dart';
import 'package:customer/app/restaurant_details/restaurant_details_screen.dart';
import 'package:customer/app/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  // TODO: Navigate to profile
                },
                child: CircleAvatar(
                  backgroundColor: AppThemeData.primary300,
                  child: Constant.userModel?.profilePictureURL != null && 
                         Constant.userModel!.profilePictureURL!.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: Constant.userModel!.profilePictureURL!,
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                            placeholder: (context, url) => const Icon(Icons.person, color: Colors.white),
                            errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.white),
                          ),
                        )
                      : const Icon(Icons.person, color: Colors.white),
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Deliver to".tr,
                  style: TextStyle(
                    color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                    fontSize: 12,
                    fontFamily: AppThemeData.regular,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppThemeData.primary300,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        Constant.selectedLocation.locality.isEmpty
                            ? "Select Location".tr
                            : Constant.selectedLocation.locality,
                        style: TextStyle(
                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                          fontSize: 14,
                          fontFamily: AppThemeData.semiBold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              // Cart Icon with Badge
              Stack(
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      "assets/icons/ic_shoping_cart.svg",
                      colorFilter: ColorFilter.mode(
                        themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () {
                      Get.to(() => const CartScreen());
                    },
                  ),
                  if (controller.cartItemCount.value > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppThemeData.primary300,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          controller.cartItemCount.value > 9 
                              ? '9+' 
                              : controller.cartItemCount.value.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              // Notification Icon
              IconButton(
                icon: SvgPicture.asset(
                  "assets/icons/ic_notification.svg",
                  colorFilter: ColorFilter.mode(
                    themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () {
                  // TODO: Navigate to notifications
                },
              ),
            ],
          ),
          body: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: controller.refreshData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            onChanged: controller.searchRestaurants,
                            decoration: InputDecoration(
                              hintText: "Search restaurants...".tr,
                              hintStyle: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                fontFamily: AppThemeData.regular,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                              ),
                              filled: true,
                              fillColor: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        
                        // Categories
                        if (controller.categories.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "Categories".tr,
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                fontSize: 18,
                                fontFamily: AppThemeData.semiBold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: controller.categories.length,
                              itemBuilder: (context, index) {
                                final category = controller.categories[index];
                                return CategoryCard(
                                  category: category,
                                  isSelected: controller.selectedCategory.value == (category.id ?? ''),
                                  onTap: () {
                                    if (controller.selectedCategory.value == (category.id ?? '')) {
                                      controller.clearCategoryFilter();
                                    } else {
                                      controller.filterByCategory(category.id ?? '');
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        // Popular Restaurants
                        if (controller.popularRestaurants.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Popular Restaurants".tr,
                                  style: TextStyle(
                                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                    fontSize: 18,
                                    fontFamily: AppThemeData.semiBold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // TODO: Navigate to all restaurants
                                  },
                                  child: Text(
                                    "See All".tr,
                                    style: TextStyle(
                                      color: AppThemeData.primary300,
                                      fontSize: 14,
                                      fontFamily: AppThemeData.medium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: controller.popularRestaurants.take(5).length,
                            itemBuilder: (context, index) {
                              final restaurant = controller.popularRestaurants[index];
                              return RestaurantCard(
                                restaurant: restaurant,
                                onTap: () {
                                  Get.to(
                                    () => const RestaurantDetailsScreen(),
                                    arguments: {'vendor': restaurant},
                                  );
                                },
                                onFavoriteTap: () {
                                  // TODO: Toggle favorite
                                },
                                isFavorite: false, // TODO: Check if favorite
                              );
                            },
                          ),
                        ],
                        
                        // Empty State
                        if (controller.popularRestaurants.isEmpty && !controller.isLoading.value)
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.restaurant_menu,
                                    size: 64,
                                    color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No restaurants found".tr,
                                    style: TextStyle(
                                      color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                      fontSize: 18,
                                      fontFamily: AppThemeData.semiBold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Try adjusting your location or search filters".tr,
                                    style: TextStyle(
                                      color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                                      fontSize: 14,
                                      fontFamily: AppThemeData.regular,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
