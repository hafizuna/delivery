// Review Model - Matches Prisma schema
class ReviewModel {
  String? id;
  String userId;
  String? vendorId;
  String? productId;
  double rating;
  String? comment;
  List<String>? photos;
  String? createdAt;
  
  ReviewModel({
    this.id,
    required this.userId,
    this.vendorId,
    this.productId,
    required this.rating,
    this.comment,
    this.photos,
    this.createdAt,
  });
  
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      userId: json['userId'] ?? '',
      vendorId: json['vendorId'],
      productId: json['productId'],
      rating: _parseDouble(json['rating']) ?? 0.0,
      comment: json['comment'],
      photos: json['photos'] != null ? List<String>.from(json['photos']) : null,
      createdAt: json['createdAt'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'vendorId': vendorId,
      'productId': productId,
      'rating': rating,
      'comment': comment,
      'photos': photos,
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
