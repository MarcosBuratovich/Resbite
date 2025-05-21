import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../providers/categories_provider.dart';
import '../../../../../services/providers.dart';

import 'activity_card.dart';
import 'empty_state.dart';
import 'error_state.dart';
import 'loading_state.dart';

/// Displays a list of activities with proper loading, empty, and error states
class ActivityList extends ConsumerWidget {
  final String? selectedCategoryId;
  final bool useAnimations;

  const ActivityList({
    super.key,
    this.selectedCategoryId,
    this.useAnimations = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch activities based on selected category
    final activitiesAsync = selectedCategoryId != null
        ? ref.watch(activitiesByCategoryProvider(selectedCategoryId!))
        : ref.watch(activitiesProvider);
    
    return RefreshIndicator(
      onRefresh: () async {
        if (selectedCategoryId != null) {
          // Store and await the refresh result
          final refreshResult = ref.refresh(activitiesByCategoryProvider(selectedCategoryId!));
          await refreshResult.when(
            data: (_) => Future.value(),
            error: (_, __) => Future.value(),
            loading: () => Future.value(),
          );
        } else {
          // Store and await the refresh result
          final refreshResult = ref.refresh(activitiesProvider);
          await refreshResult.when(
            data: (_) => Future.value(),
            error: (_, __) => Future.value(),
            loading: () => Future.value(),
          );
        }
      },
      child: activitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return EmptyState(
              selectedCategoryId: selectedCategoryId,
              onRefresh: () async {
                if (selectedCategoryId != null) {
                  // Store and await the refresh result
                  final refreshResult = ref.refresh(activitiesByCategoryProvider(selectedCategoryId!));
                  await refreshResult.when(
                    data: (_) => Future.value(),
                    error: (_, __) => Future.value(),
                    loading: () => Future.value(),
                  );
                } else {
                  // Store and await the refresh result
                  final refreshResult = ref.refresh(activitiesProvider);
                  await refreshResult.when(
                    data: (_) => Future.value(),
                    error: (_, __) => Future.value(),
                    loading: () => Future.value(),
                  );
                }
              },
              onClearFilter: selectedCategoryId != null 
                ? () => ref.read(selectedCategoryProvider.notifier).state = null
                : null,
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final Widget activityCard = Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ActivityCard(
                  activity: activities[index],
                ),
              );
              
              // Apply animations if enabled
              if (useAnimations) {
                return activityCard
                  .animate(delay: (100 * index).ms)
                  .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuad)
                  .fadeIn(duration: 800.ms);
              }
              
              return activityCard;
            },
          );
        },
        loading: () => const LoadingState(),
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () async {
            if (selectedCategoryId != null) {
              // Store and await the refresh result
              final refreshResult = ref.refresh(activitiesByCategoryProvider(selectedCategoryId!));
              await refreshResult.when(
                data: (_) => Future.value(),
                error: (_, __) => Future.value(),
                loading: () => Future.value(),
              );
            } else {
              // Store and await the refresh result
              final refreshResult = ref.refresh(activitiesProvider);
              await refreshResult.when(
                data: (_) => Future.value(),
                error: (_, __) => Future.value(),
                loading: () => Future.value(),
              );
            }
          },
        ),
      ),
    );
  }
}

// Provider is now imported from centralized providers/categories_provider.dart
