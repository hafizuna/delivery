import 'package:customer/constant/constant.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/services/api_service.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final ApiService _apiService = ApiService();

  RxBool isLoading = true.obs;
  RxBool isRefreshing = false.obs;
  
  RxList<VendorModel> allRestaurants = <VendorModel>[].obs;
  RxList<VendorModel> popularRestaurants = <VendorModel>[].obs;
  RxList<VendorModel> newArrivalRestaurants = <VendorModel>[].obs;
  RxList<VendorCategoryModel> categories = <VendorCategoryModel>[].obs;
  
  RxString searchQuery = ''.obs;
  RxString selectedCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      
      // Load categories
      await loadCategories();
      
      // Load restaurants
      await loadRestaurants();
      
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print('Error loading home data: $e');
    }
  }

  Future<void> loadCategories() async {
    try {
      final response = await _apiService.getVendorCategories();
      categories.value = response.map((json) => VendorCategoryModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> loadRestaurants() async {
    try {
      // Get user's current location
      double? latitude = Constant.selectedLocation.latitude;
      double? longitude = Constant.selectedLocation.longitude;
      
      final response = await _apiService.getVendors(
        latitude: latitude,
        longitude: longitude,
        radius: Constant.radius,
        categoryId: selectedCategory.value.isEmpty ? null : selectedCategory.value,
      );
      
      allRestaurants.value = response.map((json) => VendorModel.fromJson(json)).toList();
      
      // Sort for popular (by reviews)
      popularRestaurants.value = List.from(allRestaurants);
      popularRestaurants.sort((a, b) {
        double ratingA = a.reviewsCount > 0 ? a.reviewsSum / a.reviewsCount : 0;
        double ratingB = b.reviewsCount > 0 ? b.reviewsSum / b.reviewsCount : 0;
        return ratingB.compareTo(ratingA);
      });
      
      // Sort for new arrivals (by created date)
      newArrivalRestaurants.value = List.from(allRestaurants);
      newArrivalRestaurants.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      
    } catch (e) {
      print('Error loading restaurants: $e');
    }
  }

  Future<void> refreshData() async {
    isRefreshing.value = true;
    await loadData();
    isRefreshing.value = false;
  }

  void searchRestaurants(String query) {
    searchQuery.value = query;
    
    if (query.isEmpty) {
      // Show all restaurants
      return;
    }
    
    // Filter restaurants by name
    allRestaurants.value = allRestaurants.where((restaurant) {
      return restaurant.title.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void filterByCategory(String categoryId) {
    selectedCategory.value = categoryId;
    loadRestaurants();
  }

  void clearCategoryFilter() {
    selectedCategory.value = '';
    loadRestaurants();
  }

  double calculateRating(VendorModel vendor) {
    if (vendor.reviewsCount == 0) return 0.0;
    return vendor.reviewsSum / vendor.reviewsCount;
  }
}
