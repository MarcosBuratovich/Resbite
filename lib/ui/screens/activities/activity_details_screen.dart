import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Theme is accessed through Theme.of(context)
import '../../../models/activity.dart';
import '../../../services/providers.dart';
import '../../../config/feature_flags.dart';

class ActivityDetailsScreen extends ConsumerWidget {
  final String activityId;

  const ActivityDetailsScreen({Key? key, required this.activityId}) : super(key: key);
  
  /// Gets the appropriate icon for a detail key
  IconData _getIconForDetailKey(String key) {
    switch (key.toLowerCase()) {
      case 'duration':
      case 'time':
        return Icons.access_time;
      case 'location':
      case 'place':
        return Icons.location_on;
      case 'cost':
      case 'price':
        return Icons.attach_money;
      case 'difficulty':
        return Icons.fitness_center;
      case 'age':
      case 'age range':
        return Icons.person;
      case 'required':
      case 'requirements':
        return Icons.assignment;
      case 'materials':
      case 'supplies':
        return Icons.shopping_bag;
      default:
        return Icons.info_outline;
    }
  }
  
  /// Gets a user-friendly display name for a detail key
  String _getDisplayNameForDetailKey(String key) {
    switch (key.toLowerCase()) {
      case 'duration':
        return 'Duration';
      case 'location':
        return 'Location';
      case 'cost':
        return 'Cost';
      case 'difficulty':
        return 'Difficulty';
      case 'age':
      case 'age_range':
        return 'Age Range';
      case 'required':
        return 'Requirements';
      case 'materials':
        return 'Materials Needed';
      default:
        // Convert snake_case or camelCase to Title Case
        return key
            .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
            .replaceAll('_', ' ')
            .trim()
            .split(' ')
            .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
            .join(' ');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch activity data
    final activityAsync = ref.watch(activityProvider(activityId));
    final useNewDesign = FeatureFlags.enableNewActivityDetails;
    
    return Scaffold(
      body: activityAsync.when(
        data: (activity) {
          if (activity == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Material Design 3 empty state
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.hiking_outlined,
                      size: 40,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Activity Not Found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The activity you\'re looking for doesn\'t exist or was removed.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }
          
          // Use the feature flag to decide which design to show
          return useNewDesign 
              ? _buildModernDesign(context, ref, activity)
              : _buildLegacyDesign(context, ref, activity);
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Material Design 3 loading indicator
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text('Loading activity details...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
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
                child: Icon(
                  Icons.error_outline,
                  size: 40,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Error Loading Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  ref.refresh(activityProvider(activityId));
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
              ),
            ],
          ),
        ),
      ),
      // Modern rounded floating action button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to start resbite screen with activity ID
          Navigator.of(context).pushNamed(
            '/start-resbite',
            arguments: activityId, // Pass activity ID directly, not in a map
          );
        },
        backgroundColor: const Color(0xFF462748), // Purple from design
        foregroundColor: Colors.white,
        icon: const Icon(Icons.calendar_today),
        label: const Text(
          'Start a Resbite',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
      ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 1, end: 0, duration: 500.ms),
    );
  }

