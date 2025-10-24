import 'package:flutter/foundation.dart';

class AppConfig {
  // API Configuration - loaded from environment variables
  static String get baseUrl {
    return const String.fromEnvironment('API_BASE_URL', 
      defaultValue: 'http://10.210.92.140:3000/api/v1');
  }
  
  static String get socketUrl {
    return const String.fromEnvironment('SOCKET_URL', 
      defaultValue: 'http://10.210.92.140:3000');
  }
  
  /// Google Maps API Key - loaded securely from environment variables
  static String get googleMapsApiKey {
    // Try to get from environment variable first (production)
    const envKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
    if (envKey.isNotEmpty) {
      return envKey;
    }
    
    // Development fallback - only in debug mode
    if (kDebugMode) {
      return 'AIzaSyA_lmuxAbk7zGaWw1DVP9H_vRUQifAOP-I';
    }
    
    // Production - should be set via environment or build configuration
    throw Exception(
      'Google Maps API Key not found. Please set GOOGLE_MAPS_API_KEY environment variable.'
    );
  }
  
  // Environment-based configuration:
  // - Set API_BASE_URL and SOCKET_URL in .env file for development
  // - Use --dart-define for production builds
  // - For physical device testing, use your computer's IP address
  // - Find your IP: ipconfig (Windows) or ifconfig (Mac/Linux)
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String logoutEndpoint = '/auth/logout';
  
  // User Endpoints
  static const String userProfileEndpoint = '/users/profile';
  static const String updateProfileEndpoint = '/users/profile';
  static const String updateFcmTokenEndpoint = '/users/fcm-token';
  static const String userAddressesEndpoint = '/users/addresses';
  
  // Vendor Endpoints
  static const String vendorsEndpoint = '/vendors';
  static const String vendorDetailsEndpoint = '/vendors'; // + /{id}
  static const String vendorCategoriesEndpoint = '/vendors/categories';
  
  // Product Endpoints
  static const String productsEndpoint = '/products';
  static const String productDetailsEndpoint = '/products'; // + /{id}
  
  // Order Endpoints
  static const String ordersEndpoint = '/orders';
  static const String orderDetailsEndpoint = '/orders'; // + /{id}
  static const String createOrderEndpoint = '/orders';
  static const String cancelOrderEndpoint = '/orders'; // + /{id}/cancel
  
  // Wallet Endpoints
  static const String walletEndpoint = '/wallet';
  static const String walletTransactionsEndpoint = '/wallet/transactions';
  static const String walletTopupEndpoint = '/wallet/topup';
  static const String walletWithdrawEndpoint = '/wallet/withdraw';
  
  // Coupon Endpoints
  static const String couponsEndpoint = '/coupons';
  static const String validateCouponEndpoint = '/coupons/validate';
  
  // Favorites Endpoints
  static const String favoriteRestaurantsEndpoint = '/favorites/restaurants';
  static const String favoriteItemsEndpoint = '/favorites/items';
  
  // Review Endpoints
  static const String reviewsEndpoint = '/reviews';
  
  // Chat Endpoints
  static const String chatMessagesEndpoint = '/chat/messages';
  static const String uploadChatMediaEndpoint = '/chat/upload';
  
  // Upload Endpoints
  static const String uploadImageEndpoint = '/upload/image';
  static const String uploadFileEndpoint = '/upload/file';
  
  // Zone Endpoints
  static const String zonesEndpoint = '/zones';
  
  // Settings Endpoints
  static const String appSettingsEndpoint = '/settings';
  
  // Socket.IO Events
  static const String socketConnectEvent = 'connect';
  static const String socketDisconnectEvent = 'disconnect';
  static const String socketErrorEvent = 'error';
  
  // Order Events
  static const String socketJoinOrderEvent = 'join_order';
  static const String socketLeaveOrderEvent = 'leave_order';
  static const String socketOrderStatusUpdateEvent = 'order_status_update';
  static const String socketDriverLocationUpdateEvent = 'driver_location_update';
  static const String socketOrderCompletedEvent = 'order_completed';
  
  // Chat Events
  static const String socketJoinChatEvent = 'join_chat';
  static const String socketLeaveChatEvent = 'leave_chat';
  static const String socketSendMessageEvent = 'send_message';
  static const String socketNewMessageEvent = 'new_message';
  static const String socketMessageReadEvent = 'message_read';
  
  // App Settings
  static const String appName = 'Foodie Customer';
  static const String appVersion = '1.0.0';
  
  // Default Values
  static const String defaultCountryCode = '+251'; // Ethiopia
  static const double defaultLatitude = 9.0320; // Addis Ababa
  static const double defaultLongitude = 38.7469; // Addis Ababa
  static const String defaultCurrency = 'ETB';
  static const String defaultLanguage = 'en';
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Map Settings
  static const double defaultZoom = 15.0;
  static const double minZoom = 10.0;
  static const double maxZoom = 20.0;
  
  // Cart Settings
  static const int maxCartItems = 50;
  static const int minOrderAmount = 0;
  
  // Image Settings
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Validation
  static const int minPasswordLength = 6;
  static const int minPhoneLength = 9;
  static const int maxPhoneLength = 15;
}
