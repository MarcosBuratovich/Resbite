import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../config/feature_flags.dart';
// Theme is accessed through Theme.of(context)
import '../../../models/activity.dart';
import '../../../models/category.dart';
import '../../../services/providers.dart';
import '../../../providers/activities_provider.dart';
import 'services/index.dart';
// UI components are referenced through composition in the screen

class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  String? _selectedCategoryId;
  late final ActivitiesService _activitiesService;

  @override
  void initState() {
    super.initState();
    _activitiesService = ref.read(activitiesServiceProvider);
  }

  @override
  Widget build(BuildContext context) {
    // Watch categories data
    final categoriesAsync = ref.watch(categoriesProvider);
    final useModernDesign = FeatureFlags.enableNewActivityDetails;

    return Scaffold(
      appBar:
          useModernDesign
              ? AppBar(
                title: const Text(
                  'Discover',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF462748),
                  ),
                ),
                centerTitle: false,
                elevation: 0,
                backgroundColor: Colors.white,
                scrolledUnderElevation: 0,
                actions: [
                  // Debug button for refactored screen testing
                  if (FeatureFlags.enableDebugging)
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: IconButton(
                        icon: const Icon(Icons.bug_report, size: 20),
                        onPressed: () {
                          // Navigate to refactored activities screen
                          Navigator.of(
                            context,
                          ).pushNamed('/activities/refactored');
                        },
                        tooltip: 'Test Refactored Screen',
                      ),
                    ),
                ],
              )
              : AppBar(
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
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSecondaryContainer,
                              ),
                            ),
                            backgroundColor:
                                Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
                      tooltip: 'Search activities',
                      style: IconButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondaryContainer,
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
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onTertiaryContainer,
                              ),
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.tertiaryContainer,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
                      tooltip: 'Filter activities',
                      style: IconButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.tertiaryContainer,
                        foregroundColor:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                  // Debug button for refactored screen testing
                  if (FeatureFlags.enableDebugging)
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: IconButton.filledTonal(
                        icon: const Icon(Icons.bug_report, size: 20),
                        onPressed: () {
                          // Navigate to refactored activities screen
                          Navigator.of(
                            context,
                          ).pushNamed('/activities/refactored');
                        },
                        tooltip: 'Test Refactored Screen',
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.errorContainer,
                          foregroundColor:
                              Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                ],
              ),
      body: Column(
        children: [
          // Categories filter
          categoriesAsync.when(
            data:
                (categories) =>
                    useModernDesign
                        ? _buildModernCategoriesFilter(categories)
                        : _buildCategoriesFilter(categories),
            loading:
                () => Container(
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
            error:
                (_, __) => Container(
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
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
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
            child:
                useModernDesign
                    ? _buildModernActivitiesList()
                    : _buildActivitiesList(),
          ),
        ],
      ),
    );
  }

  /// Modern categories filter with pastel colors and animated chips
  Widget _buildModernCategoriesFilter(List<Category> categories) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: categories.length + 1, // +1 for "All" option
        itemBuilder: (context, index) {
          // Define a collection of pastel colors for tags
          final tagColors = [
            const Color(0xFFEFB0B4), // Pink
            const Color(0xFF89CAC7), // Teal
            const Color(0xFFEBD9BA), // Sand
            const Color(0xFFB8B9D9), // Lavender
            const Color(0xFFA9D2B4), // Mint
          ];

          if (index == 0) {
            // "All" option with modern styling
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = null;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _selectedCategoryId == null
                                ? const Color(0xFF462748)
                                : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow:
                            _selectedCategoryId == null
                                ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF462748,
                                    ).withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                                : null,
                      ),
                      child: Text(
                        'All',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              _selectedCategoryId == null
                                  ? Colors.white
                                  : const Color(0xFF462748),
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .slide(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                    duration: 250.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 200.ms),
            );
          }

          // Category chips with modern styling
          final category = categories[index - 1];
          final selected = _selectedCategoryId == category.id;

          // Use varied pastel colors based on category name
          final tagColor = tagColors[category.name.hashCode % tagColors.length];

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = category.id;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? tagColor : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow:
                          selected
                              ? [
                                BoxShadow(
                                  color: tagColor.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            selected ? Colors.white : const Color(0xFF462748),
                      ),
                    ),
                  ),
                )
                .animate()
                .slide(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                  duration: 250.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 200.ms),
          );
        },
      ),
    );
  }

  /// Legacy categories filter with Material Design 3 styling
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
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
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
                    color:
                        _selectedCategoryId == null
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                selected: _selectedCategoryId == null,
                showCheckmark: false,
                // Use proper Material Design 3 color scheme
                selectedColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
          // Use the hash code to select a color for active chips
          final Color chipColor =
              [
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.tertiary,
                Theme.of(context).colorScheme.primary,
              ][category.name.hashCode %
                  3]; // Use the hash code to select a color for the avatar

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                category.name,
                style: TextStyle(
                  color:
                      selected
                          ? Theme.of(context).colorScheme.onSecondaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: selected,
              // Use avatar icon with selected color
              avatar:
                  selected
                      ? Icon(Icons.check_circle, size: 18, color: chipColor)
                      : null,
              // Use proper Material Design 3 color scheme
              selectedColor: Theme.of(context).colorScheme.secondaryContainer,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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

  /// Modern activities list with cards using pastel colors and animations
  Widget _buildModernActivitiesList() {
    // Fetch activities based on selected category
    final activitiesAsync =
        _selectedCategoryId != null
            ? ref.watch(activitiesByCategoryProvider(_selectedCategoryId!))
            : ref.watch(activitiesProvider);

    return RefreshIndicator(
      color: const Color(0xFF462748),
      backgroundColor: Colors.white,
      onRefresh: () async {
        if (_selectedCategoryId != null) {
          // Store and await the refresh result
          // Use the service layer to handle refresh
          await _activitiesService.refreshActivitiesByCategory(_selectedCategoryId!);
        } else {
          // Store and await the refresh result
          // Use the service layer to handle refresh
          await _activitiesService.refreshActivities();
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
                    // Empty state icon with modern styling
                    SvgPicture.asset(
                      'assets/Resbites Illustrations/SVGs/Artboard 7.svg',
                      height: 180,
                    ).animate().fadeIn(duration: 600.ms),
                    const SizedBox(height: 32),

                    // Empty state title with modern typography
                    Text(
                      _selectedCategoryId != null
                          ? 'No Activities in This Category'
                          : 'No Activities Available',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF462748),
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
                    const SizedBox(height: 16),

                    // Empty state description with modern typography
                    Text(
                      _selectedCategoryId != null
                          ? 'Try selecting a different category or check back later for new additions.'
                          : 'We\'re working on adding exciting activities for you. Check back soon!',
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
                    const SizedBox(height: 40),

                    // Action buttons with modern styling
                    if (_selectedCategoryId != null)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategoryId = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF89CAC7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'View All Categories',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ).animate().fadeIn(duration: 800.ms, delay: 600.ms),
                  ],
                ),
              ),
            );
          }

          // Staggered grid for activities
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildModernActivityItem(activities[index], index),
                );
              },
            ),
          );
        },
        loading:
            () => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Modern progress indicator
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF462748),
                    ),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 24),

                  // Loading text with modern typography
                  const Text(
                    'Finding Activities...',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF462748),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Loading description with modern typography
                  const Text(
                    'We\'re gathering the perfect activities for you',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
        error:
            (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Error illustration
                    SvgPicture.asset(
                      'assets/Resbites Illustrations/SVGs/Artboard 8.svg',
                      height: 160,
                    ).animate().fadeIn(duration: 600.ms),
                    const SizedBox(height: 32),

                    // Error title with modern typography
                    const Text(
                      'Oops! Something Went Wrong',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF462748),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Error message with modern typography
                    const Text(
                      'We had trouble loading activities. Please check your connection and try again.',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Retry button with modern styling
                    ElevatedButton(
                      onPressed: () async {
                        if (_selectedCategoryId != null) {
                          // Use service layer to handle refresh
                          await _activitiesService.refreshActivitiesByCategory(_selectedCategoryId!);
                        } else {
                          // Use service layer to handle refresh
                          await _activitiesService.refreshActivities();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF462748),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  /// Modern activity item card with pastel colors and animations
  Widget _buildModernActivityItem(Activity activity, int index) {
    // Define a collection of pastel colors for cards
    final cardColors = [
      const Color(0xFFEFB0B4), // Pink
      const Color(0xFF89CAC7), // Teal
      const Color(0xFFEBD9BA), // Sand
      const Color(0xFFB8B9D9), // Lavender
      const Color(0xFFA9D2B4), // Mint
    ];

    // Determine color based on activity ID
    final colorIndex = activity.id.hashCode % cardColors.length;
    final cardColor = cardColors[colorIndex];

    // Build category pills with modern styling
    Widget? categoryPills;
    if (activity.categories.isNotEmpty) {
      categoryPills = Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            activity.categories.take(3).map((category) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF462748),
                  ),
                ),
              );
            }).toList(),
      );
    }

    return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                '/activities/details',
                arguments: {'id': activity.id},
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: cardColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity image or gradient background with title overlay
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      gradient:
                          activity.imageUrl == null
                              ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [cardColor, cardColor.withOpacity(0.7)],
                              )
                              : null,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Activity image if available
                        if (activity.imageUrl != null)
                          CachedNetworkImage(
                            imageUrl: activity.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Container(
                                  color: cardColor.withOpacity(0.3),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Container(
                                  color: cardColor.withOpacity(0.3),
                                  child: const Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 40,
                                    color: Colors.white70,
                                  ),
                                ),
                          ),

                        // No gradient overlay needed
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (categoryPills != null) categoryPills,
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (activity.emoji != null) ...[
                                    Text(
                                      activity.emoji!,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Expanded(
                                    child: Text(
                                      activity.title,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(0, 1),
                                            blurRadius: 3,
                                            color: Color(0x99000000),
                                          ),
                                        ],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Featured badge if applicable
                        if (activity.featured)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFB0B4).withOpacity(0.9),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Featured',
                                    style: TextStyle(
                                      fontFamily: 'Quicksand',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Content area with activity details
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description with modern typography
                        if (activity.description != null) ...[
                          Text(
                            activity.description!,
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Action buttons with modern styling
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Details button
                            OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  '/activities/details',
                                  arguments: {'id': activity.id},
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF462748),
                                elevation: 0,
                                side: const BorderSide(
                                  color: Color(0xFF462748),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Details',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Start Resbite button
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  '/start-resbite',
                                  arguments: {'activityId': activity.id},
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF89CAC7),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Start Resbite',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: (100 * index).ms)
        .slide(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
          duration: 600.ms,
          curve: Curves.easeOutQuad,
        )
        .fadeIn(duration: 800.ms);
  }

  /// Legacy activities list with Material Design 3 styling
  Widget _buildActivitiesList() {
    // Fetch activities based on selected category
    final activitiesAsync =
        _selectedCategoryId != null
            ? ref.watch(activitiesByCategoryProvider(_selectedCategoryId!))
            : ref.watch(activitiesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedCategoryId != null) {
          // Store and await the refresh result
          // Use the service layer to handle refresh
          await _activitiesService.refreshActivitiesByCategory(_selectedCategoryId!);
        } else {
          // Store and await the refresh result
          // Use the service layer to handle refresh
          await _activitiesService.refreshActivities();
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
                              foregroundColor:
                                  Theme.of(context).colorScheme.primary,
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),

                        if (_selectedCategoryId != null)
                          const SizedBox(width: 16),

                        // Refresh button with Material Design 3 styling
                        FilledButton.icon(
                          onPressed: () async {
                            if (_selectedCategoryId != null) {
                              // Use service layer to handle refresh
                              await _activitiesService.refreshActivitiesByCategory(_selectedCategoryId!);
                            } else {
                              // Use service layer to handle refresh
                              await _activitiesService.refreshActivities();
                            }
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
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
        loading:
            () => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Material Design 3 progress indicator with branded color
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
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
        error:
            (error, _) => Center(
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
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          error.toString(),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    // Material Design 3 "Try Again" button
                    FilledButton.icon(
                      onPressed: () async {
                        if (_selectedCategoryId != null) {
                          // Use service layer to handle refresh
                          await _activitiesService.refreshActivitiesByCategory(_selectedCategoryId!);
                        } else {
                          // Use service layer to handle refresh
                          await _activitiesService.refreshActivities();
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  // Build an activity item card with Material Design 3 styling
  Widget _buildActivityItem(Activity activity) {
    // Prepare category chips if available
    Widget categoryChips;

    if (activity.categories.isNotEmpty) {
      categoryChips = Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            activity.categories.map((category) {
              // Use different colors for different categories to create visual variety
              final Color chipColor =
                  [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.tertiary,
                    Theme.of(context).colorScheme.primary,
                  ][category.name.hashCode %
                      3]; // Use the hash code to select a color for the avatar

              return Chip(
                label: Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                avatar: Icon(Icons.circle, size: 12, color: chipColor),
              );
            }).toList(),
      );
      return categoryChips; // Return the widget we created
    } else {
      return const SizedBox.shrink();
    }
  }
}
