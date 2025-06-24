import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resbite_app/models/circle.dart';
import 'package:resbite_app/models/validated_contact.dart';
import 'package:resbite_app/services/providers.dart';
import 'package:resbite_app/ui/screens/friends/services/services.dart'
    as friends_services;
import 'package:uuid/uuid.dart';
import 'package:resbite_app/ui/screens/friends/components/synced_contacts_list_dialog_content.dart';
import 'package:resbite_app/config/routes.dart';
import 'package:resbite_app/ui/screens/friends/dialogs/dialogs.dart';
import 'package:resbite_app/ui/shared/toast.dart';

/// Mixin that bundles all dialog–related helpers previously living inside
/// `friends_screen.dart`. This keeps the main screen lean and focused on
/// layout / state while delegating dialog orchestration here.
///
/// To use:
/// ```dart
/// class _FriendsScreenState extends ConsumerState<FriendsScreen>
///     with SingleTickerProviderStateMixin, FriendsDialogMixin {
///   // ...
/// }
/// ```
/// The mixin expects the host `State` to be a `ConsumerState` so that it has
/// access to `ref`. It also relies on `mounted`, `context`, and `setState` that
/// are available on any `State` subclass.
mixin FriendsDialogMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  // ---------- Convenience ----------
  String? get _currentUserId =>
      ref.read(supabaseClientProvider).auth.currentUser?.id;

  // ---------- Public helpers ----------
  void showSyncContactsDialog(BuildContext context) {
    SyncContactsDialog.show(
      context,
      ref,
      (ctx, contacts) =>
          _showContactSyncResultsDialog(ctx, contacts.cast<ValidatedContact>()),
    );
  }

  void showPendingInvitationsDialog(BuildContext context) {
    PendingInvitationsDialog.show(
      context,
      ref,
      acceptInvitation: _acceptInvitation,
      declineInvitation: _declineInvitation,
    );
  }

  void showFriendDetailsDialog(BuildContext context, dynamic friend) {
    FriendDetailsDialog.show(
      context,
      friend,
      formatDate: _formatDate,
      showInviteToResbiteDialog: showInviteToResbiteDialog,
      showRemoveFriendConfirmation: _showRemoveFriendConfirmation,
    );
  }

  void showInviteToResbiteDialog(BuildContext context, dynamic friend) {
    InviteToResbiteDialog.show(context, friend);
  }

  void showCreateGroupDialog(BuildContext context) {
    CreateCircleDialog.show(
      context,
      ({
        required String name,
        required String description,
        required bool isPrivate,
      }) => _createFriendCircle(
        name: name,
        description: description,
        isPrivate: isPrivate,
      ),
    );
  }

  void showCircleDetailsDialog(BuildContext context, Circle circle) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.groupDetails, arguments: {'id': circle.id});
  }

  void showCircleMembersDialog(BuildContext context, Circle circle) {
    CircleMembersDialog.show(
      context,
      ref,
      circle,
      currentUserId: _currentUserId ?? '',
      showInviteToCircleDialog: showInviteToCircleDialog,
    );
  }

  void showInviteToCircleDialog(BuildContext context, Circle circle) {
    InviteToCircleDialog.show(
      context,
      ref,
      circle,
      showSyncContactsDialog: showSyncContactsDialog,
      inviteToCircle: _inviteToCircle,
    );
  }

  // ---------- Internal (private) helpers ----------
  void _showContactSyncResultsDialog(
    BuildContext ctx,
    List<ValidatedContact> contacts,
  ) {
    if (contacts.isEmpty) {
      Toast.showInfo(ctx, 'No new contacts found to sync.');
      return;
    }

    final resbiteUserCount =
        contacts.where((c) => Uuid.isValidUUID(fromString: c.id)).length;

    if (resbiteUserCount > 0) {
      Toast.showSuccess(
        ctx,
        'Found $resbiteUserCount contact(s) already using Resbite!',
      );
    } else {
      Toast.showInfo(
        ctx,
        'Found ${contacts.length} contact(s). Invite them to Resbite!',
      );
    }

    showDialog(
      context: ctx,
      builder: (_) => SyncedContactsListDialogContent(contacts: contacts),
    );
  }

  void _showRemoveFriendConfirmation(BuildContext ctx, dynamic friend) {
    RemoveFriendDialog.show(ctx, friend, (userId) => _removeFriend(userId));
  }

  // ---------- Service wrappers ----------
  Future<void> addFriend(String userId) async {
    if (_currentUserId == null) {
      Toast.showError(context, 'Error: User not authenticated.');
      return;
    }
    try {
      await ref.read(friends_services.friendServiceProvider).addFriend(userId);
      unawaited(ref.refresh(friends_services.directFriendsProvider.future));
      Toast.showSuccess(context, 'Friend added successfully');
    } catch (e) {
      Toast.showError(context, 'Failed to add friend: ${e.toString()}');
    }
  }

  Future<void> addContactAsFriend(String resbiteUserId) async {
    if (_currentUserId == null) {
      Toast.showError(context, 'Error: User not authenticated.');
      return;
    }
    try {
      await ref
          .read(friends_services.friendServiceProvider)
          .addFriend(resbiteUserId);
      unawaited(ref.refresh(friends_services.directFriendsProvider.future));
      Toast.showSuccess(context, 'Friend added successfully');
    } catch (e) {
      Toast.showError(context, 'Failed to add friend: ${e.toString()}');
    }
  }

  Future<void> _removeFriend(String userId) async {
    try {
      await ref
          .read(friends_services.friendServiceProvider)
          .removeFriend(userId);
      unawaited(ref.refresh(friends_services.directFriendsProvider.future));
      Toast.showSuccess(context, 'Friend removed');
    } catch (e) {
      Toast.showError(context, 'Failed: ${e.toString()}');
    }
  }

  Future<void> _createFriendCircle({
    required String name,
    required String description,
    required bool isPrivate,
  }) async {
    try {
      await ref
          .read(friends_services.groupServiceProvider)
          .createCircle(
            name: name,
            description: description,
            isPrivate: isPrivate,
          );
      unawaited(ref.refresh(friends_services.userGroupsProvider.future));
      Toast.showSuccess(context, 'Group created successfully');
    } catch (e) {
      Toast.showError(context, 'Failed: ${e.toString()}');
    }
  }

  Future<void> _inviteToCircle(String circleId, dynamic contact) async {
    try {
      await ref
          .read(friends_services.groupServiceProvider)
          .inviteToCircle(circleId, contact);
      Toast.showSuccess(context, 'Invite sent');
    } catch (e) {
      Toast.showError(context, 'Failed: ${e.toString()}');
    }
  }

  Future<void> _acceptInvitation(String invitationId) async {
    try {
      await ref
          .read(friends_services.invitationServiceProvider)
          .acceptInvitation(invitationId);
      unawaited(
        ref.refresh(friends_services.pendingInvitationsProvider.future),
      );
      Toast.showSuccess(context, 'Invitation accepted');
    } catch (e) {
      Toast.showError(context, 'Failed: ${e.toString()}');
    }
  }

  Future<void> _declineInvitation(String invitationId) async {
    try {
      await ref
          .read(friends_services.invitationServiceProvider)
          .declineInvitation(invitationId);
      unawaited(
        ref.refresh(friends_services.pendingInvitationsProvider.future),
      );
      Toast.showSuccess(context, 'Invitation declined');
    } catch (e) {
      Toast.showError(context, 'Failed: ${e.toString()}');
    }
  }

  /// Invite non-Resbite contact to the app
  Future<void> inviteContactToApp(BuildContext ctx, dynamic contact) async {
    try {
      await ref
          .read(friends_services.friendServiceProvider)
          .inviteContactToApp(contact);
      Toast.showSuccess(ctx, 'Invitation sent');
    } catch (e) {
      Toast.showError(ctx, 'Failed to send invite: ${e.toString()}');
    }
  }

  // ---------- Utility ----------
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) return 'Today';
    if (difference.inDays < 2) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30)
      return '${(difference.inDays / 7).floor()} weeks ago';
    if (difference.inDays < 365)
      return '${(difference.inDays / 30).floor()} months ago';
    return '${(difference.inDays / 365).floor()} years ago';
  }
}
