import 'package:intl/intl.dart';

class Notification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final DateTime timestamp;
  final String type;
  final bool isRead;
  final String? resbiteId;
  final String? activityId;
  final String? senderId;
  final String? imageUrl;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    required this.isRead,
    this.resbiteId,
    this.activityId,
    this.senderId,
    this.imageUrl,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] as String,
      isRead: json['is_read'] as bool,
      resbiteId: json['resbite_id'] as String?,
      activityId: json['activity_id'] as String?,
      senderId: json['sender_id'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'is_read': isRead,
      'resbite_id': resbiteId,
      'activity_id': activityId,
      'sender_id': senderId,
      'image_url': imageUrl,
    };
  }

  // Helper for display
  String get formattedTimestamp {
    return DateFormat('MMM d, yyyy hh:mm a').format(timestamp);
  }
}
