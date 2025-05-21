import 'package:flutter/material.dart';
import 'package:resbite_app/components/ui/button.dart';
import 'package:resbite_app/components/ui/card.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';

/// Dialog to invite a friend to a resbite event
class InviteToResbiteDialog {
  /// Shows a dialog to invite a friend to a resbite event
  static Future<void> show(BuildContext context, dynamic friend) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Invite to Resbite',
          style: TwTypography.heading6(context),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a resbite to invite ${friend.user.displayName ?? 'Friend'} to:',
              style: TwTypography.body(context),
            ),
            const SizedBox(height: 16),
            
            // List of upcoming resbites (mock data)
            ShadCard.default_(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Beach Day'),
                    subtitle: const Text('Saturday, Apr. 13 • 2:00 PM'),
                    trailing: ShadButton.primary(
                      text: 'Invite',
                      size: ButtonSize.sm,
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Invitation sent to ${friend.user.displayName ?? 'Friend'}!'),
                            backgroundColor: TwColors.success,
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Board Game Night'),
                    subtitle: const Text('Friday, Apr. 19 • 7:00 PM'),
                    trailing: ShadButton.primary(
                      text: 'Invite',
                      size: ButtonSize.sm,
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Invitation sent to ${friend.user.displayName ?? 'Friend'}!'),
                            backgroundColor: TwColors.success,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ShadButton.ghost(
            text: 'Cancel',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ShadButton.secondary(
            text: 'Create New Resbite',
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/start-resbite');
            },
          ),
        ],
      ),
    );
  }
}
