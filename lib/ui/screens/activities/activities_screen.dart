import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme.dart';
import '../../../models/activity.dart';
import '../../../models/category.dart';
import '../../../services/app_state.dart';
import '../../../providers/activities_provider.dart';
import '../../../ui/components/resbite_card.dart';
import '../../../ui/components/resbite_button.dart';

class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  String? _selectedCategoryId;
  
  // Helper method to get colors based on activity ID
  List<Color> _getActivityColors(String id) {
    // Generate colors based on the hash code of the ID
    final hash = id.hashCode;
    
    // Predefined gradient pairs for different activity types
    final gradients = [
      [const Color(0xFF2D77D0), const Color(0xFF3596D2)], // Blue
      [const Color(0xFF4AC6B7), const Color(0xFF5EDDB3)], // Teal
      [const Color(0xFFFFA726), const Color(0xFFFFCC80)], // Orange
      [const Color(0xFF7C4DFF), const Color(0xFFB388FF)], // Purple
      [const Color(0xFF43A047), const Color(0xFF81C784)], // Green
      [const Color(0xFFE53935), const Color(0xFFEF9A9A)], // Red
      [const Color(0xFF5C6BC0), const Color(0xFF9FA8DA)], // Indigo
      [const Color(0xFF8D6E63), const Color(0xFFBCAAA4)], // Brown
    ];
    
    // Use the hash to select a gradient
    final index = hash.abs() % gradients.length;
    return gradients[index];
  }
  
  // Helper method to get icon based on activity ID
  IconData _getActivityIcon(String id) {
    // Generate icon based on the hash code of the ID
    final hash = id.hashCode;
    
    // Predefined icons for different activity types
    final icons = [
      Icons.sports_basketball,
      Icons.restaurant,
      Icons.movie,
      Icons.music_note,
      Icons.hiking,
      Icons.beach_access,
      Icons.emoji_events,
      Icons.book,
      Icons.local_cafe,
      Icons.sports_soccer,
      Icons.fitness_center,
      Icons.palette,
    ];
    
    // Use the hash to select an icon
    final index = hash.abs() % icons.length;
    return icons[index];
  }
  
  @override
  Widget build(BuildContext context) {
    // Watch categories data
    final categoriesAsync = ref.watch(categoriesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Activities',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 3,
        actions: [
          // Search button with Material Design 3 styling
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton.filledTonal(
              icon: const Icon(Icons.search, size: 20),
              onPressed: () {
                // Show search functionality with Material Design 3 snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Search functionality coming soon!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              tooltip: 'Search activities',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          // Filter button for additional filtering options
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton.filledTonal(
              icon: const Icon(Icons.tune, size: 20),
              onPressed: () {
                // Show filter options in the future
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Advanced filtering options coming soon!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              tooltip: 'Filter activities',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories filter
          categoriesAsync.when(
            data: (categories) => _buildCategoriesFilter(categories),
            loading: () => Container(
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ),
            error: (_, __) => Container(
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Error loading categories',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Activities list
          Expanded(
            child: _buildActivitiesList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoriesFilter(List<Category> categories) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        // Use Material Design 3 rounded corners
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: categories.length + 1, // +1 for "All" option
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" option with Material Design 3 FilterChip styling
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  'All',
                  style: TextStyle(
                    color: _selectedCategoryId == null 
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                selected: _selectedCategoryId == null,
                showCheckmark: false,
                // Use proper Material Design 3 color scheme
                selectedColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onSelected: (_) {
                  setState(() {
                    _selectedCategoryId = null;
                  });
                },
              ),
            );
          }
          
          // Category chips with Material Design 3 FilterChip styling
          final category = categories[index - 1];
          final selected = _selectedCategoryId == category.id;
          
          // Use different colors for different categories to create visual variety
          final categoryColors = [
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.tertiary,
            Theme.of(context).colorScheme.primary,
          ];
          final colorIndex = category.name.hashCode % categoryColors.length;
          final chipColor = categoryColors[colorIndex];
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                category.name,
                style: TextStyle(
                  color: selected 
                      ? Theme.of(context).colorScheme.onSecondaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: selected,
              showCheckmark: false,
              avatar: selected 
                ? Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  )
                : null,
              // Use proper Material Design 3 color scheme
              selectedColor: Theme.of(context).colorScheme.secondaryContainer,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onSelected: (_) {
                setState(() {
                  _selectedCategoryId = category.id;
                });
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildActivitiesList() {
    // Fetch activities based on selected category
    final activitiesAsync = _selectedCategoryId != null
        ? ref.watch(activitiesByCategoryProvider(_selectedCategoryId!))
        : ref.watch(activitiesProvider);
    
    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedCategoryId != null) {
          ref.refresh(activitiesByCategoryProvider(_selectedCategoryId!));
        } else {
          ref.refresh(activitiesProvider);
        }
      },
      child: activitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
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
                          _selectedCategoryId != null
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
                      _selectedCategoryId != null
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
                      _selectedCategoryId != null
                          ? 'Try selecting a different category or check back later for new additions.'
                          : 'We\'re working on adding exciting activities for you. Check back soon!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Material Design 3 buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Change category button
                        if (_selectedCategoryId != null)
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedCategoryId = null;
                              });
                            },
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
                        
                        if (_selectedCategoryId != null)
                          const SizedBox(width: 16),
                          
                        // Refresh button with Material Design 3 styling
                        FilledButton.icon(
                          onPressed: () {
                            if (_selectedCategoryId != null) {
                              ref.refresh(activitiesByCategoryProvider(_selectedCategoryId!));
                            } else {
                              ref.refresh(activitiesProvider);
                            }
                          },
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
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildActivityItem(activities[index]),
              );
            },
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Material Design 3 progress indicator with branded color
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              
              // Loading text with branded color
              Text(
                'Loading Activities...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              
              // Additional context for the loading state
              Text(
                'We\'re getting the best activities for you',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Material Design 3 error indicator
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.error_outline,
                      size: 40,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Error title with Material Design 3 typography
                Text(
                  'Something Went Wrong',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Error description with Material Design 3 typography
                Text(
                  'We couldn\'t load the activities. Please check your connection and try again.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // Error details in a card for better visualization
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                // Material Design 3 "Try Again" button
                FilledButton.icon(
                  onPressed: () {
                    if (_selectedCategoryId != null) {
                      ref.refresh(activitiesByCategoryProvider(_selectedCategoryId!));
                    } else {
                      ref.refresh(activitiesProvider);
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildActivityItem(Activity activity) {
    // Build category chips with Material Design 3 styling
    Widget? categoryChips;
    if (activity.categories.isNotEmpty) {
      // Randomize colors for different categories for visual variety
      final categoryColors = [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.secondary,
        Theme.of(context).colorScheme.tertiary,
      ];
      
      categoryChips = Wrap(
        spacing: 8,
        runSpacing: 8,
        children: activity.categories.map((category) {
          // Assign a consistent color to each category based on name
          final colorIndex = category.name.hashCode % categoryColors.length;
          final chipColor = categoryColors[colorIndex];
          
          // Create Material Design 3 styled chip
          return Chip(
            label: Text(
              category.name,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            avatar: Icon(
              Icons.circle,
              size: 12,
              color: chipColor,
            ),
          );
        }).toList(),
      );
    }
    
    // Create action buttons with Material Design 3 styling
    final actions = [
      // Details button (secondary action)
      OutlinedButton.icon(
        onPressed: () {
          Navigator.of(context).pushNamed(
            '/activities/details',
            arguments: {'id': activity.id},
          );
        },
        icon: const Icon(Icons.info_outline, size: 18),
        label: const Text('Details'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: const Size(0, 36),
          visualDensity: VisualDensity.compact,
          textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
        ),
      ),
      const SizedBox(width: 8),
      
      // Start Resbite button (primary action)
      FilledButton.icon(
        onPressed: () {
          Navigator.of(context).pushNamed(
            '/start-resbite',
            arguments: {'activityId': activity.id},
          );
        },
        icon: const Icon(Icons.play_arrow_rounded, size: 18),
        label: const Text('Start Resbite'),
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          foregroundColor: Theme.of(context).colorScheme.onTertiary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: const Size(0, 36),
          visualDensity: VisualDensity.compact,
          textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ];
    
    // Determine if we should use a gradient based on some condition
    final useGradient = activity.categories.isNotEmpty && 
      activity.categories.any((c) => c.name.toLowerCase() == 'featured');
    
    // Create Material Design 3 card
    return Card(
      elevation: 2,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            '/activities/details',
            arguments: {'id': activity.id},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient and icon
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getActivityColors(activity.id),
                ),
              ),
              child: Stack(
                children: [
                  // Activity icon
                  Center(
                    child: Icon(
                      _getActivityIcon(activity.id),
                      size: 64,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  
                  // Featured badge for special activities
                  if (activity.categories.any((c) => c.name.toLowerCase() == 'featured'))
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Theme.of(context).colorScheme.onTertiaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Featured',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onTertiaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Content area
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with Material Design 3 typography
                  Text(
                    activity.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Description with Material Design 3 typography
                  if (activity.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      activity.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  // Category chips with Material Design 3 styling
                  if (categoryChips != null) ...[
                    const SizedBox(height: 16),
                    categoryChips,
                  ],
                  
                  // Action buttons with Material Design 3 styling
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}