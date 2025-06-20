import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resbite_app/models/circle.dart';
import 'package:resbite_app/ui/screens/friends/services/services.dart' as friends_services;
import 'package:resbite_app/ui/shared/empty_state.dart';
import 'package:resbite_app/ui/shared/loading_state.dart';

/// Tab that displays the user's groups
class GroupsTab extends ConsumerWidget {
  final String searchQuery;
  final Function(BuildContext) showCreateGroupDialog;
  final Widget Function(Circle) buildCircleWidget;

  const GroupsTab({
    super.key,
    required this.searchQuery,
    required this.showCreateGroupDialog,
    required this.buildCircleWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circlesAsync = ref.watch(friends_services.userGroupsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(friends_services.userGroupsProvider).value;
      },
      child: circlesAsync.when(
        data: (circles) {
          final filteredCircles = searchQuery.isEmpty
              ? circles
              : circles.where((circle) {
                  final name = circle.name;
                  final description = circle.description;
                  return name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                      description.toLowerCase().contains(searchQuery.toLowerCase());
                }).toList();

          if (filteredCircles.isEmpty) {
            return EmptyState(
              type: EmptyStateType.empty,
              title: searchQuery.isEmpty ? 'No Groups Yet' : 'No Results Found',
              message: searchQuery.isEmpty
                  ? 'Create your first group to organise your friends.'
                  : 'Try a different search term.',
              customIcon: Icons.group,
              onActionPressed: () => showCreateGroupDialog(context),
              actionLabel: 'Create Group',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredCircles.length,
            itemBuilder: (context, index) {
              final circle = filteredCircles[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: buildCircleWidget(circle),
              );
            },
          );
        },
        loading: () => LoadingState(
          type: LoadingStateType.shimmer,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: LoadingState.listItemSkeleton(height: 100),
            ),
          ),
        ),
        error: (error, _) => EmptyState(
          type: EmptyStateType.error,
          title: 'Error Loading Groups',
          message: 'We couldn\'t load your groups. Please try again.',
          onActionPressed: () async {
            ref.refresh(friends_services.userGroupsProvider).value;
          },
          actionLabel: 'Try Again',
        ),
      ),
    );
  }
}
