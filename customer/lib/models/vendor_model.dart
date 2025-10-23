// Vendor Model - Matches Prisma schema exactly
class VendorModel {
  String? id;
  String title;
  String? description;
  String? photo;
  double latitude;
  double longitude;
  String location;
  String phoneNumber;
  String categoryId;
  double restaurantCost;
  bool hidephotos;
  bool reststatus;
  int reviewsCount;
  double reviewsSum;
  String zoneId;
  String? fcmToken;
  double walletAmount;
  String? createdAt;
  String? updatedAt;
  
  // Relations
  List<VendorPhoto>? photos;
  List<VendorWorkingHour>? workingHours;
  List<VendorSpecialDiscount>? specialDiscounts;
  
  VendorModel({
    this.id,
    required this.title,
    this.description,
    this.photo,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.phoneNumber,
    required this.categoryId,
    this.restaurantCost = 0.0,
    this.hidephotos = false,
    this.reststatus = true,
    this.reviewsCount = 0,
    this.reviewsSum = 0.0,
    required this.zoneId,
    this.fcmToken,
    this.walletAmount = 0.0,
    this.createdAt,
    this.updatedAt,
    this.photos,
    this.workingHours,
    this.specialDiscounts,
  });
  
  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      photo: json['photo'],
      latitude: _parseDouble(json['latitude']) ?? 0.0,
      longitude: _parseDouble(json['longitude']) ?? 0.0,
      location: json['location'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      categoryId: json['categoryId'] ?? '',
      restaurantCost: _parseDouble(json['restaurantCost']) ?? 0.0,
      hidephotos: json['hidephotos'] ?? false,
      reststatus: json['reststatus'] ?? true,
      reviewsCount: json['reviewsCount'] ?? 0,
      reviewsSum: _parseDouble(json['reviewsSum']) ?? 0.0,
      zoneId: json['zoneId'] ?? '',
      fcmToken: json['fcmToken'],
      walletAmount: _parseDouble(json['walletAmount']) ?? 0.0,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      photos: json['photos'] != null
          ? (json['photos'] as List).map((e) => VendorPhoto.fromJson(e)).toList()
          : null,
      workingHours: json['workingHours'] != null
          ? (json['workingHours'] as List).map((e) => VendorWorkingHour.fromJson(e)).toList()
          : null,
      specialDiscounts: json['specialDiscounts'] != null
          ? (json['specialDiscounts'] as List).map((e) => VendorSpecialDiscount.fromJson(e)).toList()
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'photo': photo,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'phoneNumber': phoneNumber,
      'categoryId': categoryId,
      'restaurantCost': restaurantCost,
      'hidephotos': hidephotos,
      'reststatus': reststatus,
      'reviewsCount': reviewsCount,
      'reviewsSum': reviewsSum,
      'zoneId': zoneId,
      'fcmToken': fcmToken,
      'walletAmount': walletAmount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'photos': photos?.map((e) => e.toJson()).toList(),
      'workingHours': workingHours?.map((e) => e.toJson()).toList(),
      'specialDiscounts': specialDiscounts?.map((e) => e.toJson()).toList(),
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

// VendorPhoto Model
class VendorPhoto {
  String? id;
  String vendorId;
  String url;
  
  VendorPhoto({
    this.id,
    required this.vendorId,
    required this.url,
  });
  
  factory VendorPhoto.fromJson(Map<String, dynamic> json) {
    return VendorPhoto(
      id: json['id'],
      vendorId: json['vendorId'] ?? '',
      url: json['url'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'url': url,
    };
  }
}

// VendorWorkingHour Model
class VendorWorkingHour {
  String? id;
  String vendorId;
  String day;
  String? fromTime;
  String? toTime;
  
  VendorWorkingHour({
    this.id,
    required this.vendorId,
    required this.day,
    this.fromTime,
    this.toTime,
  });
  
  factory VendorWorkingHour.fromJson(Map<String, dynamic> json) {
    return VendorWorkingHour(
      id: json['id'],
      vendorId: json['vendorId'] ?? '',
      day: json['day'] ?? '',
      fromTime: json['fromTime'],
      toTime: json['toTime'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'day': day,
      'fromTime': fromTime,
      'toTime': toTime,
    };
  }
}

// VendorSpecialDiscount Model
class VendorSpecialDiscount {
  String? id;
  String vendorId;
  String day;
  String discount;
  String fromTime;
  String toTime;
  String type; // percentage, amount
  
  VendorSpecialDiscount({
    this.id,
    required this.vendorId,
    required this.day,
    required this.discount,
    required this.fromTime,
    required this.toTime,
    required this.type,
  });
  
  factory VendorSpecialDiscount.fromJson(Map<String, dynamic> json) {
    return VendorSpecialDiscount(
      id: json['id'],
      vendorId: json['vendorId'] ?? '',
      day: json['day'] ?? '',
      discount: json['discount']?.toString() ?? '0',
      fromTime: json['fromTime'] ?? '',
      toTime: json['toTime'] ?? '',
      type: json['type'] ?? 'percentage',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'day': day,
      'discount': discount,
      'fromTime': fromTime,
      'toTime': toTime,
      'type': type,
    };
  }
}
