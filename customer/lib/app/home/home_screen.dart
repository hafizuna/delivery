import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/home_controller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
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
                                return GestureDetector(
                                  onTap: () => controller.filterByCategory(category.id ?? ''),
                                  child: Container(
                                    width: 80,
                                    margin: const EdgeInsets.only(right: 12),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            color: AppThemeData.primary300.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: category.photo != null
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: CachedNetworkImage(
                                                    imageUrl: category.photo!,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) => const Center(
                                                      child: CircularProgressIndicator(),
                                                    ),
                                                    errorWidget: (context, url, error) => Icon(
                                                      Icons.restaurant,
                                                      color: AppThemeData.primary300,
                                                    ),
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.restaurant,
                                                  color: AppThemeData.primary300,
                                                ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          category.title,
                                          style: TextStyle(
                                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                            fontSize: 12,
                                            fontFamily: AppThemeData.medium,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
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
                              final rating = controller.calculateRating(restaurant);
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Restaurant Image
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                      ),
                                      child: restaurant.photo != null
                                          ? CachedNetworkImage(
                                              imageUrl: restaurant.photo!,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(
                                                width: 100,
                                                height: 100,
                                                color: AppThemeData.grey200,
                                                child: const Center(
                                                  child: CircularProgressIndicator(),
                                                ),
                                              ),
                                              errorWidget: (context, url, error) => Container(
                                                width: 100,
                                                height: 100,
                                                color: AppThemeData.grey200,
                                                child: Icon(
                                                  Icons.restaurant,
                                                  color: AppThemeData.grey600,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              width: 100,
                                              height: 100,
                                              color: AppThemeData.grey200,
                                              child: Icon(
                                                Icons.restaurant,
                                                color: AppThemeData.grey600,
                                              ),
                                            ),
                                    ),
                                    // Restaurant Info
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              restaurant.title,
                                              style: TextStyle(
                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                fontSize: 16,
                                                fontFamily: AppThemeData.semiBold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            if (restaurant.description != null)
                                              Text(
                                                restaurant.description!,
                                                style: TextStyle(
                                                  color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                                                  fontSize: 12,
                                                  fontFamily: AppThemeData.regular,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  rating.toStringAsFixed(1),
                                                  style: TextStyle(
                                                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                    fontSize: 14,
                                                    fontFamily: AppThemeData.medium,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "(${restaurant.reviewsCount})",
                                                  style: TextStyle(
                                                    color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                                                    fontSize: 12,
                                                    fontFamily: AppThemeData.regular,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
