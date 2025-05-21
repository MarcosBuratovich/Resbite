import 'package:flutter/material.dart';
import 'package:resbite_app/components/ui.dart';
import 'package:resbite_app/models/circle.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';
import 'package:resbite_app/ui/screens/friends/components/badge_icon.dart';

/// Component that displays a friend circle item
class CircleItem extends StatelessWidget {
  final Circle circle;
  final Function(BuildContext, Circle) showCircleDetailsDialog;
  final Function(BuildContext, Circle) showCircleMembersDialog;
  final Function(BuildContext, Circle) showInviteToCircleDialog;
  final String currentUserId;

  const CircleItem({
    super.key,
    required this.circle,
    required this.showCircleDetailsDialog,
    required this.showCircleMembersDialog,
    required this.showInviteToCircleDialog,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = circle.isAdmin(currentUserId);

    return ShadCard.default_(
      onTap: () {
        showCircleDetailsDialog(context, circle);
      },
      title: circle.name,
      subtitle: circle.description.isNotEmpty ? circle.description : null,
      leading: CircleAvatar(
        backgroundColor: isAdmin ? TwColors.primary : TwColors.slate300,
        foregroundColor: isAdmin ? TwColors.textLight : TwColors.textDark,
        child: Icon(
          isAdmin ? Icons.edit : Icons.group,
        ),
      ),
      trailing: BadgeIcon(
        memberCount: circle.memberCount,
        isPrivate: circle.isPrivate,
      ),
      footer: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // View members button
            ShadButton.ghost(
              text: 'Members',
              size: ButtonSize.sm,
              icon: Icons.people,
              onPressed: () {
                showCircleMembersDialog(context, circle);
              },
            ),
            
            // Add member button (if admin or circle is not private)
            if (isAdmin || !circle.isPrivate)
              ShadButton.primary(
                text: 'Invite',
                size: ButtonSize.sm,
                icon: Icons.person_add,
                onPressed: () {
                  showInviteToCircleDialog(context, circle);
                },
              ),
          ],
        ),
      ),
    );
  }
}
