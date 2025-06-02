import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../models/activity.dart';
import '../../../../../models/category.dart';
import '../../../../../services/providers.dart';

/// ActivityService defines the interface for all activity-related operations
abstract class ActivityService {
  /// Fetch all activities
  Future<List<Activity>> getActivities();

  /// Fetch activities by category
  Future<List<Activity>> getActivitiesByCategory(String categoryId);

  /// Fetch a specific activity by ID
  Future<Activity?> getActivityById(String id);

  /// Get featured activities
  Future<List<Activity>> getFeaturedActivities();

  /// Get recommended activities for the current user
  Future<List<Activity>> getRecommendedActivities();

  /// Get recent activities that have been added to the platform
  Future<List<Activity>> getRecentActivities({int limit = 10});

  /// Fetch all categories
  Future<List<Category>> getCategories();

  /// Toggle favorite status of an activity
  Future<bool> toggleFavorite(String activityId);

  /// Mark activity as completed
  Future<bool> markAsCompleted(String activityId);

  /// Refresh all activities data
  Future<void> refreshActivities();

  /// Refresh activities for a specific category
  Future<void> refreshActivitiesByCategory(String categoryId);

  /// Refresh categories data
  Future<void> refreshCategories();
}

/// ActivityServiceImpl implements the ActivityService interface
class ActivityServiceImpl implements ActivityService {
  final Ref _ref;

  const ActivityServiceImpl(this._ref);

  @override
  Future<List<Activity>> getActivities() async {
    try {
      return await _ref.read(activitiesProvider.future);
    } catch (e) {
      print('Error fetching activities: $e');
      return [];
    }
  }

  @override
  Future<List<Activity>> getActivitiesByCategory(String categoryId) async {
    try {
      return await _ref.read(activitiesByCategoryProvider(categoryId).future);
    } catch (e) {
      print('Error fetching activities by category: $e');
      return [];
    }
  }

  @override
  Future<Activity?> getActivityById(String id) async {
    try {
      return await _ref.read(activityProvider(id).future);
    } catch (e) {
      print('Error fetching activity by id: $e');
      return null;
    }
  }

  @override
  Future<List<Activity>> getFeaturedActivities() async {
    try {
      final activities = await getActivities();
      return activities.where((activity) => activity.featured).toList();
    } catch (e) {
      print('Error fetching featured activities: $e');
      return [];
    }
  }

  @override
  Future<List<Activity>> getRecommendedActivities() async {
    try {
      // This could be enhanced with recommendation logic based on user preferences
      // For now, return a sample of activities as recommendations
      final activities = await getActivities();

      // Filter by some criteria, for example user's profile preferences
      // This will be expanded with actual recommendation algorithms
      final filtered = activities.take(5).toList();

      return filtered;
    } catch (e) {
      print('Error fetching recommended activities: $e');
      return [];
    }
  }

  @override
  Future<List<Activity>> getRecentActivities({int limit = 10}) async {
    try {
      final activities = await getActivities();

      // Sort by created date if available
      activities.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return b.createdAt!.compareTo(a.createdAt!); // Newest first
      });

      return activities.take(limit).toList();
    } catch (e) {
      print('Error fetching recent activities: $e');
      return [];
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      return await _ref.read(categoriesProvider.future);
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  @override
  Future<bool> toggleFavorite(String activityId) async {
    try {
      final supabase = _ref.read(supabaseClientProvider);
      final user = _ref.read(currentUserProvider).valueOrNull;

      if (user == null) {
        return false;
      }

      // Remove favorite
      await supabase
          .from('activity_favorites')
          .delete()
          .eq('user_id', user.id)
          .eq('activity_id', activityId);
      return false; // Not favorited anymore
    } catch (e) {
      print('Error toggling favorite status: $e');
      return false;
    }
  }

  @override
  Future<bool> markAsCompleted(String activityId) async {
    try {
      final supabase = _ref.read(supabaseClientProvider);
      final user = _ref.read(currentUserProvider).valueOrNull;

      if (user == null) {
        return false;
      }

      // Record activity completion
      await supabase.from('activity_completions').insert({
        'user_id': user.id,
        'activity_id': activityId,
        'completed_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error marking activity as completed: $e');
      return false;
    }
  }

  @override
  Future<void> refreshActivities() async {
    try {
      // The correct pattern for refreshing providers
      _ref.invalidate(activitiesProvider);
      // Wait for the invalidated provider to complete loading
      await _ref.read(activitiesProvider.future);
    } catch (e) {
      print('Error refreshing activities: $e');
    }
  }

  @override
  Future<void> refreshActivitiesByCategory(String categoryId) async {
    try {
      // The correct pattern for refreshing providers
      _ref.invalidate(activitiesByCategoryProvider(categoryId));
      // Wait for the invalidated provider to complete loading
      await _ref.read(activitiesByCategoryProvider(categoryId).future);
    } catch (e) {
      print('Error refreshing activities by category: $e');
    }
  }

  @override
  Future<void> refreshCategories() async {
    try {
      // The correct pattern for refreshing providers
      _ref.invalidate(categoriesProvider);
      // Wait for the invalidated provider to complete loading
      await _ref.read(categoriesProvider.future);
    } catch (e) {
      print('Error refreshing categories: $e');
    }
  }
}

/// Provider for the ActivityService
final activityServiceProvider = Provider<ActivityService>((ref) {
  return ActivityServiceImpl(ref);
});

/// Provider for featured activities
final featuredActivitiesProvider = FutureProvider<List<Activity>>((ref) async {
  final activityService = ref.watch(activityServiceProvider);
  return activityService.getFeaturedActivities();
});

/// Provider for recommended activities
final recommendedActivitiesProvider = FutureProvider<List<Activity>>((
  ref,
) async {
  final activityService = ref.watch(activityServiceProvider);
  return activityService.getRecommendedActivities();
});

/// Provider for recent activities
final recentActivitiesProvider = FutureProvider<List<Activity>>((ref) async {
  final activityService = ref.watch(activityServiceProvider);
  return activityService.getRecentActivities();
});

// For backward compatibility
// Legacy name alias for activities service
final activitiesServiceProvider = Provider<ActivityService>((ref) {
  return ref.watch(activityServiceProvider);
});
