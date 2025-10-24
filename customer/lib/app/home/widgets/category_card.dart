import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class CategoryCard extends StatelessWidget {
  final VendorCategoryModel category;
  final VoidCallback? onTap;
  final bool isSelected;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category Image/Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppThemeData.primary300.withOpacity(0.1)
                    : (themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? AppThemeData.primary300 
                      : (themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey300),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: category.photo != null && category.photo!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: category.photo!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppThemeData.primary300,
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.restaurant_menu,
                          color: isSelected 
                              ? AppThemeData.primary300 
                              : AppThemeData.grey500,
                          size: 32,
                        ),
                      )
                    : Icon(
                        Icons.restaurant_menu,
                        color: isSelected 
                            ? AppThemeData.primary300 
                            : AppThemeData.grey500,
                        size: 32,
                      ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Category Name
            Text(
              category.title,
              style: TextStyle(
                color: isSelected 
                    ? AppThemeData.primary300
                    : (themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900),
                fontSize: 12,
                fontFamily: isSelected ? AppThemeData.semiBold : AppThemeData.regular,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
