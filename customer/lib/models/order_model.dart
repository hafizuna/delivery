// Order Model - Matches Prisma schema exactly
class OrderModel {
  String? id;
  String customerId;
  String vendorId;
  String? driverId;
  String status; // Order_Placed, Order_Accepted, etc.
  
  // Address
  String? addressId;
  String? deliveryAddress;
  double? deliveryLatitude;
  double? deliveryLongitude;
  String? deliveryLocality;
  String? deliveryLandmark;
  
  // Pricing
  double subtotal;
  double discount;
  double deliveryCharge;
  double tipAmount;
  double totalAmount;
  
  // Platform commission
  double platformCommission;
  double deliveryCommission;
  
  // Discount/Coupon
  String? couponId;
  String? couponCode;
  Map<String, dynamic>? specialDiscount;
  
  // Payment
  String paymentMethod;
  String paymentStatus;
  
  // Delivery
  bool takeAway;
  String? estimatedTimeToPrepare;
  String? scheduleTime;
  String? triggerDelivery;
  
  // Notes
  String? notes;
  
  // Driver rejection tracking
  List<String>? rejectedByDrivers;
  
  // Timestamps
  String? createdAt;
  String? updatedAt;
  String? completedAt;
  
  // Relations
  List<OrderItem>? items;
  
  OrderModel({
    this.id,
    required this.customerId,
    required this.vendorId,
    this.driverId,
    this.status = 'Order_Placed',
    this.addressId,
    this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.deliveryLocality,
    this.deliveryLandmark,
    required this.subtotal,
    this.discount = 0.0,
    this.deliveryCharge = 0.0,
    this.tipAmount = 0.0,
    required this.totalAmount,
    this.platformCommission = 0.0,
    this.deliveryCommission = 0.0,
    this.couponId,
    this.couponCode,
    this.specialDiscount,
    required this.paymentMethod,
    this.paymentStatus = 'pending',
    this.takeAway = false,
    this.estimatedTimeToPrepare,
    this.scheduleTime,
    this.triggerDelivery,
    this.notes,
    this.rejectedByDrivers,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.items,
  });
  
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      customerId: json['customerId'] ?? '',
      vendorId: json['vendorId'] ?? '',
      driverId: json['driverId'],
      status: json['status'] ?? 'Order_Placed',
      addressId: json['addressId'],
      deliveryAddress: json['deliveryAddress'],
      deliveryLatitude: _parseDouble(json['deliveryLatitude']),
      deliveryLongitude: _parseDouble(json['deliveryLongitude']),
      deliveryLocality: json['deliveryLocality'],
      deliveryLandmark: json['deliveryLandmark'],
      subtotal: _parseDouble(json['subtotal']) ?? 0.0,
      discount: _parseDouble(json['discount']) ?? 0.0,
      deliveryCharge: _parseDouble(json['deliveryCharge']) ?? 0.0,
      tipAmount: _parseDouble(json['tipAmount']) ?? 0.0,
      totalAmount: _parseDouble(json['totalAmount']) ?? 0.0,
      platformCommission: _parseDouble(json['platformCommission']) ?? 0.0,
      deliveryCommission: _parseDouble(json['deliveryCommission']) ?? 0.0,
      couponId: json['couponId'],
      couponCode: json['couponCode'],
      specialDiscount: json['specialDiscount'] != null 
          ? Map<String, dynamic>.from(json['specialDiscount'])
          : null,
      paymentMethod: json['paymentMethod'] ?? '',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      takeAway: json['takeAway'] ?? false,
      estimatedTimeToPrepare: json['estimatedTimeToPrepare'],
      scheduleTime: json['scheduleTime'],
      triggerDelivery: json['triggerDelivery'],
      notes: json['notes'],
      rejectedByDrivers: json['rejectedByDrivers'] != null
          ? List<String>.from(json['rejectedByDrivers'])
          : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      completedAt: json['completedAt'],
      items: json['items'] != null
          ? (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList()
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'vendorId': vendorId,
      'driverId': driverId,
      'status': status,
      'addressId': addressId,
      'deliveryAddress': deliveryAddress,
      'deliveryLatitude': deliveryLatitude,
      'deliveryLongitude': deliveryLongitude,
      'deliveryLocality': deliveryLocality,
      'deliveryLandmark': deliveryLandmark,
      'subtotal': subtotal,
      'discount': discount,
      'deliveryCharge': deliveryCharge,
      'tipAmount': tipAmount,
      'totalAmount': totalAmount,
      'platformCommission': platformCommission,
      'deliveryCommission': deliveryCommission,
      'couponId': couponId,
      'couponCode': couponCode,
      'specialDiscount': specialDiscount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'takeAway': takeAway,
      'estimatedTimeToPrepare': estimatedTimeToPrepare,
      'scheduleTime': scheduleTime,
      'triggerDelivery': triggerDelivery,
      'notes': notes,
      'rejectedByDrivers': rejectedByDrivers,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'completedAt': completedAt,
      'items': items?.map((e) => e.toJson()).toList(),
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

// OrderItem Model
class OrderItem {
  String? id;
  String orderId;
  String productId;
  String productName;
  int quantity;
  double price;
  double? discountPrice;
  
  OrderItem({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.discountPrice,
  });
  
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['orderId'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: _parseDouble(json['price']) ?? 0.0,
      discountPrice: _parseDouble(json['discountPrice']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'discountPrice': discountPrice,
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
