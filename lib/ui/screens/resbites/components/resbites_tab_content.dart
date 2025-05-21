import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/providers.dart'; // Provides resbitesProvider & currentUserProvider
import 'empty_resbites_state.dart';
import 'resbite_card.dart';
import '../../../../models/resbite_filter.dart';

class ResbitesTabContent extends ConsumerWidget {
  final bool upcoming;

  const ResbitesTabContent({required this.upcoming, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserProvider).valueOrNull?.id;
    // Watch the appropriate resbites provider based on the 'upcoming' flag
    final resbitesAsyncValue = ref.watch(
      resbitesProvider(ResbiteFilter(upcoming: upcoming, userId: currentUserId)),
    );

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh the provider
        final _ = ref.refresh(
          resbitesProvider(ResbiteFilter(upcoming: upcoming, userId: currentUserId)),
        );
        // Optionally await the future if immediate feedback is needed, 
        // but RefreshIndicator handles the visual state.
      },
      child: resbitesAsyncValue.when(
        data: (data) {
          if (data.isEmpty) {
            // Use the extracted EmptyResbitesState component
            return EmptyResbitesState(upcoming: upcoming);
          }

          // Use ListView.builder with the extracted ResbiteCard component
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              // Pass the resbite data to the ResbiteCard
              return ResbiteCard(resbite: data[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error loading resbites: $error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ),
    );
  }
}
