// User Model - Matches Prisma schema exactly
class UserModel {
  String? id;
  String phoneNumber;
  String countryCode;
  String firstName;
  String lastName;
  String? email;
  String? profilePictureURL;
  String? fcmToken;
  double walletAmount;
  bool active;
  bool isActive;
  bool isDocumentVerify;
  String role; // customer, driver, restaurant, admin
  String? provider;
  String? appIdentifier;
  String? zoneId;
  
  // Driver specific fields
  String? carName;
  String? carNumber;
  String? carPictureURL;
  double? latitude;
  double? longitude;
  double? rotation;
  
  // Restaurant owner specific
  String? vendorId;
  
  // Timestamps (as String - ISO 8601)
  String? createdAt;
  String? updatedAt;
  
  // Relations
  List<ShippingAddress>? shippingAddresses;
  
  UserModel({
    this.id,
    required this.phoneNumber,
    this.countryCode = '+251',
    required this.firstName,
    required this.lastName,
    this.email,
    this.profilePictureURL,
    this.fcmToken,
    this.walletAmount = 0.0,
    this.active = true,
    this.isActive = true,
    this.isDocumentVerify = false,
    this.role = 'customer',
    this.provider,
    this.appIdentifier,
    this.zoneId,
    this.carName,
    this.carNumber,
    this.carPictureURL,
    this.latitude,
    this.longitude,
    this.rotation,
    this.vendorId,
    this.createdAt,
    this.updatedAt,
    this.shippingAddresses,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phoneNumber: json['phoneNumber'] ?? '',
      countryCode: json['countryCode'] ?? '+251',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'],
      profilePictureURL: json['profilePictureURL'],
      fcmToken: json['fcmToken'],
      walletAmount: _parseDouble(json['walletAmount']) ?? 0.0,
      active: json['active'] ?? true,
      isActive: json['isActive'] ?? true,
      isDocumentVerify: json['isDocumentVerify'] ?? false,
      role: json['role'] ?? 'customer',
      provider: json['provider'],
      appIdentifier: json['appIdentifier'],
      zoneId: json['zoneId'],
      carName: json['carName'],
      carNumber: json['carNumber'],
      carPictureURL: json['carPictureURL'],
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      rotation: _parseDouble(json['rotation']),
      vendorId: json['vendorId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      shippingAddresses: json['shippingAddresses'] != null
          ? (json['shippingAddresses'] as List)
              .map((e) => ShippingAddress.fromJson(e))
              .toList()
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'countryCode': countryCode,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profilePictureURL': profilePictureURL,
      'fcmToken': fcmToken,
      'walletAmount': walletAmount,
      'active': active,
      'isActive': isActive,
      'isDocumentVerify': isDocumentVerify,
      'role': role,
      'provider': provider,
      'appIdentifier': appIdentifier,
      'zoneId': zoneId,
      'carName': carName,
      'carNumber': carNumber,
      'carPictureURL': carPictureURL,
      'latitude': latitude,
      'longitude': longitude,
      'rotation': rotation,
      'vendorId': vendorId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'shippingAddresses': shippingAddresses?.map((e) => e.toJson()).toList(),
    };
  }
  
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

// ShippingAddress Model - Matches Prisma schema
class ShippingAddress {
  String? id;
  String? userId;
  String address;
  String addressAs; // Home, Work, Other
  String? landmark;
  String locality;
  double latitude;
  double longitude;
  bool isDefault;
  String? createdAt;
  
  ShippingAddress({
    this.id,
    this.userId,
    this.address = '',
    this.addressAs = 'Home',
    this.landmark,
    this.locality = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.isDefault = false,
    this.createdAt,
  });
  
  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id'],
      userId: json['userId'],
      address: json['address'] ?? '',
      addressAs: json['addressAs'] ?? 'Home',
      landmark: json['landmark'],
      locality: json['locality'] ?? '',
      latitude: _parseDouble(json['latitude']) ?? 0.0,
      longitude: _parseDouble(json['longitude']) ?? 0.0,
      isDefault: json['isDefault'] ?? false,
      createdAt: json['createdAt'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'address': address,
      'addressAs': addressAs,
      'landmark': landmark,
      'locality': locality,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
      'createdAt': createdAt,
    };
  }
  
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
