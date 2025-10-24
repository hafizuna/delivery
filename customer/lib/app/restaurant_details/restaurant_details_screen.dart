import 'package:customer/controllers/restaurant_details_controller.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/app/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  const RestaurantDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<RestaurantDetailsController>(
      init: RestaurantDetailsController(),
      builder: (controller) {
        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppThemeData.primary300,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () => Get.back(),
                  ),
                  actions: [
                    // Favorite Button (placeholder)
                    IconButton(
                      icon: Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // TODO: Implement favorite toggle
                      },
                    ),
                    // Cart Button with Badge
                    Stack(
                      children: [
                        IconButton(
                          icon: SvgPicture.asset(
                            "assets/icons/ic_shoping_cart.svg",
                            colorFilter: ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          onPressed: () {
                            // TODO: Navigate to cart
                          },
                        ),
                        if (controller.cartItemCount.value > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppThemeData.secondary300,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                controller.cartItemCount.value.toString(),
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
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Restaurant Image
                        controller.vendor.value.photos != null && 
                        controller.vendor.value.photos!.isNotEmpty
                            ? PageView.builder(
                                controller: controller.pageController,
                                itemCount: controller.vendor.value.photos!.length,
                                onPageChanged: (index) {
                                  controller.currentPage.value = index;
                                },
                                itemBuilder: (context, index) {
                                  return CachedNetworkImage(
                                    imageUrl: controller.vendor.value.photos![index].url,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: AppThemeData.grey300,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: AppThemeData.grey300,
                                      child: Icon(
                                        Icons.restaurant,
                                        size: 60,
                                        color: AppThemeData.grey600,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : CachedNetworkImage(
                                imageUrl: controller.vendor.value.photo ?? '',
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppThemeData.grey300,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppThemeData.grey300,
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 60,
                                    color: AppThemeData.grey600,
                                  ),
                                ),
                              ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                        // Page indicators (if multiple photos)
                        if (controller.vendor.value.photos != null && 
                            controller.vendor.value.photos!.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                controller.vendor.value.photos!.length,
                                (index) => Obx(() => Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: controller.currentPage.value == index
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                  ),
                                )),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: controller.refreshData,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Restaurant Info
                          _buildRestaurantInfo(controller, themeChange),
                          
                          const SizedBox(height: 24),
                          
                          // Search Bar
                          _buildSearchBar(controller, themeChange),
                          
                          const SizedBox(height: 16),
                          
                          // Categories (if any)
                          if (controller.categories.isNotEmpty)
                            _buildCategories(controller, themeChange),
                          
                          const SizedBox(height: 16),
                          
                          // Products
                          _buildProductsList(controller, themeChange),
                        ],
                      ),
                    ),
                  ),
          ),
          // Floating Cart Button
          floatingActionButton: Obx(() {
            if (controller.cartItemCount.value == 0) return const SizedBox.shrink();
            
            return FloatingActionButton.extended(
              onPressed: () {
                Get.to(() => const CartScreen());
              },
              backgroundColor: AppThemeData.primary300,
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: Text(
                '${controller.cartItemCount.value} items | ₹${controller.cartTotal.value.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildRestaurantInfo(RestaurantDetailsController controller, DarkThemeProvider themeChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.vendor.value.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.vendor.value.location,
                    style: TextStyle(
                      fontSize: 14,
                      color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                    ),
                  ),
                ],
              ),
            ),
            // Rating
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppThemeData.primary300.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppThemeData.primary300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: AppThemeData.primary300,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    controller.calculateRating().toStringAsFixed(1),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppThemeData.primary300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Open/Closed Status
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: controller.getStatusColor(),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              controller.getOpenCloseStatus().tr,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: controller.getStatusColor(),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              "${controller.vendor.value.reviewsCount} reviews",
              style: TextStyle(
                color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(RestaurantDetailsController controller, DarkThemeProvider themeChange) {
    return TextField(
      controller: controller.searchController,
      onChanged: controller.searchProducts,
      decoration: InputDecoration(
        hintText: "Search menu items...".tr,
        hintStyle: TextStyle(
          color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
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
    );
  }

  Widget _buildCategories(RestaurantDetailsController controller, DarkThemeProvider themeChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Categories".tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              final isSelected = controller.selectedCategory.value == category;
              
              return GestureDetector(
                onTap: () => controller.filterByCategory(category),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppThemeData.primary300 
                        : (themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey200),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected 
                          ? Colors.white 
                          : (themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductsList(RestaurantDetailsController controller, DarkThemeProvider themeChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Menu".tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
          ),
        ),
        const SizedBox(height: 16),
        controller.filteredProducts.isEmpty
            ? _buildEmptyState(themeChange)
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = controller.filteredProducts[index];
                  return _buildProductCard(product, controller, themeChange);
                },
              ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product, RestaurantDetailsController controller, DarkThemeProvider themeChange) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey200,
        ),
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: product.photo ?? '',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 80,
                height: 80,
                color: AppThemeData.grey300,
                child: const Icon(Icons.restaurant_menu),
              ),
              errorWidget: (context, url, error) => Container(
                width: 80,
                height: 80,
                color: AppThemeData.grey300,
                child: const Icon(Icons.restaurant_menu),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                  ),
                ),
                if (product.description != null && product.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (product.discountPrice != null && product.discountPrice! > 0) ...[
                      Text(
                        '\$${product.discountPrice!.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppThemeData.primary300,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ] else ...[
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppThemeData.primary300,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Add to Cart Button
          ElevatedButton(
            onPressed: product.isAvailable 
                ? () => controller.addToCart(product, 1)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeData.primary300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              product.isAvailable ? "Add".tr : "Unavailable".tr,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(DarkThemeProvider themeChange) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
            ),
            const SizedBox(height: 16),
            Text(
              "No menu items found".tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try adjusting your search or filters".tr,
              style: TextStyle(
                fontSize: 14,
                color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}