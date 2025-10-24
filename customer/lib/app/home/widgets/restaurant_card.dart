import 'package:customer/models/vendor_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class RestaurantCard extends StatelessWidget {
  final VendorModel restaurant;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
  });

  double _calculateRating() {
    if (restaurant.reviewsCount == 0) return 0.0;
    return restaurant.reviewsSum / restaurant.reviewsCount;
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final rating = _calculateRating();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey200,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: CachedNetworkImage(
                imageUrl: restaurant.photo ?? '',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 100,
                  height: 100,
                  color: AppThemeData.grey300,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 100,
                  height: 100,
                  color: AppThemeData.grey300,
                  child: Icon(
                    Icons.restaurant,
                    color: AppThemeData.grey600,
                    size: 40,
                  ),
                ),
              ),
            ),
            
            // Restaurant Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Favorite Icon
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.title,
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                              fontSize: 16,
                              fontFamily: AppThemeData.semiBold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onFavoriteTap != null)
                          InkWell(
                            onTap: onFavoriteTap,
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : AppThemeData.grey500,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Description
                    if (restaurant.description != null && restaurant.description!.isNotEmpty)
                      Text(
                        restaurant.description!,
                        style: TextStyle(
                          color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                          fontSize: 12,
                          fontFamily: AppThemeData.regular,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Rating and Reviews
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
                            fontFamily: AppThemeData.semiBold,
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
      ),
    );
  }
}
