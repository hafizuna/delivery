// GiftCard Model - Matches Prisma schema
class GiftCardModel {
  String? id;
  String title;
  double amount;
  String? description;
  String? imageUrl;
  bool isActive;
  String? createdAt;
  
  GiftCardModel({
    this.id,
    required this.title,
    required this.amount,
    this.description,
    this.imageUrl,
    this.isActive = true,
    this.createdAt,
  });
  
  factory GiftCardModel.fromJson(Map<String, dynamic> json) {
    return GiftCardModel(
      id: json['id'],
      title: json['title'] ?? '',
      amount: _parseDouble(json['amount']) ?? 0.0,
      description: json['description'],
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'description': description,
      'imageUrl': imageUrl,
      'isActive': isActive,
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

// GiftCardPurchase Model
class GiftCardPurchaseModel {
  String? id;
  String giftCardId;
  String userId;
  String code;
  double amount;
  bool isRedeemed;
  String? redeemedBy;
  String? redeemedAt;
  String? createdAt;
  
  GiftCardPurchaseModel({
    this.id,
    required this.giftCardId,
    required this.userId,
    required this.code,
    required this.amount,
    this.isRedeemed = false,
    this.redeemedBy,
    this.redeemedAt,
    this.createdAt,
  });
  
  factory GiftCardPurchaseModel.fromJson(Map<String, dynamic> json) {
    return GiftCardPurchaseModel(
      id: json['id'],
      giftCardId: json['giftCardId'] ?? '',
      userId: json['userId'] ?? '',
      code: json['code'] ?? '',
      amount: _parseDouble(json['amount']) ?? 0.0,
      isRedeemed: json['isRedeemed'] ?? false,
      redeemedBy: json['redeemedBy'],
      redeemedAt: json['redeemedAt'],
      createdAt: json['createdAt'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'giftCardId': giftCardId,
      'userId': userId,
      'code': code,
      'amount': amount,
      'isRedeemed': isRedeemed,
      'redeemedBy': redeemedBy,
      'redeemedAt': redeemedAt,
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