  /// The modern design implementation with tag cloud, modern cards, and animations
  Widget _buildModernDesign(BuildContext context, WidgetRef ref, Activity activity) {
    return CustomScrollView(
      slivers: [
        // Modern sliver app bar with image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: const Color(0xFF89CAC7),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Activity image with gradient overlay
                activity.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: activity.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: const Color(0xFFB8B9D9).withOpacity(0.3),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFF89CAC7).withOpacity(0.2),
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                      ),
                    )
                  : Container(
                      color: const Color(0xFF89CAC7).withOpacity(0.2),
                      child: SvgPicture.asset(
                        'assets/Resbites Illustrations/SVGs/Artboard 3.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                
                // Gradient overlay for better text visibility
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.6, 1.0],
                    ),
                  ),
                ),
                
                // Bottom title
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        activity.title,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
                      
                      // Emoji and featured indicator if available
                      if (activity.emoji != null || activity.featured) ...[                        
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (activity.emoji != null) ...[                              
                              Text(
                                activity.emoji!,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                            ],
                            
                            if (activity.featured)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFB0B4).withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
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
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Favorite button
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.favorite_border, size: 24),
                onPressed: () {
                  // TODO: Add to favorites with snackbar feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Added to favorites'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF462748),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                tooltip: 'Add to favorites',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.3),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            // Share button
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: const Icon(Icons.share, size: 24),
                onPressed: () {
                  // TODO: Share activity
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Sharing coming soon'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF462748),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                tooltip: 'Share activity',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.3),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        
        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag cloud style categories
                if (activity.categories.isNotEmpty) ...[                  
                  // Tag cloud - modern design with varied colors and sizes
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: activity.categories.map((category) {
                      // Define a collection of pastel colors for tags
                      final tagColors = [
                        const Color(0xFFEFB0B4), // Pink
                        const Color(0xFF89CAC7), // Teal
                        const Color(0xFFEBD9BA), // Sand
                        const Color(0xFFB8B9D9), // Lavender
                        const Color(0xFFA9D2B4), // Mint
                      ];
                      
                      // Determine color based on category name
                      final colorIndex = category.name.hashCode % tagColors.length;
                      final tagColor = tagColors[colorIndex];
                      
                      // Vary the font size and padding based on category name length
                      final fontSize = category.name.length < 6 ? 15.0 : 13.0;
                      final verticalPadding = category.name.length < 6 ? 10.0 : 8.0;
                      final horizontalPadding = category.name.length < 6 ? 16.0 : 12.0;
                      
                      return Container(
                        padding: EdgeInsets.symmetric(
                          vertical: verticalPadding,
                          horizontal: horizontalPadding,
                        ),
                        decoration: BoxDecoration(
                          color: tagColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: tagColor,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          category.name,
                          style: TextStyle(
                            color: const Color(0xFF462748),
                            fontSize: fontSize,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ).animate().fadeIn(duration: 500.ms, delay: 100.ms * activity.categories.indexOf(category));
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Description section - modern card with subtle shadows
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description header with modern styling
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF89CAC7).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.description_outlined,
                                size: 20,
                                color: Color(0xFF89CAC7),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'About this activity',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF462748),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Description with better typography
                        Text(
                          activity.description ?? 'No description provided',
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                        ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Activity details section
                if (activity.details.isNotEmpty) ...[                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Details header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEBD9BA).withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.info_outline,
                                  size: 20,
                                  color: Color(0xFFCD9D56),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Activity Details',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF462748),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Detail items
                          ...activity.details.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEBD9BA).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _getIconForDetailKey(entry.key),
                                      size: 16,
                                      color: const Color(0xFFCD9D56),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getDisplayNameForDetailKey(entry.key),
                                          style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF462748),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          entry.value,
                                          style: const TextStyle(
                                            fontFamily: 'Quicksand',
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 600.ms, delay: 100.ms * activity.details.entries.toList().indexOf(entry));
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Tips section
                if (activity.tips.isNotEmpty) ...[                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tips header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB8B9D9).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lightbulb_outline,
                                  size: 20,
                                  color: Color(0xFF7071A4),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Tips & Suggestions',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF462748),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Tips list
                          ...activity.tips.asMap().entries.map((entry) {
                            final index = entry.key;
                            final tip = entry.value;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFB8B9D9).withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF7071A4),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: const TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontSize: 16,
                                        color: Colors.black87,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 600.ms, delay: 100.ms * index);
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Benefits section
                if (activity.benefits.isNotEmpty) ...[                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Benefits header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFA9D2B4).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.favorite_outline,
                                  size: 20,
                                  color: Color(0xFF459E60),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Benefits',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF462748),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Benefits list
                          ...activity.benefits.asMap().entries.map((entry) {
                            final index = entry.key;
                            final benefit = entry.value;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFA9D2B4).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Color(0xFF459E60),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      benefit,
                                      style: const TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontSize: 16,
                                        color: Colors.black87,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 600.ms, delay: 100.ms * index);
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Start a Resbite button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to start resbite flow
                      Navigator.of(context).pushNamed('/resbite/create', arguments: activity.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF462748),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Start a Resbite',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ).animate().fadeIn(duration: 800.ms, delay: 500.ms).slideY(begin: 0.2, end: 0, duration: 800.ms, curve: Curves.easeOutQuad),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// The legacy design implementation with Material Design components
  Widget _buildLegacyDesign(BuildContext context, WidgetRef ref, Activity activity) {
    return CustomScrollView(
      slivers: [
        // Material Design 3 app bar with image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          stretch: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 70,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.zero,
            title: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (activity.emoji != null)
                    Text(
                      activity.emoji!,
                      style: const TextStyle(fontSize: 24),
                    ),
                ],
              ),
            ),
            collapseMode: CollapseMode.parallax,
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.blurBackground,
            ],
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Activity image or gradient placeholder
                activity.imageUrl != null
                  ? Image.network(
                      activity.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.hiking,
                            size: 80,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        );
                      },
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.hiking,
                        size: 80,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    
                // Gradient overlay for better text visibility
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.85),
                        ],
                        stops: const [0.5, 0.95],
                      ),
                    ),
                  ),
                ),
                
                // Featured badge (if applicable)
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
          actions: [
            // Material Design 3 button styling
            // Favorite button
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.favorite_border, size: 24),
                onPressed: () {
                  // TODO: Add to favorites with snackbar feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Added to favorites'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF462748),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                tooltip: 'Add to favorites',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.3),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            // Share button
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: const Icon(Icons.share, size: 24),
                onPressed: () {
                  // TODO: Share activity
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Sharing coming soon'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF462748),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                tooltip: 'Share activity',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.3),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        
        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag cloud style categories
                if (activity.categories.isNotEmpty) ...[
                  // Tag cloud - modern design with varied colors and sizes
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: activity.categories.map((category) {
                      // Define a collection of pastel colors for tags
                      final tagColors = [
                        const Color(0xFFEFB0B4), // Pink
                        const Color(0xFF89CAC7), // Teal
                        const Color(0xFFEBD9BA), // Sand
                        const Color(0xFFB8B9D9), // Lavender
                        const Color(0xFFA9D2B4), // Mint
                      ];
                      
                      // Determine color and text styles based on category name
                      final colorIndex = category.name.hashCode % tagColors.length;
                      final tagColor = tagColors[colorIndex];
                      
                      // Vary the font size and padding based on category name length
                      // to create visual hierarchy in the tag cloud
                      final fontSize = category.name.length < 6 ? 15.0 : 13.0;
                      final verticalPadding = category.name.length < 6 ? 10.0 : 8.0;
                      final horizontalPadding = category.name.length < 6 ? 16.0 : 12.0;
                      
                      return Container(
                        padding: EdgeInsets.symmetric(
                          vertical: verticalPadding,
                          horizontal: horizontalPadding,
                        ),
                        decoration: BoxDecoration(
                          color: tagColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: tagColor,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          category.name,
                          style: TextStyle(
                            color: const Color(0xFF462748), // Dark purple text
                            fontSize: fontSize,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ).animate().fadeIn(duration: 500.ms, delay: 100.ms * activity.categories.indexOf(category));
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Description section - modern card with subtle shadows
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description header with modern styling
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF89CAC7).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.description_outlined,
                                size: 20,
                                color: Color(0xFF89CAC7),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'About this activity',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF462748),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Description with better typography
                        Text(
                          activity.description ?? 'No description provided',
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                        ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Space divider
                const SizedBox(height: 32),
                
                // Activity Details with modern styling
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFB0B4).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Color(0xFFEFB0B4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Activity Details',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF462748),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 800.ms, delay: 300.ms),
                const SizedBox(height: 16),
                
                // Modern card with details
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      // Location - Material Design 3 ListTile
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.location_on_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          'Location',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          'Various locations',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      
                      // Divider between items
                      Divider(
                        indent: 72,
                        endIndent: 16,
                        height: 1,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      
                      // Duration - Material Design 3 ListTile
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.timer_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        title: Text(
                          'Duration',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          activity.duration != null
                              ? '${activity.duration} minutes'
                              : 'Varies',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      
                      // Divider between items
                      Divider(
                        indent: 72,
                        endIndent: 16,
                        height: 1,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      
                      // Age Range - Material Design 3 ListTile
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.people_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        title: Text(
                          'Age Range',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          'Min age: ${activity.minAge ?? 'Any'}, Max age: ${activity.maxAge ?? 'Any'}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      
                      // Divider between items
                      Divider(
                        indent: 72,
                        endIndent: 16,
                        height: 1,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      
                      // Cost - Material Design 3 ListTile
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.monetization_on_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          'Cost',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          activity.estimatedCost == null || activity.estimatedCost == 0
                              ? 'Free'
                              : '\$${activity.estimatedCost}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: activity.estimatedCost == null || activity.estimatedCost == 0
                            ? Chip(
                                label: const Text('FREE'),
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                visualDensity: VisualDensity.compact,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Space divider
                const SizedBox(height: 32),
                
                // Tips header with modern styling
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA9D2B4).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: Color(0xFFA9D2B4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Tips & Suggestions',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF462748),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
                const SizedBox(height: 16),
                
                // Tips with modern styling
                activity.tips.isNotEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: activity.tips.map((tip) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      margin: const EdgeInsets.only(top: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFA9D2B4).withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.lightbulb,
                                        size: 18,
                                        color: Color(0xFFA9D2B4),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: const TextStyle(
                                          fontFamily: 'Quicksand',
                                          fontSize: 15,
                                          color: Colors.black87,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.info_outline,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'No tips available for this activity',
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 15,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
