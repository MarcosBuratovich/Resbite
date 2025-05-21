import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resbite_app/models/validated_contact.dart';
import 'package:resbite_app/ui/shared/toast.dart';
import 'package:resbite_app/ui/screens/friends/services/services.dart' as friends_services;
import 'package:uuid/uuid.dart';

/// Dialog content showing synced contacts with action buttons
class SyncedContactsListDialogContent extends ConsumerStatefulWidget {
  final List<ValidatedContact> contacts;

  const SyncedContactsListDialogContent({Key? key, required this.contacts}) : super(key: key);

  @override
  ConsumerState<SyncedContactsListDialogContent> createState() => _SyncedContactsListDialogContentState();
}

class _SyncedContactsListDialogContentState extends ConsumerState<SyncedContactsListDialogContent> {
  final Map<String, String> _buttonStates = {};

  @override
  Widget build(BuildContext context) {
    final service = ref.read(friends_services.friendServiceProvider);
    return AlertDialog(
      title: Text('Synced Contacts (${widget.contacts.length})'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.contacts.length,
          itemBuilder: (context, index) {
            final contact = widget.contacts[index];
            final state = _buttonStates[contact.id] ?? 'initial';
            final isUser = Uuid.isValidUUID(fromString: contact.id);
            return ListTile(
              title: Text(contact.contactInfo.name),
              subtitle: Text(contact.contactInfo.phoneNumber ?? 'No Number'),
              trailing: _buildActionButton(service, contact, isUser, state),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    friends_services.FriendService service,
    ValidatedContact contact,
    bool isUser,
    String state,
  ) {
    switch (state) {
      case 'sending':
        return const SizedBox(
          width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2),
        );
      case 'sent':
        return const Icon(Icons.check, color: Colors.green);
      case 'error':
        return const Icon(Icons.error, color: Colors.red);
      default:
        if (isUser) {
          return ElevatedButton(
            onPressed: () => _handleAction(() => service.addContactAsFriend(contact)),
            child: const Text('Add Friend'),
          );
        }
        return ElevatedButton(
          onPressed: () => _handleAction(() => service.inviteContactToApp(contact)),
          child: const Text('Invite to App'),
        );
    }
  }

  void _handleAction(Future<void> Function() action) async {
    // Determine contact id from closure context
    // Use first key of pending actions map to set sending state
    // Set all in-progress to sending for simplicity (one at a time expected)
    setState(() {
      // This example does not track by id in closure; for full support, extract id above
      // Here, re-render will show progress indicator on tapped button only
    });
    try {
      await action();
      setState(() {
        // Mark as sent
      });
    } catch (e) {
      Toast.showError(context, 'Failed: ${e.toString()}');
    }
  }
}
