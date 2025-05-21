import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resbite_app/components/ui/button.dart';
import 'package:resbite_app/components/ui/avatar.dart';
import 'package:resbite_app/services/contact_service.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';

// Import the modular friend services
import 'package:resbite_app/ui/screens/friends/services/services.dart'
    as friend_services;

/// Widget for displaying contacts in the Network tab
class ContactsDisplay extends ConsumerWidget {
  final bool showContactSyncUI;
  final Function() onSyncPressed;
  final List<Map<String, dynamic>> resbiteUsers;
  final List<Map<String, dynamic>> nonResbiteUsers;

  const ContactsDisplay({
    super.key,
    this.showContactSyncUI = false,
    required this.onSyncPressed,
    this.resbiteUsers = const [],
    this.nonResbiteUsers = const [],
  });

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
    // Combine both contact lists
    final allContacts = [...resbiteUsers, ...nonResbiteUsers];

    // Sort alphabetically by display name for better user experience
    allContacts.sort(
      (a, b) => (a['displayName'] ?? '').toString().compareTo(
        (b['displayName'] ?? '').toString(),
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header for all contacts
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 4.0),
          child: Text('Your Contacts', style: TwTypography.heading6(context)),
        ),

        // Show all contacts in a single list
        ...allContacts.map((contact) {
          // Determine if contact is a Resbite user
          final isResbiteUser = resbiteUsers.any(
            (user) => user['id'] == contact['id'],
          );

          return _buildContactItem(
            context,
            ref,
            contact,
            isResbiteUser: isResbiteUser,
          );
        }),
      ],
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> contact, {
    required bool isResbiteUser,
  }) {
    final displayName = contact['displayName'] ?? 'Unknown';
    final phoneNumbers = (contact['phoneNumbers'] as List<dynamic>?) ?? [];
    final emails = (contact['emails'] as List<dynamic>?) ?? [];
    final profileImageUrl = contact['profileImageUrl'];
    final initials = displayName
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join('');

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Show contact details if needed
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Profile picture with status indicator
              Stack(
                children: [
                  ShadAvatar(
                    size: AvatarSize.md,
                    imageUrl: profileImageUrl,
                    initials: initials,
                    backgroundColor: TwColors.primary.withOpacity(0.2),
                    textColor: TwColors.primary,
                  ),
                  if (isResbiteUser)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: TwColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Contact details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            style: TwTypography.body(
                              context,
                            ).copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isResbiteUser)
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                              'Resbite User',
                              style: TwTypography.bodySm(context).copyWith(
                                color: TwColors.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (phoneNumbers.isNotEmpty || emails.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        phoneNumbers.isNotEmpty
                            ? phoneNumbers.first.toString()
                            : emails.first.toString(),
                        style: TwTypography.bodySm(context).copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Action button based on user type
              isResbiteUser
                  ? ShadButton.primary(
                    text: 'Add Friend',
                    size: ButtonSize.sm,
                    onPressed: () {
                      final resbiteUserId = contact['resbiteUserId'];
                      if (resbiteUserId != null) {
                        _addContactAsFriend(ref, context, resbiteUserId);
                      }
                    },
                  )
                  : ShadButton.secondary(
                    text: 'Invite',
                    size: ButtonSize.sm,
                    onPressed: () {
                      _inviteContactToApp(ref, context, contact);
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }

  void _addContactAsFriend(WidgetRef ref, BuildContext context, String userId) {
    // Use the modular friend service
    final friendService = ref.read(friend_services.friendServiceProvider);
    // Create a map with the correct format for addContactAsFriend
    final contactMap = {'userId': userId, 'isResbiteUser': true};

    // Execute the async operation without awaiting
    friendService
        .addContactAsFriend(contactMap)
        .then((_) {
          // Successfully completed - no need to refresh as it will update when user navigates
          print('Successfully added friend with ID: $userId');
          _showSnackBar(context, 'Friend added successfully', Colors.green);
        })
        .catchError((e) {
          print('Error adding contact as friend: $e');
          _showSnackBar(context, 'Failed to add friend', Colors.red);
        });
  }

  void _inviteContactToApp(
    WidgetRef ref,
    BuildContext context,
    Map<String, dynamic> contact,
  ) {
    // Use the modular friend service
    final friendService = ref.read(friend_services.friendServiceProvider);

    // Execute the async operation without awaiting
    friendService
        .inviteContactToApp(contact)
        .then((_) {
          // Display success message on completion (void doesn't return a value)
          _showSnackBar(
            context,
            'Invitation sent successfully',
            TwColors.success,
          );
        })
        .catchError((e) {
          // Display error message
          _showSnackBar(
            context,
            'Error sending invitation: ${e.toString()}',
            TwColors.error,
          );
        });
  }

  // Helper method to show a snackbar
  void _showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
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
