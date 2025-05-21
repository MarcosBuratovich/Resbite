import 'package:flutter/material.dart';
import 'package:resbite_app/components/ui.dart';
import 'package:resbite_app/models/friend.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';

/// Component that displays a network connection item in the network tab
class NetworkConnectionItem extends StatelessWidget {
  final NetworkConnection connection;
  final Function(String) addFriend;

  const NetworkConnectionItem({
    super.key,
    required this.connection,
    required this.addFriend,
  });

  @override
  Widget build(BuildContext context) {
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          // Show limited profile
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Profile picture
              ShadAvatar(
                size: AvatarSize.md,
                imageUrl: connection.user.profileImageUrl,
                initials: connection.user.displayName?.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('') ?? '',
                backgroundColor: TwColors.slate200,
                textColor: TwColors.slate700,
              ),
              const SizedBox(width: 16),
              
              // Connection details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      connection.user.displayName ?? 'User',
                      style: TwTypography.body(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Connection path
                    Row(
                      children: [
                        Text(
                          'via ${connection.mutualFriend.displayName ?? 'Friend'}',
                          style: TwTypography.bodyXs(context).copyWith(
                            color: TwColors.slate500,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        if (connection.mutualFriendsCount > 1) ...[
                          Text(
                            ' +${connection.mutualFriendsCount - 1} others',
                            style: TwTypography.bodyXs(context).copyWith(
                              color: TwColors.slate500,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Action button
              ShadButton.secondary(
                  text: 'Add Friend',
                  size: ButtonSize.sm,
                  icon: Icons.person_add,
                  onPressed: () {
                    final userId = connection.user.id;
                    addFriend(userId);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
