import 'package:intl/intl.dart';

/// Matches `public.notifications` table (see migration 2025-05-22)
class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final Map<String, dynamic> payload;
  final NotificationStatus status;
  final DateTime createdAt;
  final DateTime? readAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.payload,
    required this.status,
    required this.createdAt,
    this.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: NotificationType.values
          .firstWhere((e) => e.sqlValue == json['type'] as String),
      payload: Map<String, dynamic>.from(json['payload'] as Map<String, dynamic>),
      status: NotificationStatus.values
          .firstWhere((e) => e.sqlValue == json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt:
          json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'type': type.sqlValue,
        'payload': payload,
        'status': status.sqlValue,
        'created_at': createdAt.toIso8601String(),
        'read_at': readAt?.toIso8601String(),
      };

  String get formattedTimestamp =>
      DateFormat('MMM d, yyyy – hh:mm a').format(createdAt);
}

enum NotificationType { friendInvite, circleInvite, resbiteInvite }

extension NotificationTypeX on NotificationType {
  String get sqlValue => switch (this) {
        NotificationType.friendInvite => 'friend_invite',
        NotificationType.circleInvite => 'circle_invite',
        NotificationType.resbiteInvite => 'resbite_invite',
      };
}

enum NotificationStatus { pending, accepted, declined }

extension NotificationStatusX on NotificationStatus {
  String get sqlValue => switch (this) {
        NotificationStatus.pending => 'pending',
        NotificationStatus.accepted => 'accepted',
        NotificationStatus.declined => 'declined',
      };
}
