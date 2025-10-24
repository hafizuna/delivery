import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../config/app_config.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/coupon_model.dart';
import 'package:customer/models/tax_model.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/models/zone_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/preferences.dart';
import 'package:customer/widget/permission_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

// Global cart items (stored locally in SQLite)
RxList<CartProductModel> cartItem = <CartProductModel>[].obs;

class Constant {
  // User Roles
  static String userRoleDriver = 'driver';
  static String userRoleCustomer = 'customer';
  static String userRoleVendor = 'restaurant';
  
  // Current User & Location
  static ShippingAddress selectedLocation = ShippingAddress(
    latitude: 9.0320,  // Addis Ababa Central (matches seed data)
    longitude: 38.7469,
    address: 'Addis Ababa, Ethiopia',
    locality: 'Addis Ababa Central',
  );
  static UserModel? userModel;
  
  // Zone
  static bool isZoneAvailable = false;
  static ZoneModel? selectedZone;
  
  // App Settings
  static String theme = "theme_1";
  // Use secure configuration from AppConfig
  static String get mapAPIKey => AppConfig.googleMapsApiKey;
  static String placeHolderImage = "";
  static String radius = "50";
  static String driverRadios = "50";
  static String distanceType = "km";
  static String placeholderImage = "";
  static String googlePlayLink = "";
  static String appStoreLink = "";
  static String appVersion = "";
  static String websiteUrl = "";
  static String termsAndConditions = "";
  static String privacyPolicy = "";
  static String supportURL = "";
  static String minimumAmountToDeposit = "0.0";
  static String minimumAmountToWithdrawal = "0.0";
  static String? referralAmount = "0.0";
  static bool? walletSetting = true;
  static bool? storyEnable = true;
  static bool? specialDiscountOffer = true;
  static String selectedMapType = 'google';
  static String? mapType = "google";
  static bool? isEnabledForCustomer = true;
  
  // Order Status Constants
  static const String orderPlaced = "Order_Placed";
  static const String orderAccepted = "Order_Accepted";
  static const String orderRejected = "Order_Rejected";
  static const String driverPending = "Driver_Pending";
  static const String driverAccepted = "Driver_Accepted";
  static const String driverRejected = "Driver_Rejected";
  static const String orderShipped = "Order_Shipped";
  static const String orderInTransit = "In_Transit";
  static const String orderCompleted = "Order_Completed";
  static const String orderCancelled = "Order_Cancelled";
  
  // Notification Types
  static String newOrderPlaced = "order_placed";
  static String scheduleOrder = "schedule_order";
  static String restaurantAccepted = "restaurant_accepted";
  static String restaurantRejected = "restaurant_rejected";
  static String driverCompleted = "driver_completed";
  static String takeawayCompleted = "takeaway_completed";
  
  // Tax & Commission
  static List<TaxModel>? taxList = [];
  static double platformCommissionPercent = 10.0;
  static double deliveryCommissionPercent = 5.0;
  
  // Currency Settings
  static String currencySymbol = "ETB";
  static bool currencySymbolAtRight = false;
  static int currencyDecimalDigits = 2;
  
  /// Format amount with currency
  static String amountShow({required String? amount}) {
    if (amount == null || amount.isEmpty) {
      return currencySymbolAtRight 
        ? "0.00 $currencySymbol" 
        : "$currencySymbol 0.00";
    }
    
    String formatted = double.parse(amount).toStringAsFixed(currencyDecimalDigits);
    return currencySymbolAtRight 
      ? "$formatted $currencySymbol" 
      : "$currencySymbol $formatted";
  }
  
  /// Get status color
  static Color statusColor({required String? status}) {
    switch (status) {
      case orderPlaced:
      case driverPending:
        return AppThemeData.secondary300;
      case orderAccepted:
      case driverAccepted:
      case orderCompleted:
        return AppThemeData.success400;
      case orderRejected:
      case driverRejected:
      case orderCancelled:
        return AppThemeData.danger300;
      case orderShipped:
      case orderInTransit:
        return AppThemeData.warning300;
      default:
        return AppThemeData.grey500;
    }
  }
  
