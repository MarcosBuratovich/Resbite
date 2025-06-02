import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/logger.dart';
import 'providers.dart';
import '../models/notification.dart';

class NotificationService {
  final supabase.SupabaseClient _supabase;

  NotificationService(this._supabase);

  // Get notifications for a user
  Future<List<AppNotification>> getNotifications(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      if (userId.isEmpty) {
        AppLogger.error(
          'Failed to get notifications: userId is empty',
          null,
          null,
        );
        return [];
      }

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List<dynamic>)
          .map((data) => AppNotification.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      AppLogger.error('Failed to get notifications', e, stack);
      return [];
    }
  }

  // Mark notification as read (does not change status)
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      if (notificationId.isEmpty) {
        AppLogger.error(
          'Failed to mark notification as read: notificationId is empty',
          null,
          null,
        );
        return;
      }

      await _supabase
          .from('notifications')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('id', notificationId);

      AppLogger.info('Marked notification as read: $notificationId');
    } catch (e, stack) {
      AppLogger.error('Failed to mark notification as read', e, stack);
      // Don't rethrow - non-critical operation
    }
  }

  // Mark all notifications as read for a user
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      if (userId.isEmpty) {
        AppLogger.error(
          'Failed to mark all notifications as read: userId is empty',
          null,
          null,
        );
        return;
      }

      await _supabase
          .from('notifications')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('user_id', userId);

      AppLogger.info('Marked all notifications as read for user: $userId');
    } catch (e, stack) {
      AppLogger.error('Failed to mark all notifications as read', e, stack);
      // Don't rethrow - non-critical operation
    }
  }

  // Create notification row (generic)
  Future<void> sendNotification({
    required String userId,
    required NotificationType type,
    required Map<String, dynamic> payload,
    NotificationStatus status = NotificationStatus.pending,
  }) async {
    try {
      if (userId.isEmpty) {
        AppLogger.error(
          'Failed to send notification: userId is empty',
          null,
          null,
        );
        return;
      }

      await _supabase.from('notifications').insert({
        'user_id': userId,
        'type': type.sqlValue,
        'payload': payload,
        'status': status.sqlValue,
      });

      AppLogger.info('Notification sent to user: $userId');
    } catch (e, stack) {
      AppLogger.error('Failed to send notification', e, stack);
      // Don't rethrow - non-critical operation
    }
  }

  // Update status (accept / decline)
  Future<void> updateStatus(String notificationId, NotificationStatus newStatus) async {
    try {
      await _supabase
          .from('notifications')
          .update({
            'status': newStatus.sqlValue,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);
    } catch (e, st) {
      AppLogger.error('Failed to update notification status', e, st);
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final supabase.SupabaseClient supabaseClient = ref.watch(supabaseClientProvider);
  return NotificationService(supabaseClient);
});
