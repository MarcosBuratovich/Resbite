import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/notification.dart';
import '../../../../services/notification_service.dart' as ns;
import 'package:resbite_app/ui/screens/friends/services/friend_service_impl.dart' as fs;
import 'package:resbite_app/ui/screens/friends/services/invitation_service.dart' as inv;
import 'package:resbite_app/services/providers.dart' as app;

// removed unused rs import
class NotificationTile extends ConsumerWidget {
  const NotificationTile({super.key, required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final title = _title();
    final subtitle = _subtitle();

    return ListTile(
      leading: _icon(theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: _trailingButtons(ref, context),
      onTap: () {
        // mark read
        ref
            .read(ns.notificationServiceProvider)
            .markNotificationAsRead(notification.id);
      },
    );
  }

  String _title() {
    switch (notification.type) {
      case NotificationType.friendInvite:
        return 'Friend request';
      case NotificationType.circleInvite:
        return 'Circle invitation';
      case NotificationType.resbiteInvite:
        return 'Resbite invitation';
    }
  }

  String _subtitle() {
    switch (notification.type) {
      case NotificationType.friendInvite:
        return 'Someone wants to add you as friend';
      case NotificationType.circleInvite:
        return 'You were invited to a circle';
      case NotificationType.resbiteInvite:
        return 'You were invited to join a resbite';
    }
  }

  Widget _icon(Color color) {
    switch (notification.type) {
      case NotificationType.friendInvite:
        return Icon(Icons.person_add, color: color);
      case NotificationType.circleInvite:
        return Icon(Icons.group_add, color: color);
      case NotificationType.resbiteInvite:
        return Icon(Icons.event, color: color);
    }
  }

  Widget _trailingButtons(WidgetRef ref, BuildContext context) {
    if (notification.status != NotificationStatus.pending) {
      return Text(notification.status.name);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Decline',
          onPressed: () async {
            await _handleDecline(ref);
          },
        ),
        IconButton(
          icon: const Icon(Icons.check),
          tooltip: 'Accept',
          onPressed: () async {
            await _handleAccept(ref, context);
          },
        ),
      ],
    );
  }

  Future<void> _handleAccept(WidgetRef ref, BuildContext context) async {
    final notificationService = ref.read(ns.notificationServiceProvider);
    try {
      switch (notification.type) {
        case NotificationType.friendInvite:
          final connectionId = notification.payload['connection_id'] as String?;
          if (connectionId != null) {
            await ref.read(fs.friendServiceProvider).acceptFriendRequest(connectionId);
          }
          break;
        case NotificationType.circleInvite:
          final invitationId = notification.payload['invitation_id'] as String?;
          if (invitationId != null) {
            await ref.read(inv.invitationServiceProvider).acceptInvitation(invitationId);
          }
          break;
        case NotificationType.resbiteInvite:
          final resbiteId = notification.payload['resbite_id'] as String?;
          final userId = ref.read(app.currentUserIdProvider);
          if (resbiteId != null && userId != null) {
            await ref.read(app.resbiteServiceProvider).joinResbite(resbiteId, userId);
          }
          break;
      }

      await notificationService.updateStatus(notification.id, NotificationStatus.accepted);
      ref.invalidate(app.notificationsProvider);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Accepted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _handleDecline(WidgetRef ref) async {
    final notificationService = ref.read(ns.notificationServiceProvider);
    try {
      switch (notification.type) {
        case NotificationType.friendInvite:
          final connectionId = notification.payload['connection_id'] as String?;
          if (connectionId != null) {
            await ref.read(fs.friendServiceProvider).declineFriendRequest(connectionId);
          }
          break;
        case NotificationType.circleInvite:
          final invitationId = notification.payload['invitation_id'] as String?;
          if (invitationId != null) {
            await ref.read(inv.invitationServiceProvider).declineInvitation(invitationId);
          }
          break;
        case NotificationType.resbiteInvite:
          final resbiteId = notification.payload['resbite_id'] as String?;
          final userId = ref.read(app.currentUserIdProvider);
          if (resbiteId != null && userId != null) {
            await ref.read(app.resbiteServiceProvider).declineResbiteInvite(resbiteId, userId);
          }
          break;
      }

      await notificationService.updateStatus(notification.id, NotificationStatus.declined);
      ref.invalidate(app.notificationsProvider);
    } catch (_) {}
  }
}
