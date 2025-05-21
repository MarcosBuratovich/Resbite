import 'package:flutter/material.dart';
import 'package:resbite_app/components/ui/button.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';

/// Dialog to confirm removing a friend
class RemoveFriendDialog {
  /// Shows a dialog to confirm removing a friend
  static Future<void> show(BuildContext context, dynamic friend, Function(String) removeFriend) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remove Friend',
          style: TwTypography.heading6(context),
        ),
        content: Text(
          'Are you sure you want to remove ${friend.user.displayName ?? 'Friend'} from your friends? '
          'They will also be removed from any circle you\'ve created.',
          style: TwTypography.body(context),
        ),
        actions: [
          ShadButton.ghost(
            text: 'Cancel',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ShadButton.destructive(
            text: 'Remove',
            onPressed: () {
              Navigator.of(context).pop();
              removeFriend(friend.user.id);
            },
          ),
        ],
      ),
    );
  }
}
