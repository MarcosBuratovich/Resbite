import 'package:flutter/material.dart';
import 'package:resbite_app/components/ui/button.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';

/// Dialog to confirm leaving a friend group
class LeaveCircleDialog {
  /// Shows a dialog to confirm leaving a friend group
  static Future<void> show(BuildContext context, dynamic circle, Function(String) leaveCircle) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Leave Group',
          style: TwTypography.heading6(context),
        ),
        content: Text(
          'Are you sure you want to leave the ${circle.name} group?\nYou\'ll need an invitation to rejoin.',
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
            text: 'Leave Group',
            onPressed: () {
              Navigator.of(context).pop();
              leaveCircle(circle.id);
            },
          ),
        ],
      ),
    );
  }
}
