import 'package:flutter/material.dart';
import 'package:resbite_app/components/ui.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';
import 'package:resbite_app/ui/shared/toast.dart';

/// Component that displays a friend item in the friends list
class FriendItem extends StatelessWidget {
  final dynamic friend;
  final Function(BuildContext, dynamic) showFriendDetailsDialog;
  final Function(BuildContext, dynamic) showInviteToResbiteDialog;

  const FriendItem({
    super.key, 
    required this.friend,
    required this.showFriendDetailsDialog,
    required this.showInviteToResbiteDialog,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          showFriendDetailsDialog(context, friend);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Profile picture
              ShadAvatar(
                size: AvatarSize.md,
                imageUrl: friend.user.profileImageUrl,
                initials: friend.user.displayName?.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('') ?? '',
                backgroundColor: TwColors.primary.withOpacity(0.2),
                textColor: TwColors.primary,
              ),
              const SizedBox(width: 16),
              
              // Friend details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          friend.user.displayName ?? 'Friend',
                          style: TwTypography.body(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (friend.user.email != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        friend.user.email!,
                        style: TwTypography.bodyXs(context).copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Message button
                  IconButton(
                    icon: const Icon(Icons.message_outlined),
                    color: Theme.of(context).colorScheme.primary,
                    tooltip: 'Message',
                    onPressed: () {
                      Toast.showInfo(
                        context, 
                        'Messaging will be available soon',
                      );
                    },
                  ),
                  
                  // Resbite invite button
                  IconButton(
                    icon: const Icon(Icons.calendar_today_outlined),
                    color: Theme.of(context).colorScheme.primary,
                    tooltip: 'Invite to Resbite',
                    onPressed: () {
                      showInviteToResbiteDialog(context, friend);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
