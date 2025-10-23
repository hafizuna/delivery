// WalletTransaction Model - Matches Prisma schema
class WalletTransactionModel {
  String? id;
  String userId;
  double amount;
  String type; // credit, debit
  String transactionType; // order, refund, topup, withdrawal
  String? orderId;
  String? note;
  String? createdAt;
  
  WalletTransactionModel({
    this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.transactionType,
    this.orderId,
    this.note,
    this.createdAt,
  });
  
  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'],
      userId: json['userId'] ?? '',
      amount: _parseDouble(json['amount']) ?? 0.0,
      type: json['type'] ?? 'debit',
      transactionType: json['transactionType'] ?? 'order',
      orderId: json['orderId'],
      note: json['note'],
      createdAt: json['createdAt'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type,
      'transactionType': transactionType,
      'orderId': orderId,
      'note': note,
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
