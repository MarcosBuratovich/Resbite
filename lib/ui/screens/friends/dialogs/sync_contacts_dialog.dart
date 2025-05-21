import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resbite_app/components/ui/button.dart';
import 'package:resbite_app/services/providers.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';
import 'package:resbite_app/ui/screens/friends/services/services.dart' as friends_services;

/// Shows a dialog to sync contacts with the app
class SyncContactsDialog {
  /// Shows the dialog to sync contacts
  static Future<void> show(BuildContext context, WidgetRef ref, Function(BuildContext, List<dynamic>) showResultsDialog) async {
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Sync Contacts',
          style: TwTypography.heading6(dialogContext),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Syncing your contacts helps you find friends who are already using Resbite and invite others to join.',
              style: TwTypography.body(dialogContext),
            ),
            const SizedBox(height: 12),
            Text(
              'This requires permission to access your contacts. Your contacts won\'t be stored on our servers without your permission.',
              style: TwTypography.bodySm(dialogContext).copyWith(
                color: Theme.of(dialogContext).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          ShadButton.ghost(
            text: 'Cancel',
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          ShadButton.primary(
            text: 'Sync Contacts',
            onPressed: () => _syncContacts(dialogContext, context, ref, showResultsDialog),
          ),
        ],
      ),
    );
  }

  /// Handles the contact sync process
  static Future<void> _syncContacts(
    BuildContext dialogContext, 
    BuildContext parentContext, 
    WidgetRef ref,
    Function(BuildContext, List<dynamic>) showResultsDialog
  ) async {
    // Store the BuildContext in a local variable
    Navigator.of(dialogContext).pop();
    
    // Store the build context before async operations
    final scaffoldContext = parentContext;
    
    // Show loading indicator
    showDialog(
      context: scaffoldContext,
      barrierDismissible: false,
      builder: (loadingContext) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      final friendService = ref.read(friends_services.friendServiceProvider);
      final contacts = await friendService.syncContacts();
      
      // Close loading dialog
      Navigator.of(scaffoldContext).pop();
      
      // Show results dialog
      showResultsDialog(scaffoldContext, contacts);
      
      // Refresh the data - we're intentionally not using the return values
      // as we just want to trigger a refresh and then wait for completion
      // ignore: unused_result
      ref.refresh(friends_services.directFriendsProvider);
      // ignore: unused_result
      ref.refresh(friends_services.extendedNetworkProvider);
      // ignore: unused_result
      ref.refresh(resbiteContactsProvider);
      
      // Wait for the providers to complete refreshing
      await ref.read(friends_services.directFriendsProvider.future);
      await ref.read(friends_services.extendedNetworkProvider.future);
      await ref.read(resbiteContactsProvider.future);
    } catch (e) {
      // Close loading dialog
      Navigator.of(scaffoldContext).pop();
      
      // Show error
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Error syncing contacts: ${e.toString()}'),
          backgroundColor: TwColors.error,
        ),
      );
    }
  }
}
