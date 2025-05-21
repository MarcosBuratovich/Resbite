import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resbite_app/models/circle.dart';
import 'package:resbite_app/ui/screens/friends/services/services.dart'
    as friends_services;
import 'package:resbite_app/ui/shared/empty_state.dart';
import 'package:resbite_app/ui/shared/loading_state.dart';

/// Tab that displays the user's friend circles
class CirclesTab extends ConsumerWidget {
  final String searchQuery;
  final Function(BuildContext) showCreateCircleDialog;
  final Widget Function(Circle) buildCircleItem;

  const CirclesTab({
    super.key,
    required this.searchQuery,
    required this.showCreateCircleDialog,
    required this.buildCircleItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Using the newer userCirclesProvider from circle_service.dart
    final circlesAsync = ref.watch(friends_services.userCirclesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        // Using the newer userCirclesProvider for refresh
        ref.refresh(friends_services.userCirclesProvider).value;
      },
      child: circlesAsync.when(
        data: (circles) {
          // Filter circles based on search query
          final filteredCircles =
              searchQuery.isEmpty
                  ? circles
                  : circles.where((circle) {
                    final name = circle.name;
                    final description = circle.description;
                    return name.toLowerCase().contains(
                          searchQuery.toLowerCase(),
                        ) ||
                        description.toLowerCase().contains(
                          searchQuery.toLowerCase(),
                        );
                  }).toList();

          if (filteredCircles.isEmpty) {
            return EmptyState(
              type: EmptyStateType.empty,
              title:
                  searchQuery.isEmpty
                      ? 'No Friend Circles Yet'
                      : 'No Results Found',
              message:
                  searchQuery.isEmpty
                      ? 'Create your first friend circle to organize your friends.'
                      : 'Try a different search term.',
              customIcon: Icons.group,
              onActionPressed: () {
                showCreateCircleDialog(context);
              },
              actionLabel: 'Create Circle',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredCircles.length,
            itemBuilder: (context, index) {
              final circle = filteredCircles[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: buildCircleItem(circle),
              );
            },
          );
        },
        loading:
            () => LoadingState(
              type: LoadingStateType.shimmer,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: LoadingState.listItemSkeleton(height: 100),
                  );
                },
              ),
            ),
        error:
            (error, _) => EmptyState(
              type: EmptyStateType.error,
              title: 'Error Loading Circles',
              message:
                  'We couldn\'t load your friend circles. Please try again.',
              onActionPressed: () async {
                ref.refresh(friends_services.userCirclesProvider).value;
              },
              actionLabel: 'Try Again',
            ),
      ),
    );
  }
}
