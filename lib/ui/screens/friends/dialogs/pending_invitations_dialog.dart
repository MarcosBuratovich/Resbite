import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resbite_app/components/ui.dart';
import 'package:resbite_app/models/invitation.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';
import 'package:resbite_app/ui/screens/friends/services/services.dart' as friends_services;

/// Dialog to display and manage pending circle invitations
class PendingInvitationsDialog {
  /// Shows a dialog with the user's pending circle invitations
  static Future<void> show(
    BuildContext context, 
    WidgetRef ref,
    {
      required Function(String) acceptInvitation,
      required Function(String) declineInvitation,
    }
  ) async {
    return showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<Invitation>>(
        future: ref.read(friends_services.invitationServiceProvider).getPendingInvitations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (snapshot.hasError) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Could not load invitations.'),
              actions: [
                ShadButton.ghost(
                  text: 'Close',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
          
          final invitations = snapshot.data ?? [];
          
          if (invitations.isEmpty) {
            return AlertDialog(
              title: Text(
                'Pending Invitations',
                style: TwTypography.heading6(context),
              ),
              content: const Text('You have no pending invitations.'),
              actions: [
                ShadButton.ghost(
                  text: 'Close',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
          
          return AlertDialog(
            title: Text(
              'Pending Invitations',
              style: TwTypography.heading6(context),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: invitations.length,
                itemBuilder: (context, index) {
                  final invitation = invitations[index];
                  return ListTile(
                    title: Text(invitation.circleName),
                    subtitle: Text(
                      'Invited by ${invitation.inviterName}',
                      style: TwTypography.bodyXs(context),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShadButton.ghost(
                          text: 'Decline',
                          size: ButtonSize.sm,
                          onPressed: () {
                            Navigator.of(context).pop();
                            declineInvitation(invitation.id);
                          },
                        ),
                        const SizedBox(width: 8),
                        ShadButton.primary(
                          text: 'Accept',
                          size: ButtonSize.sm,
                          onPressed: () {
                            Navigator.of(context).pop();
                            acceptInvitation(invitation.id);
                          },
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  );
                },
              ),
            ),
            actions: [
              ShadButton.ghost(
                text: 'Close',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
