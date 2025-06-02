import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resbite_app/services/providers.dart'; // Generic resbitesProvider
import 'package:resbite_app/models/resbite_filter.dart';

import 'empty_resbites_state.dart';
import 'resbite_card.dart';

class ResbitesTabContent extends ConsumerWidget {
  final bool upcoming;

  const ResbitesTabContent({required this.upcoming, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the generic resbites provider with the ResbiteFilter
    final resbitesAsyncValue = ref.watch(
      resbitesProvider(ResbiteFilter(upcoming: upcoming)),
    );

    return RefreshIndicator(
      onRefresh: () async {
        // Pull-to-refresh: refresh the FutureProvider and wait for completion
        await ref.refresh(
          resbitesProvider(ResbiteFilter(upcoming: upcoming)).future,
        );
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
