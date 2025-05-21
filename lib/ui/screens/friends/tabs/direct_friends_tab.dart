import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resbite_app/ui/screens/friends/services/services.dart'
    as friends_services;
import 'package:resbite_app/ui/shared/empty_state.dart';
import 'package:resbite_app/ui/shared/loading_state.dart';

/// Tab that displays the user's direct friends list
class DirectFriendsTab extends ConsumerWidget {
  final String searchQuery;
  final Function(BuildContext) showSyncContactsDialog;
  final Function(dynamic) buildFriendItem;

  const DirectFriendsTab({
    super.key,
    required this.searchQuery,
    required this.showSyncContactsDialog,
    required this.buildFriendItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the newer directFriendsListProvider instead of legacy directFriendsProvider
    final friendsAsync = ref.watch(friends_services.directFriendsListProvider);

    return RefreshIndicator(
      onRefresh: () async {
        // Use the newer directFriendsListProvider for refresh
        ref.refresh(friends_services.directFriendsListProvider).value;
      },
      child: friendsAsync.when(
        data: (friends) {
          // Filter friends based on search query
          final filteredFriends =
              searchQuery.isEmpty
                  ? friends
                  : friends.where((friend) {
                    // Now properly accessing FriendConnection properties
                    final user = friend.user;
                    // User fields for search comparison
                    final displayName = user.displayName;
                    final email = user.email;

                    return (displayName?.toLowerCase() ?? '').contains(
                          searchQuery.toLowerCase(),
                        ) ||
                        email.toLowerCase().contains(searchQuery.toLowerCase());
                  }).toList();

          if (filteredFriends.isEmpty) {
            return EmptyState(
              type: EmptyStateType.empty,
              title:
                  searchQuery.isEmpty ? 'No Friends Yet' : 'No Results Found',
              message:
                  searchQuery.isEmpty
                      ? 'Sync your contacts to find friends using Resbite.'
                      : 'Try a different search term or sync more contacts.',
              customIcon: Icons.people_outline,
              onActionPressed: () {
                showSyncContactsDialog(context);
              },
              actionLabel: 'Add Friends',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredFriends.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final friend = filteredFriends[index];
              return buildFriendItem(friend);
            },
          );
        },
        loading:
            () => LoadingState(
              type: LoadingStateType.shimmer,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: LoadingState.listItemSkeleton(height: 70),
                  );
                },
              ),
            ),
        error:
            (error, _) => EmptyState(
              type: EmptyStateType.error,
              title: 'Error Loading Friends',
              message: 'We couldn\'t load your friends. Please try again.',
              onActionPressed: () async {
                ref.refresh(friends_services.directFriendsListProvider).value;
              },
              actionLabel: 'Try Again',
            ),
      ),
    );
  }
}