  /// Get status text color
  static Color statusTextColor({required String? status}) {
    return AppThemeData.grey50;
  }
  
  /// Calculate distance between two coordinates (Haversine formula)
  static String getDistance({
    required String lat1,
    required String lng1,
    required String lat2,
    required String lng2,
  }) {
    double startLatitude = double.parse(lat1);
    double startLongitude = double.parse(lng1);
    double endLatitude = double.parse(lat2);
    double endLongitude = double.parse(lng2);
    
    double distanceInMeters = Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
    
    double distance = distanceInMeters / 1000; // Convert to km
    
    if (distanceType == "mile") {
      distance = distance * 0.621371; // Convert to miles
    }
    
    return distance.toStringAsFixed(2);
  }
  
  /// Calculate discount amount
  static double calculateDiscount({
    required double amount,
    required CouponModel coupon,
  }) {
    if (coupon.discountType == "percentage") {
      double discount = (amount * double.parse(coupon.discount.toString())) / 100;
      if (coupon.maxDiscount != null && discount > double.parse(coupon.maxDiscount.toString())) {
        return double.parse(coupon.maxDiscount.toString());
      }
      return discount;
    } else {
      return double.parse(coupon.discount.toString());
    }
  }
  
  /// Calculate tax amount
  static double calculateTax({
    required String amount,
    required TaxModel taxModel,
  }) {
    if (taxModel.type == "percentage") {
      return (double.parse(amount) * double.parse(taxModel.value.toString())) / 100;
    } else {
      return double.parse(taxModel.value.toString());
    }
  }
  
  /// Convert timestamp to readable date format
  static String timestampToDateTime(String timestamp) {
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
    } catch (e) {
      return timestamp; // Return original if parsing fails
    }
  }
  
  /// Show empty view widget
  static Widget showEmptyView({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppThemeData.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            message ?? "No data found",
            style: TextStyle(
              color: AppThemeData.grey600,
              fontSize: 16,
              fontFamily: AppThemeData.medium,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Show loader widget
  static Widget loader() {
    return Center(
      child: CircularProgressIndicator(
        color: AppThemeData.primary300,
      ),
    );
  }
  
  /// Calculate review rating
  static double calculateReview({
    required String reviewCount,
    required String reviewSum,
  }) {
    if (reviewCount == "0" || reviewSum == "0") {
      return 0.0;
    }
    return double.parse(reviewSum) / double.parse(reviewCount);
  }
  
  /// Check if point is in polygon (for zone checking)
  static bool isPointInPolygon(LatLng point, List<dynamic> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      if (rayCastIntersect(point, polygon[j], polygon[j + 1])) {
        intersectCount++;
      }
    }
    return ((intersectCount % 2) == 1);
  }
  
  static bool rayCastIntersect(LatLng point, dynamic aPoint, dynamic bPoint) {
    double px = point.longitude;
    double py = point.latitude;
    double ax = aPoint['longitude'];
    double ay = aPoint['latitude'];
    double bx = bPoint['longitude'];
    double by = bPoint['latitude'];
    
    if (ay > by) {
      ax = bPoint['longitude'];
      ay = bPoint['latitude'];
      bx = aPoint['longitude'];
      by = aPoint['latitude'];
    }
    
    if (py == ay || py == by) py += 0.00000001;
    if ((py > by || py < ay) || (px > math.max(ax, bx))) return false;
    if (px < math.min(ax, bx)) return true;
    
    double red = (ax != bx) ? ((by - ay) / (bx - ax)) : double.infinity;
    double blue = (ax != px) ? ((py - ay) / (px - ax)) : double.infinity;
    return (blue >= red);
  }
  
  /// Generate UUID
  static String getUuid() {
    return const Uuid().v4();
  }
  
  /// Get bytes from asset for map markers
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
  
  /// Show permission dialog
  static Future<void> showLocationPermissionDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return const PermissionDialog();
      },
    );
  }
  
  /// Launch URL
  static Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ShowToastDialog.showToast('Could not launch $url');
    }
  }
  
  /// Make phone call
  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  /// Simple loading widget for network images
  static Widget simpleLoader() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Check permission helper for location
  static Future<bool> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }
}
