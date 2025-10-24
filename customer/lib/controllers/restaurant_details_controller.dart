import 'package:customer/constant/constant.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/services/api_service.dart';
import 'package:customer/services/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestaurantDetailsController extends GetxController {
  final ApiService _apiService = ApiService();
  final CartProvider _cartProvider = Get.find<CartProvider>();
  
  // UI Controllers
  final TextEditingController searchController = TextEditingController();
  final PageController pageController = PageController();
  
  // Loading states
  RxBool isLoading = true.obs;
  RxInt currentPage = 0.obs;
  
  // Data
  Rx<VendorModel> vendor = VendorModel(
    title: '',
    latitude: 0.0,
    longitude: 0.0,
    location: '',
    phoneNumber: '',
    categoryId: '',
    zoneId: '',
  ).obs;
  
  RxList<ProductModel> allProducts = <ProductModel>[].obs;
  RxList<ProductModel> filteredProducts = <ProductModel>[].obs;
  RxList<String> categories = <String>[].obs;
  RxString selectedCategory = ''.obs;
  
  // Search and filters
  RxString searchQuery = ''.obs;
  RxBool showVegOnly = false.obs;
  
  // Cart
  RxList<CartProductModel> cartItems = <CartProductModel>[].obs;
  RxInt cartItemCount = 0.obs;
  RxDouble cartTotal = 0.0.obs;
  
  // Restaurant status
  RxBool isOpen = false.obs;

  @override
  void onInit() {
    super.onInit();
    _getArguments();
    _setupCartListener();
  }

  void _getArguments() {
    final arguments = Get.arguments;
    if (arguments != null && arguments['vendor'] != null) {
      vendor.value = arguments['vendor'] as VendorModel;
      _loadRestaurantData();
    }
  }

  void _setupCartListener() {
    _cartProvider.cartStream.listen((items) {
      cartItems.value = items;
      cartItemCount.value = items.fold<int>(0, (sum, item) => sum + (item.quantity ?? 0));
      
      // Calculate cart total
      double total = 0.0;
      for (var item in items) {
        double itemPrice = 0.0;
        if (item.discountPrice != null && double.parse(item.discountPrice.toString()) > 0) {
          itemPrice = double.parse(item.discountPrice.toString());
        } else {
          itemPrice = double.parse(item.price.toString());
        }
        total += itemPrice * (item.quantity ?? 0);
      }
      cartTotal.value = total;
    });
  }

  Future<void> _loadRestaurantData() async {
    try {
      isLoading.value = true;
      
      // Load products for this restaurant
      await _loadProducts();
      
      // Check if restaurant is open
      _checkRestaurantStatus();
      
    } catch (e) {
      print('Error loading restaurant data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadProducts() async {
    try {
      print('🏪 Loading products for vendor: ${vendor.value.id} - ${vendor.value.title}');
      
      // Call API to get products for this vendor
      final response = await _apiService.request(
        'GET',
        '/vendors/${vendor.value.id}/products',
      );
      
      print('🔍 Products API Response: $response');
      
      // Backend returns {success: true, data: [...products...]}
      final List<ProductModel> products = ((response['data'] ?? []) as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
          
      print('🍽️ Parsed ${products.length} products');
      
      allProducts.value = products;
      filteredProducts.value = products;
      
      // Extract unique categories
      final Set<String> categorySet = {};
      for (var product in products) {
        if (product.categoryId != null && product.categoryId!.isNotEmpty) {
          categorySet.add(product.categoryId!);
        }
      }
      categories.value = categorySet.toList();
      
    } catch (e) {
      print('Error loading products: $e');
      allProducts.value = [];
      filteredProducts.value = [];
    }
  }

  void _checkRestaurantStatus() {
    // Simple implementation - can be enhanced later
    final now = DateTime.now();
    final currentHour = now.hour;
    
    // Assume restaurant is open between 9 AM and 11 PM
    isOpen.value = currentHour >= 9 && currentHour <= 23;
  }

  void searchProducts(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void filterByCategory(String categoryId) {
    if (selectedCategory.value == categoryId) {
      selectedCategory.value = '';
    } else {
      selectedCategory.value = categoryId;
    }
    _applyFilters();
  }

  void toggleVegFilter() {
    showVegOnly.value = !showVegOnly.value;
    _applyFilters();
  }

  void _applyFilters() {
    List<ProductModel> filtered = List.from(allProducts);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((product) =>
          product.name.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }

    // Apply category filter
    if (selectedCategory.value.isNotEmpty) {
      filtered = filtered.where((product) =>
          product.categoryId == selectedCategory.value).toList();
    }

    // Apply veg filter (this would need to be added to ProductModel if needed)
    // if (showVegOnly.value) {
    //   filtered = filtered.where((product) => product.isVeg == true).toList();
    // }

    filteredProducts.value = filtered;
  }

  Future<void> addToCart(ProductModel product, int quantity) async {
    try {
      final cartItem = CartProductModel(
        id: product.id ?? '',
        name: product.name,
        photo: product.photo ?? '',
        price: product.price.toString(),
        discountPrice: (product.discountPrice ?? 0.0).toString(),
        quantity: quantity,
        vendorID: vendor.value.id ?? '',
        categoryId: product.categoryId ?? '',
        extras: [],
        extrasPrice: '0.0',
        variantInfo: null,
      );

      await _cartProvider.addToCart(Get.context!, cartItem, quantity);
      
      Get.snackbar(
        'Added to Cart',
        '${product.name} has been added to your cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      
    } catch (e) {
      print('Error adding to cart: $e');
      Get.snackbar(
        'Error',
        'Failed to add item to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> refreshData() async {
    await _loadRestaurantData();
  }

  double calculateRating() {
    if (vendor.value.reviewsCount == 0) return 0.0;
    return vendor.value.reviewsSum / vendor.value.reviewsCount;
  }

  String getOpenCloseStatus() {
    return isOpen.value ? 'Open' : 'Closed';
  }

  Color getStatusColor() {
    return isOpen.value ? Colors.green : Colors.red;
  }

  @override
  void onClose() {
    searchController.dispose();
    pageController.dispose();
    super.onClose();
  }
}