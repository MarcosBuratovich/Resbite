import 'package:flutter/material.dart';
import 'package:resbite_app/components/ui.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';
import 'package:resbite_app/ui/shared/toast.dart';

/// Dialog displaying a friend's details and actions for interacting with a friend
class FriendDetailsDialog {
  /// Shows a dialog with friend details and available actions
  static Future<void> show(
    BuildContext context,
    dynamic friend, {
    required Function(DateTime) formatDate,
    required Function(BuildContext, dynamic) showInviteToResbiteDialog,
    required Function(BuildContext, dynamic) showRemoveFriendConfirmation,
  }) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            contentPadding: const EdgeInsets.all(16),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile picture
                ShadAvatar(
                  size: AvatarSize.xl,
                  imageUrl: friend.user.profileImageUrl,
                  initials:
                      friend.user.displayName
                          ?.split(' ')
                          .map((e) => e.isNotEmpty ? e[0] : '')
                          .join('') ??
                      '',
                  backgroundColor: TwColors.primary.withOpacity(0.2),
                  textColor: TwColors.primary,
                  hasBorder: true,
                  borderColor: TwColors.primary,
                ),
                const SizedBox(height: 16),

                // Name
                Text(
                  friend.user.displayName ?? 'Friend',
                  style: TwTypography.heading5(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Friend since
                Text(
                  'Friend since ${formatDate(friend.connectedAt)}',
                  style: TwTypography.bodySm(context).copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),

                // Contact details
                if (friend.user.email != null) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.email, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        friend.user.email!,
                        style: TwTypography.body(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Action buttons for large screens
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ShadButton.ghost(
                      text: 'Message',
                      icon: Icons.message,
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Messaging functionality
                        Toast.showInfo(
                          context,
                          'Messaging will be available soon',
                        );
                      },
                    ),
                    ShadButton.primary(
                      text: 'Invite to Resbite',
                      icon: Icons.calendar_today,
                      onPressed: () {
                        Navigator.of(context).pop();
                        showInviteToResbiteDialog(context, friend);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Friend circles
                if (friend.groupIds.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Shared Friend Circles',
                    style: TwTypography.heading6(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children:
                        friend.groupIds
                            .map<Widget>(
                              (circleId) => ShadBadge.secondary(
                                text:
                                    'Close Friends', // Would fetch actual circle name
                                size: BadgeSize.md,
                                icon: Icons.group,
                              ),
                            )
                            .toList(),
                  ),
                ],
              ],
            ),
            actions: [
              ShadButton.destructive(
                text: 'Remove Friend',
                onPressed: () {
                  Navigator.of(context).pop();
                  showRemoveFriendConfirmation(context, friend);
                },
              ),
              ShadButton.ghost(
                text: 'Close',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
    );
  }
}
