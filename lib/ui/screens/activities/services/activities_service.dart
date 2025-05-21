import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../models/activity.dart';
import '../../../../../models/category.dart';
import '../../../../../services/providers.dart';

/// ActivitiesService handles all business logic related to activities
/// including data fetching, filtering, and manipulation
class ActivitiesService {
  final Ref ref;

  const ActivitiesService(this.ref);

  /// Fetch all activities
  Future<List<Activity>> getActivities() async {
    return await ref.read(activitiesProvider.future);
  }

  /// Fetch activities by category
  Future<List<Activity>> getActivitiesByCategory(String categoryId) async {
    return await ref.read(activitiesByCategoryProvider(categoryId).future);
  }

  /// Refresh all activities data
  Future<void> refreshActivities() async {
    // The correct pattern for refreshing providers
    ref.invalidate(activitiesProvider);
    // Wait for the invalidated provider to complete loading
    await ref.read(activitiesProvider.future);
  }

  /// Refresh activities for a specific category
  Future<void> refreshActivitiesByCategory(String categoryId) async {
    // The correct pattern for refreshing providers
    ref.invalidate(activitiesByCategoryProvider(categoryId));
    // Wait for the invalidated provider to complete loading
    await ref.read(activitiesByCategoryProvider(categoryId).future);
  }

  /// Fetch all categories
  Future<List<Category>> getCategories() async {
    return await ref.read(categoriesProvider.future);
  }

  /// Refresh categories data
  Future<void> refreshCategories() async {
    // The correct pattern for refreshing providers
    ref.invalidate(categoriesProvider);
    // Wait for the invalidated provider to complete loading
    await ref.read(categoriesProvider.future);
  }
}

/// Provider for the ActivitiesService
final activitiesServiceProvider = Provider<ActivitiesService>((ref) {
  return ActivitiesService(ref);
});
