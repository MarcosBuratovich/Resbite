import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resbite_app/models/circle.dart';
import 'package:resbite_app/ui/screens/friends/services/group_service_impl.dart';
import 'package:resbite_app/ui/shared/loading_state.dart';
import 'package:resbite_app/models/user.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';
import 'package:resbite_app/components/ui.dart';
import 'package:resbite_app/ui/shared/empty_state.dart';

/// Dialog to view and manage members of a friend circle
class CircleMembersDialog extends ConsumerWidget {
  final Circle circle;
  final String currentUserId;
  final Function(BuildContext, Circle) showInviteToCircleDialog;

  const CircleMembersDialog({
    super.key,
    required this.circle,
    required this.currentUserId,
    required this.showInviteToCircleDialog,
  });

  /// Shows a dialog displaying the members of a friend circle
  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    Circle circle, {
    required String currentUserId,
    required Function(BuildContext, Circle) showInviteToCircleDialog,
  }) {
    return showDialog(
      context: context,
      builder:
          (_) => ProviderScope(
            parent: ProviderScope.containerOf(context),
            child: CircleMembersDialog(
              circle: circle,
              currentUserId: currentUserId,
              showInviteToCircleDialog: showInviteToCircleDialog,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(groupMembersProvider(circle.id));
    final bool canAddMembers =
        circle.isAdmin(currentUserId) || !circle.isPrivate;

    return AlertDialog(
      title: Text(
        '${circle.name} Members',
        style: TwTypography.heading6(context),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: membersAsync.when(
          data: (List<User> members) {
            if (members.isEmpty) {
              return const EmptyState(
                type: EmptyStateType.empty,
                title: 'No Members Yet',
                message: 'Invite people to join this group.',
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final bool memberIsAdmin = circle.isAdmin(member.id);
                final String initials =
                    member.displayName?.isNotEmpty == true
                        ? member.displayName!
                            .substring(
                              0,
                              (member.displayName!.length >= 2 ? 2 : 1),
                            )
                            .toUpperCase()
                        : '??';

                return ListTile(
                  leading: ShadAvatar(size: AvatarSize.sm, initials: initials),
                  title: Text(
                    member.displayName ??
                        'User ${member.id.substring(0, member.id.length > 4 ? 4 : member.id.length)}',
                  ),
                  subtitle: memberIsAdmin ? const Text('Admin') : null,
                );
              },
            );
          },
          loading:
              () => const LoadingState(
                type: LoadingStateType.circular,
                message: 'Loading members...',
              ),
          error:
              (error, stackTrace) => EmptyState(
                type: EmptyStateType.error,
                title: 'Error Loading Members',
                message: error.toString(),
                actionLabel: 'Retry',
                onActionPressed:
                    () => ref.refresh(groupMembersProvider(circle.id)),
              ),
        ),
      ),
      actions: [
        if (canAddMembers)
          ShadButton.primary(
            text: 'Add Members',
            onPressed: () {
              Navigator.of(context).pop();
              showInviteToCircleDialog(context, circle);
            },
          ),
        ShadButton.ghost(
          text: 'Close',
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
