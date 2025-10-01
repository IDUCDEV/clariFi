// Based on the 'notifications' table
class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final Map<String, dynamic> payload;
  final bool delivered;
  final DateTime? deliveredAt;
  final DateTime? scheduledAt;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.payload,
    required this.delivered,
    this.deliveredAt,
    this.scheduledAt,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      payload: Map<String, dynamic>.from(json['payload']),
      delivered: json['delivered'] ?? false,
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at']) : null,
      scheduledAt: json['scheduled_at'] != null ? DateTime.parse(json['scheduled_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'payload': payload,
      'delivered': delivered,
      'delivered_at': deliveredAt?.toIso8601String(),
      'scheduled_at': scheduledAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}