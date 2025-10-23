// Notification Model - Matches Prisma schema
class NotificationModel {
  String? id;
  String? userId;
  String title;
  String body;
  String type; // order, promotion, general
  Map<String, dynamic>? data;
  bool isRead;
  String? createdAt;
  
  NotificationModel({
    this.id,
    this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    this.isRead = false,
    this.createdAt,
  });
  
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['userId'],
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'general',
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }
}
