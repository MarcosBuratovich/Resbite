import 'package:flutter/material.dart';
import 'package:resbite_app/components/ui.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';

/// Component that displays a contact item in the network tab
class ContactItem extends StatelessWidget {
  final dynamic contact;
  final bool isResbiteUser;
  final Function(String) addContactAsFriend;
  final Function(BuildContext, dynamic) inviteContactToApp;

  const ContactItem({
    super.key,
    required this.contact,
    required this.isResbiteUser,
    required this.addContactAsFriend,
    required this.inviteContactToApp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          if (isResbiteUser) {
            // If contact is a Resbite user, we can add them as friend
            addContactAsFriend(contact.resbiteUserId);
          } else {
            // If not a Resbite user, we can invite them to the app
            inviteContactToApp(context, contact);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Profile picture/avatar
              ShadAvatar(
                size: AvatarSize.md,
                imageUrl: isResbiteUser ? contact.profileImageUrl : null,
                initials: contact.displayName?.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('') ?? '',
                backgroundColor: isResbiteUser 
                  ? TwColors.primary.withAlpha((0.2 * 255).round()) 
                  : TwColors.slate200,
                textColor: isResbiteUser ? TwColors.primary : TwColors.slate700,
              ),
              const SizedBox(width: 16),
              
              // Contact information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.displayName ?? '',
                      style: TwTypography.body(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (contact.phoneNumbers.isNotEmpty)
                      Text(
                        contact.phoneNumbers.first,
                        style: TwTypography.bodySm(context).copyWith(
                          color: TwColors.slate600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              
              // Action button
              isResbiteUser
                ? ShadButton.primary(
                    text: 'Add',
                    onPressed: () => addContactAsFriend(contact.resbiteUserId),
                    size: ButtonSize.sm,
                    icon: Icons.person_add_alt,
                  )
                : ShadButton.secondary(
                    text: 'Invite',
                    onPressed: () => inviteContactToApp(context, contact),
                    size: ButtonSize.sm,
                    icon: Icons.share,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
