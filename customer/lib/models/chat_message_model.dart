// ChatMessage Model - Matches Prisma schema
class ChatMessageModel {
  String? id;
  String orderId;
  String senderId;
  String receiverId;
  String message;
  String messageType; // text, image, video, audio
  String? mediaUrl;
  String? mediaMimeType;
  String? videoThumbnail;
  bool isRead;
  String? createdAt;
  
  ChatMessageModel({
    this.id,
    required this.orderId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.messageType = 'text',
    this.mediaUrl,
    this.mediaMimeType,
    this.videoThumbnail,
    this.isRead = false,
    this.createdAt,
  });
  
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      orderId: json['orderId'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      message: json['message'] ?? '',
      messageType: json['messageType'] ?? 'text',
      mediaUrl: json['mediaUrl'],
      mediaMimeType: json['mediaMimeType'],
      videoThumbnail: json['videoThumbnail'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'messageType': messageType,
      'mediaUrl': mediaUrl,
      'mediaMimeType': mediaMimeType,
      'videoThumbnail': videoThumbnail,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }
}
