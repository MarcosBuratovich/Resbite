import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_notification.freezed.dart';
part 'user_notification.g.dart';

enum NotificationType {
  invitation, // Invited to a resbite
  reminder, // Reminder about upcoming resbite
  update, // Update to a resbite (time, location, etc.)
  join, // New participant joined resbite
  cancel, // Resbite was cancelled
  system, // System notification
}

@freezed
abstract class UserNotification with _$UserNotification {
  const factory UserNotification({
    required String id,
    required String title,
    required String message,
    required DateTime timestamp,
    required NotificationType type,
    required String userId,
    String? resbiteId,
    String? activityId,
    String? senderId,
    String? imageUrl,
    @Default(false) bool read,
    String? actionUrl,
    Map<String, dynamic>? additionalData,
  }) = _UserNotification;

  factory UserNotification.fromJson(Map<String, dynamic> json) =>
      _$UserNotificationFromJson(json);

  static UserNotification fromSupabase(Map<String, dynamic> json) {
    // Convert string type to enum
    final typeStr = json['type'] as String? ?? 'system';
    final NotificationType type = NotificationType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => NotificationType.system,
    );

    return UserNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      type: type,
      userId: json['user_id'] ?? '',
      resbiteId: json['resbite_id'],
      activityId: json['activity_id'],
      senderId: json['sender_id'],
      imageUrl: json['image_url'],
      read: json['read'] ?? false,
      actionUrl: json['action_url'],
      additionalData:
          json['additional_data'] != null
              ? Map<String, dynamic>.from(json['additional_data'])
              : null,
    );
  }
}
