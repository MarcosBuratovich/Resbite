import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/providers.dart' hide resbiteServiceProvider;
import 'services/services.dart';

class ManageParticipantsScreen extends ConsumerWidget {
  final String resbiteId;
  const ManageParticipantsScreen({super.key, required this.resbiteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync = ref.watch(resbiteParticipantsProvider(resbiteId));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Participants')),
      body: participantsAsync.when(
        data: (participants) {
          if (participants.isEmpty) {
            return const Center(child: Text('No participants yet.'));
          }
          return ListView.builder(
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant = participants[index];
              final canRemove =
                  currentUser != null && participant.id != currentUser.id;
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      participant.profileImageUrl != null
                          ? NetworkImage(participant.profileImageUrl!)
                          : null,
                  child:
                      participant.profileImageUrl == null
                          ? Text(
                            participant.displayName
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                '',
                          )
                          : null,
                ),
                title: Text(participant.displayName ?? participant.email),
                subtitle: Text(participant.email),
                trailing:
                    canRemove
                        ? IconButton(
                          icon: Icon(
                            Icons.remove_circle,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () {
                            showDialog<bool>(
                              context: context,
                              builder:
                                  (_) => AlertDialog(
                                    title: Text('Remove Participant'),
                                    content: Text(
                                      'Remove ${participant.displayName ?? participant.email}?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(
                                              context,
                                            ).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed:
                                            () =>
                                                Navigator.of(context).pop(true),
                                        child: const Text('Remove'),
                                      ),
                                    ],
                                  ),
                            ).then((confirmed) async {
                              if (confirmed == true) {
                                final service = ref.read(
                                  resbiteServiceProvider,
                                );
                                final removed = await service.leaveResbite(
                                  resbiteId,
                                  participant.id,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        removed
                                            ? 'Removed ${participant.displayName ?? participant.email}'
                                            : 'Failed to remove participant',
                                      ),
                                      backgroundColor:
                                          removed
                                              ? Theme.of(
                                                context,
                                              ).colorScheme.errorContainer
                                              : Theme.of(
                                                context,
                                              ).colorScheme.error,
                                    ),
                                  );
                                }
                                if (removed) {
                                  ref.refresh(
                                    resbiteParticipantsProvider(resbiteId),
                                  );
                                }
                              }
                            });
                          },
                        )
                        : null,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
