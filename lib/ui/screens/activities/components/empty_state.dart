import 'package:flutter/material.dart';

/// Empty state widget for when no activities are available
class EmptyState extends StatelessWidget {
  final String? selectedCategoryId;
  final VoidCallback onRefresh;
  final VoidCallback? onClearFilter;

  const EmptyState({
    super.key,
    required this.selectedCategoryId,
    required this.onRefresh,
    this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon with Material Design 3 container styling
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  selectedCategoryId != null
                      ? Icons.category_outlined
                      : Icons.hiking_outlined,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Empty state title with Material Design 3 typography
            Text(
              selectedCategoryId != null
                  ? 'No Activities in This Category'
                  : 'No Activities Available',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Empty state description with Material Design 3 typography
            Text(
              selectedCategoryId != null
                  ? 'Try selecting a different category or check back later for new additions.'
                  : 'We\'re working on adding exciting activities for you. Check back soon!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Material Design 3 action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Change category button
                if (selectedCategoryId != null && onClearFilter != null)
                  OutlinedButton.icon(
                    onPressed: onClearFilter,
                    icon: const Icon(Icons.category_outlined),
                    label: const Text('All Categories'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                
                if (selectedCategoryId != null && onClearFilter != null)
                  const SizedBox(width: 16),
                  
                // Refresh button with Material Design 3 styling
                FilledButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
