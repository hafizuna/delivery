// Tax Model - For tax calculations
class TaxModel {
  String? id;
  String title;
  String type; // percentage, amount
  double value;
  bool isActive;
  
  TaxModel({
    this.id,
    required this.title,
    required this.type,
    required this.value,
    this.isActive = true,
  });
  
  factory TaxModel.fromJson(Map<String, dynamic> json) {
    return TaxModel(
      id: json['id'],
      title: json['title'] ?? '',
      type: json['type'] ?? 'percentage',
      value: _parseDouble(json['value']) ?? 0.0,
      isActive: json['isActive'] ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'value': value,
      'isActive': isActive,
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
