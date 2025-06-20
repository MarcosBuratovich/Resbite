import 'package:flutter/material.dart';
import 'package:resbite_app/components/ui.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';
import 'package:resbite_app/ui/shared/toast.dart';

/// Dialog for creating a new group
class CreateCircleDialog {
  /// Shows a dialog to create a new group
  static Future<void> show(
    BuildContext context,
    Function({required String name, required String description, required bool isPrivate}) createFriendCircle,
  ) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isPrivate = true;
    
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Create Group',
            style: TwTypography.heading6(context),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a group to organise your friends by interests, activities, or relationships.',
                style: TwTypography.bodySm(context),
              ),
              const SizedBox(height: 16),
              
              // Name field
              ShadInput.text(
                labelText: 'Group Name',
                hintText: 'E.g., Close Friends, Family, Sports Team',
                controller: nameController,
              ),
              const SizedBox(height: 16),
              
              // Description field
              ShadInput.text(
                labelText: 'Description (Optional)',
                hintText: 'What brings this group together?',
                controller: descriptionController,
              ),
              const SizedBox(height: 16),
              
              // Privacy toggle
              Row(
                children: [
                  Icon(
                    isPrivate ? Icons.lock_outline : Icons.lock_open_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Private Group',
                      style: TwTypography.body(context),
                    ),
                  ),
                  Switch(
                    value: isPrivate,
                    onChanged: (value) {
                      setState(() {
                        isPrivate = value;
                      });
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              
              // Privacy explanation
              Text(
                isPrivate
                    ? 'Only you can add members to this group.'
                    : 'Members can add their friends to this group.',
                style: TwTypography.bodyXs(context).copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
              text: 'Create Group',
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  Toast.showError(context, 'Please enter a group name');
                  return;
                }
                
                // Create circle
                createFriendCircle(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  isPrivate: isPrivate,
                );
                
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
