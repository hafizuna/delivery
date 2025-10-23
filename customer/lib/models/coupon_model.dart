// Coupon Model - Matches Prisma schema
class CouponModel {
  String? id;
  String code;
  String? description;
  double discount;
  String discountType; // percentage, amount
  double? minOrder;
  double? maxDiscount;
  String validFrom;
  String validTo;
  bool isActive;
  String? createdAt;
  
  CouponModel({
    this.id,
    required this.code,
    this.description,
    required this.discount,
    required this.discountType,
    this.minOrder,
    this.maxDiscount,
    required this.validFrom,
    required this.validTo,
    this.isActive = true,
    this.createdAt,
  });
  
  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'],
      code: json['code'] ?? '',
      description: json['description'],
      discount: _parseDouble(json['discount']) ?? 0.0,
      discountType: json['discountType'] ?? 'percentage',
      minOrder: _parseDouble(json['minOrder']),
      maxDiscount: _parseDouble(json['maxDiscount']),
      validFrom: json['validFrom'] ?? '',
      validTo: json['validTo'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'discount': discount,
      'discountType': discountType,
      'minOrder': minOrder,
      'maxDiscount': maxDiscount,
      'validFrom': validFrom,
      'validTo': validTo,
      'isActive': isActive,
      'createdAt': createdAt,
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
