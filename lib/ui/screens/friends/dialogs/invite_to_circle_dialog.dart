import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resbite_app/components/ui.dart';
import 'package:resbite_app/models/friend.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';
import 'package:resbite_app/ui/screens/friends/services/services.dart' as friends_services;

/// Dialog to invite friends to a circle
class InviteToCircleDialog {
  /// Shows a dialog to invite friends to a circle
  static Future<void> show(
    BuildContext context, 
    WidgetRef ref,
    dynamic circle,
    {
      required Function(BuildContext) showSyncContactsDialog,
      required Function(String, String) inviteToCircle,
    }
  ) async {
    // In a real app, you would fetch the user's friends who aren't already in the circle
    
    return showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<FriendConnection>>(
        future: ref.read(friends_services.friendServiceProvider).getDirectFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (snapshot.hasError || !snapshot.hasData) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Could not load friends.'),
              actions: [
                ShadButton.ghost(
                  text: 'Close',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
          
          final friends = snapshot.data!;
          
          // Filter out friends already in the circle
          final eligibleFriends = friends.where((friend) => 
            !circle.memberIds.contains(friend.user.id) &&
            !circle.adminIds.contains(friend.user.id) &&
            circle.createdBy != friend.user.id &&
            !circle.pendingInviteIds.contains(friend.user.id)
          ).toList();
          
          if (eligibleFriends.isEmpty) {
            return AlertDialog(
              title: Text(
                'Invite to ${circle.name}',
                style: TwTypography.heading6(context),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('All your friends are already in this circle.'),
                  const SizedBox(height: 16),
                  ShadButton.secondary(
                    text: 'Add New Friends',
                    isFullWidth: true,
                    onPressed: () {
                      Navigator.of(context).pop();
                      showSyncContactsDialog(context);
                    },
                  ),
                ],
              ),
              actions: [
                ShadButton.ghost(
                  text: 'Close',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
          
          return AlertDialog(
            title: Text(
              'Invite to ${circle.name}',
              style: TwTypography.heading6(context),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select friends to invite:',
                    style: TwTypography.body(context),
                  ),
                  const SizedBox(height: 16),
                  
                  // Friend list
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: eligibleFriends.length,
                      itemBuilder: (context, index) {
                        final friend = eligibleFriends[index];
                        return ListTile(
                          leading: ShadAvatar(
                            size: AvatarSize.sm,
                            imageUrl: friend.user.profileImageUrl,
                            initials: friend.user.displayName?.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('') ?? '',
                          ),
                          title: Text(friend.user.displayName ?? 'Friend'),
                          trailing: ShadButton.primary(
                            text: 'Invite',
                            size: ButtonSize.sm,
                            onPressed: () {
                              Navigator.of(context).pop();
                              inviteToCircle(circle.id, friend.user.id);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ShadButton.ghost(
                text: 'Cancel',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
