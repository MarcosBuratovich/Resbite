import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resbite_app/components/ui.dart'; // ShadAvatar, ShadButton
import 'package:resbite_app/models/circle.dart';
import 'package:resbite_app/models/user.dart';
import 'package:resbite_app/ui/screens/friends/services/group_service_impl.dart';
import 'package:resbite_app/services/providers.dart';
import 'package:resbite_app/utils/logger.dart';

class CircleDetailsScreen extends ConsumerWidget {
  final String circleId;
  const CircleDetailsScreen({Key? key, required this.circleId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circleAsync = ref.watch(groupDetailsProvider(circleId));
    final membersAsync = ref.watch(groupMembersProvider(circleId));
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(circleAsync.when(
          data: (c) => c.name,
          loading: () => 'Circle',
          error: (_, __) => 'Circle',
        )),
      ),
      body: circleAsync.when(
        data: (circle) => _buildContent(context, ref, circle, membersAsync, currentUserId),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: circleAsync.when(
        data: (circle) {
          final isAdmin = circle.isAdmin(currentUserId ?? '');
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ShadButton.destructive(
              text: isAdmin ? 'Delete Group' : 'Leave Group',
              isFullWidth: true,
              onPressed: () async {
                try {
                  final service = ref.read(groupServiceProvider);
                  if (isAdmin) {
                    await service.deleteCircle(circle.id);
                  } else {
                    await service.leaveCircle(circle.id);
                  }
                  Navigator.of(context).pop();
                } catch (e, st) {
                  AppLogger.error('Action failed', e, st);
                }
              },
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Circle circle, AsyncValue<List<User>> membersAsync, String? currentUserId) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(circle.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          if (circle.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(circle.description),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.people),
              const SizedBox(width: 4),
              Text('${circle.memberCount} members'),
              const Spacer(),
              Text('Created: ${circle.createdAt.toLocal().toString().split(' ')[0]}'),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text('Members', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Expanded(
            child: membersAsync.when(
              data: (members) {
                if (members.isEmpty) return const Center(child: Text('No members yet.'));
                return ListView.separated(
                  itemCount: members.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final m = members[i];
                    final memberIsAdmin = circle.isAdmin(m.id);
                    return Row(
                      children: [
                        ShadAvatar(
                          size: AvatarSize.md,
                          imageUrl: m.profileImageUrl,
                          initials: _initials(m),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.displayName ?? m.email, style: Theme.of(context).textTheme.bodyMedium),
                              if (memberIsAdmin)
                                Text('Admin', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading members: $e')),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(User m) {
    final name = m.displayName;
    if (name != null && name.isNotEmpty) {
      final parts = name.split(' ');
      if (parts.length > 1) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      return parts[0][0].toUpperCase();
    }
    return m.email.isNotEmpty ? m.email[0].toUpperCase() : '';
  }
}
