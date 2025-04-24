import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resbite_app/components/ui/button.dart';
import 'package:resbite_app/components/ui/avatar.dart';
import 'package:resbite_app/services/contact_service.dart';
import 'package:resbite_app/services/providers.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';

/// Widget for displaying contacts in the Network tab
class ContactsDisplay extends ConsumerWidget {
  final bool showContactSyncUI;
  final Function() onSyncPressed;
  final List<Map<String, dynamic>> resbiteUsers;
  final List<Map<String, dynamic>> nonResbiteUsers;

  const ContactsDisplay({
    Key? key,
    this.showContactSyncUI = false,
    required this.onSyncPressed,
    this.resbiteUsers = const [],
    this.nonResbiteUsers = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (showContactSyncUI) {
      // Show UI to sync contacts when permission not granted
      return _buildContactSyncPrompt(context);
    } else {
      // Show contacts lists
      return _buildContactLists(context, ref);
    }
  }

  Widget _buildContactSyncPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Text(
            'Sync Your Contacts',
            style: TwTypography.heading5(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Find friends who are already using Resbite and invite others to join.',
              style: TwTypography.body(context),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ShadButton.primary(
            text: 'Sync Contacts',
            onPressed: onSyncPressed,
            icon: Icons.sync,
          ),
        ],
      ),
    );
  }

  Widget _buildContactLists(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Resbite users from contacts
        if (resbiteUsers.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text(
              'Contacts on Resbite',
              style: TwTypography.heading6(context),
            ),
          ),
          ...resbiteUsers.map((contact) => _buildContactItem(context, ref, contact, isResbiteUser: true)),
          const SizedBox(height: 24),
        ],
          
        // Non-Resbite users from contacts
        if (nonResbiteUsers.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text(
              'Invite Contacts to Resbite',
              style: TwTypography.heading6(context),
            ),
          ),
          ...nonResbiteUsers.map((contact) => _buildContactItem(context, ref, contact, isResbiteUser: false)),
        ],
      ],
    );
  }

  Widget _buildContactItem(BuildContext context, WidgetRef ref, Map<String, dynamic> contact, {required bool isResbiteUser}) {
    final displayName = contact['displayName'] ?? 'Unknown';
    final phoneNumbers = (contact['phoneNumbers'] as List<dynamic>?) ?? [];
    final emails = (contact['emails'] as List<dynamic>?) ?? [];
    final profileImageUrl = contact['profileImageUrl'];
    final initials = displayName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('');
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Show contact details if needed
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Profile picture
              ShadAvatar(
                size: AvatarSize.md,
                imageUrl: profileImageUrl,
                initials: initials,
                backgroundColor: TwColors.primary.withOpacity(0.2),
                textColor: TwColors.primary,
                statusColor: isResbiteUser ? TwColors.success : null,
              ),
              const SizedBox(width: 16),
              
              // Contact details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TwTypography.body(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (phoneNumbers.isNotEmpty || emails.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        phoneNumbers.isNotEmpty 
                          ? phoneNumbers.first.toString()
                          : emails.first.toString(),
                        style: TwTypography.bodySm(context).copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Actions based on whether they're a Resbite user
              if (isResbiteUser)
                ShadButton.primary(
                  text: 'Add Friend',
                  size: ButtonSize.sm,
                  onPressed: () {
                    // Add as friend
                    final resbiteUserId = contact['resbiteUserId'];
                    if (resbiteUserId != null) {
                      _addContactAsFriend(ref, resbiteUserId);
                    }
                  },
                )
              else
                ShadButton.secondary(
                  text: 'Invite',
                  size: ButtonSize.sm,
                  onPressed: () {
                    // Invite to Resbite
                    _inviteContactToApp(ref, context, contact);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _addContactAsFriend(WidgetRef ref, String userId) async {
    try {
      final friendService = ref.read(friendServiceProvider);
      final success = await friendService.addContactAsFriend(userId);
      
      if (success) {
        // Refresh the friends list
        await ref.refresh(directFriendsProvider).value;
      }
    } catch (e) {
      print('Error adding contact as friend: $e');
    }
  }

  void _inviteContactToApp(WidgetRef ref, BuildContext context, Map<String, dynamic> contact) async {
    try {
      final friendService = ref.read(friendServiceProvider);
      final success = await friendService.inviteContactToApp(contact);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation sent successfully'),
            backgroundColor: TwColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending invitation: ${e.toString()}'),
          backgroundColor: TwColors.error,
        ),
      );
    }
  }
}

/// Extension method to check contacts permission
extension ContactPermissionCheck on ContactService {
  /// Checks if contacts permission has been granted and is stored in preferences
  Future<bool> hasContactsPermissionStored() async {
    // First check if stored in preferences
    // Then check actual permission status
    return await hasContactsPermission();
  }
}
