// Product Model - Matches Prisma schema
class ProductModel {
  String? id;
  String vendorId;
  String name;
  String? description;
  String? photo;
  double price;
  double? discountPrice;
  String? categoryId;
  bool isAvailable;
  String? createdAt;
  String? updatedAt;
  
  // Relations
  List<ProductPhoto>? photos;
  
  ProductModel({
    this.id,
    required this.vendorId,
    required this.name,
    this.description,
    this.photo,
    required this.price,
    this.discountPrice,
    this.categoryId,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
    this.photos,
  });
  
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      vendorId: json['vendorId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      photo: json['photo'],
      price: _parseDouble(json['price']) ?? 0.0,
      discountPrice: json['discountPrice'] != null ? _parseDouble(json['discountPrice']) : null,
      categoryId: json['categoryId'],
      isAvailable: json['isAvailable'] ?? true,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      photos: json['photos'] != null
          ? (json['photos'] as List).map((e) => ProductPhoto.fromJson(e)).toList()
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'name': name,
      'description': description,
      'photo': photo,
      'price': price,
      'discountPrice': discountPrice,
      'categoryId': categoryId,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'photos': photos?.map((e) => e.toJson()).toList(),
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

// ProductPhoto Model
class ProductPhoto {
  String? id;
  String productId;
  String url;
  
  ProductPhoto({
    this.id,
    required this.productId,
    required this.url,
  });
  
  factory ProductPhoto.fromJson(Map<String, dynamic> json) {
    return ProductPhoto(
      id: json['id'],
      productId: json['productId'] ?? '',
      url: json['url'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'url': url,
    };
  }
}
