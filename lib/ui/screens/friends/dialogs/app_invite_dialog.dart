import 'package:flutter/material.dart';
import 'package:resbite_app/components/ui/button.dart';
import 'package:resbite_app/components/ui/input.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';

/// Dialog to invite a contact to the Resbite app
class AppInviteDialog {
  /// Shows a dialog to invite a contact to the Resbite app
  static Future<void> show(BuildContext context, String contactName, String contactPhone) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Invite to Resbite App',
          style: TwTypography.heading6(context),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send $contactName an invitation to join Resbite:',
              style: TwTypography.body(context),
            ),
            const SizedBox(height: 16),
            
            ShadInput.multiline(
              maxLines: 5,
              minLines: 3,
              controller: TextEditingController(
                text: 'Hey ${contactName.split(' ').first}! I\'m using this great app called Resbite for organizing activities with friends. You should check it out: https://resbite.app/download',
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
          ShadButton.primary(
            text: 'Send Invitation',
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('App invitation sent to $contactName!'),
                  backgroundColor: TwColors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
