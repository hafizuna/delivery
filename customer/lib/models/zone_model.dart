// Zone Model - Matches Prisma schema
class ZoneModel {
  String? id;
  String name;
  List<dynamic> area; // Polygon coordinates
  bool publish;
  String? createdAt;
  
  ZoneModel({
    this.id,
    required this.name,
    required this.area,
    this.publish = true,
    this.createdAt,
  });
  
  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      id: json['id'],
      name: json['name'] ?? '',
      area: json['area'] ?? [],
      publish: json['publish'] ?? true,
      createdAt: json['createdAt'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'area': area,
      'publish': publish,
      'createdAt': createdAt,
    };
  }
}
