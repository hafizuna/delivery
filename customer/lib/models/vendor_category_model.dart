// VendorCategory Model - Matches Prisma schema
class VendorCategoryModel {
  String? id;
  String title;
  String? photo;
  String? createdAt;
  
  VendorCategoryModel({
    this.id,
    required this.title,
    this.photo,
    this.createdAt,
  });
  
  factory VendorCategoryModel.fromJson(Map<String, dynamic> json) {
    return VendorCategoryModel(
      id: json['id'],
      title: json['title'] ?? '',
      photo: json['photo'],
      createdAt: json['createdAt'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'photo': photo,
      'createdAt': createdAt,
    };
  }
}
