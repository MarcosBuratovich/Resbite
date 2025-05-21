import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../../models/activity.dart';
import '../../../../../models/category.dart';

/// A Material Design 3 styled card to display an activity
class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onTap;

  const ActivityCard({super.key, required this.activity, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap:
            onTap ??
            () {
              // Default navigation to activity details screen
              Navigator.pushNamed(
                context,
                '/activity_details',
                arguments: activity,
              );
            },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(context),
            _buildContentSection(context),
          ],
        ),
      ),
    );
  }

  /// Builds the image section with featured badge if applicable
  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child:
              (activity.imageUrl != null && activity.imageUrl!.isNotEmpty)
                  ? CachedNetworkImage(
                    imageUrl: activity.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: Center(
                            child: Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                  )
                  : Container(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Icon(
                        _getActivityIcon(),
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
        ),
        if (activity.featured) _buildFeaturedBadge(context),
      ],
    );
  }

  /// Builds the featured badge for the activity
  Widget _buildFeaturedBadge(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'Featured',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the content section with title, description, and category chips
  Widget _buildContentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activity.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          if (activity.description != null)
            Text(
              activity.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 16),

          // Category chips if available
          _buildCategoryChips(context),
        ],
      ),
    );
  }

  /// Builds category chips based on activity categories
  Widget _buildCategoryChips(BuildContext context) {
    if (activity.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          activity.categories.map((category) {
            // Use hash code to select a consistent color for each category
            final Color chipColor = _getCategoryColor(context, category);

            return Chip(
              label: Text(
                category.name,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              avatar: Icon(Icons.circle, size: 12, color: chipColor),
            );
          }).toList(),
    );
  }

  /// Generates a consistent color for a category based on its name
  Color _getCategoryColor(BuildContext context, Category category) {
    final colorOptions = [
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
      Theme.of(context).colorScheme.primary,
    ];

    // Use hash code for consistent color selection
    return colorOptions[category.name.hashCode % colorOptions.length];
  }

  /// Returns an appropriate icon based on activity properties
  IconData _getActivityIcon() {
    // Map common activity keywords to icons
    final String title = activity.title.toLowerCase();

    if (title.contains('hike') ||
        title.contains('walk') ||
        title.contains('trek')) {
      return Icons.hiking;
    } else if (title.contains('swim') || title.contains('water')) {
      return Icons.pool;
    } else if (title.contains('bike') || title.contains('cycle')) {
      return Icons.pedal_bike;
    } else if (title.contains('game') || title.contains('play')) {
      return Icons.sports_esports;
    } else if (title.contains('cook') || title.contains('food')) {
      return Icons.restaurant;
    } else if (title.contains('art') || title.contains('craft')) {
      return Icons.palette;
    } else if (title.contains('music') || title.contains('sing')) {
      return Icons.music_note;
    } else if (title.contains('garden') || title.contains('plant')) {
      return Icons.nature;
    } else if (title.contains('read') || title.contains('book')) {
      return Icons.menu_book;
    } else {
      // Default icon if no matches
      return Icons.local_activity;
    }
  }
}
