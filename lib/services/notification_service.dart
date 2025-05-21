import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/logger.dart';
import 'providers.dart'; 
import '../models/notification.dart'; // Import the new Notification model

// TODO: Consider creating a Notification model in lib/models/notification.dart - DONE
// and update getNotifications to return Future<List<Notification>>. - DONE

class NotificationService {
  final SupabaseClient _supabase;

  NotificationService(this._supabase);

  // Get notifications for a user
  Future<List<Notification>> getNotifications(
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
          .select() // Select all fields for the Notification model
          .eq('user_id', userId)
          .order('timestamp', ascending: false)
          .range(offset, offset + limit - 1);

      // The response is List<dynamic> where each dynamic is Map<String, dynamic>
      final notifications = (response as List<dynamic>)
          .map((data) => Notification.fromJson(data as Map<String, dynamic>))
          .toList();
      return notifications;
    } catch (e, stack) {
      AppLogger.error('Failed to get notifications', e, stack);
      return [];
    }
  }

  // Mark notification as read
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
          .update({'is_read': true})
          .eq('id', notificationId);

      AppLogger.info('Marked notification as read: $notificationId'); // Changed from error to info
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
          .update({'is_read': true})
          .eq('user_id', userId);

      AppLogger.info('Marked all notifications as read for user: $userId'); // Changed from error to info
    } catch (e, stack) {
      AppLogger.error('Failed to mark all notifications as read', e, stack);
      // Don't rethrow - non-critical operation
    }
  }

  // Send a notification to a user
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? resbiteId,
    String? activityId,
    String? senderId,
    String? imageUrl,
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
        'title': title,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'type': type,
        'resbite_id': resbiteId,
        'activity_id': activityId,
        'sender_id': senderId,
        'is_read': false,
        'image_url': imageUrl,
      });

      AppLogger.info('Notification sent to user: $userId'); // Changed from error to info
    } catch (e, stack) {
      AppLogger.error('Failed to send notification', e, stack);
      // Don't rethrow - non-critical operation
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return NotificationService(supabaseClient);
});

// Helper provider for Supabase client (if not already globally available like this)
// This assumes supabaseClientProvider is defined elsewhere (e.g., in services/providers.dart)
// If not, you might need to define it or pass Supabase.instance.client directly.
