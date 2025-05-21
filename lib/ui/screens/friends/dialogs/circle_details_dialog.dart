import 'package:flutter/material.dart';
import 'package:resbite_app/components/ui/button.dart';
import 'package:resbite_app/models/circle.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';

/// Dialog to display details of a friend circle
class CircleDetailsDialog {
  /// Shows a dialog with details about a friend circle
  static Future<void> show(
    BuildContext context, 
    Circle circle, 
    {
      required String currentUserId,
      required Function(DateTime) formatDate,
      required Function(BuildContext, Circle) showLeaveCircleConfirmation,
      required Function(BuildContext, Circle) showCircleMembersDialog,
    }
  ) async {
    final bool isAdmin = circle.isAdmin(currentUserId);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Text(
                circle.name,
                style: TwTypography.heading6(context),
              ),
            ),
            if (circle.isPrivate)
              Icon(
                Icons.lock_outline,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            if (circle.description.isNotEmpty) ...[
              Text(
                circle.description,
                style: TwTypography.body(context),
              ),
              const SizedBox(height: 16),
            ],
            
            // Circle stats
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${circle.memberCount} members',
                  style: TwTypography.bodySm(context),
                ),
                const Spacer(),
                Text(
                  'Created ${formatDate(circle.createdAt)}',
                  style: TwTypography.bodyXs(context).copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Admin section
            if (isAdmin) ...[
              Text(
                'Admin Tools',
                style: TwTypography.heading6(context),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ShadButton.secondary(
                      text: 'Edit Circle',
                      icon: Icons.edit,
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Show edit dialog
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ShadButton.destructive(
                      text: 'Delete',
                      icon: Icons.delete,
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Show delete confirmation
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Member section
              ShadButton.destructive(
                text: 'Leave Circle',
                isFullWidth: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  showLeaveCircleConfirmation(context, circle);
                },
              ),
            ],
          ],
        ),
        actions: [
          ShadButton.ghost(
            text: 'Close',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ShadButton.primary(
            text: 'View Members',
            onPressed: () {
              Navigator.of(context).pop();
              showCircleMembersDialog(context, circle);
            },
          ),
        ],
      ),
    );
  }
}
