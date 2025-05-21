import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/resbite.dart';
import '../../../../models/resbite_filter.dart';
import '../../../../services/providers.dart';

/// Context-aware action button adapting to user and resbite state.
class ResbiteActionButton extends ConsumerWidget {
  final Resbite resbite;

  const ResbiteActionButton({required this.resbite, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isPast = resbite.startDate.isBefore(DateTime.now());
    final isOwner = user != null && resbite.ownerId == user.id;
    final isParticipant = user != null && resbite.participants.any((p) => p.id == user.id);
    final isFull = resbite.attendanceLimit != null && resbite.attendanceLimit! > 0 && resbite.currentAttendance >= resbite.attendanceLimit!;

    if (isPast) return CompletedButton();
    if (isOwner) return ManageButton(resbiteId: resbite.id);
    if (isParticipant) return LeaveButton(resbiteId: resbite.id, userId: user.id);
    if (isFull) return FullButton();
    return JoinButton(resbiteId: resbite.id, user: user);
  }
}

class CompletedButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: null,
      icon: const Icon(Icons.check_circle),
      label: const Text('Completed'),
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        disabledBackgroundColor:
            Theme.of(context).colorScheme.surfaceContainerHighest,
        disabledForegroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

class ManageButton extends StatelessWidget {
  final String resbiteId;

  const ManageButton({required this.resbiteId, super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {
        Navigator.of(
          context,
        ).pushNamed('/resbites/manage', arguments: {'id': resbiteId});
      },
      icon: const Icon(Icons.edit, size: 18),
      label: const Text('Manage'),
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

class LeaveButton extends ConsumerWidget {
  final String resbiteId;
  final String userId;

  const LeaveButton({required this.resbiteId, required this.userId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () async {
        final resbiteService = ref.read(resbiteServiceProvider);
        try {
          await resbiteService.leaveResbite(resbiteId, userId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully left resbite')),
          );
          final _ = ref.refresh(resbitesProvider(ResbiteFilter(upcoming: true, userId: userId)));
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error leaving resbite: $e')),
            );
          }
        }
      },
      icon: const Icon(Icons.exit_to_app, size: 18),
      label: const Text('Leave'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.error,
        side: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

class FullButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: null,
      icon: const Icon(Icons.block, size: 18),
      label: const Text('Full'),
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.1),
        foregroundColor: Theme.of(context).colorScheme.error,
        disabledBackgroundColor: Theme.of(
          context,
        ).colorScheme.error.withOpacity(0.1),
        disabledForegroundColor: Theme.of(context).colorScheme.error,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

class JoinButton extends ConsumerWidget {
  final String resbiteId;
  final dynamic user;

  const JoinButton({required this.resbiteId, required this.user, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.icon(
      onPressed: () async {
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to join.')),
          );
          return;
        }
        final resbiteService = ref.read(resbiteServiceProvider);
        try {
          await resbiteService.joinResbite(resbiteId, user.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully joined resbite')),
          );
          final _ = ref.refresh(resbitesProvider(ResbiteFilter(upcoming: true, userId: user.id)));
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error joining resbite: $e')),
            );
          }
        }
      },
      icon: const Icon(Icons.person_add, size: 18),
      label: const Text('Join'),
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        foregroundColor: Theme.of(context).colorScheme.onTertiary,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
