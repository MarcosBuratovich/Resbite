import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/activity.dart';
import '../models/category.dart';
import '../utils/logger.dart';

class CategoryService {
  final SupabaseClient _supabase;

  CategoryService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  // Get categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _supabase
          .from('activities_categories')
          .select()
          .order('display_order', ascending: true);

      return response.map((json) => Category.fromSupabase(json)).toList();
    } catch (e, stack) {
      AppLogger.error('Failed to get categories', e, stack);
      return [];
    }
  }

  // Get activities by category
  Future<List<Activity>> getActivitiesByCategory(
    String categoryId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('activities_to_categories')
          .select('activity:activities(*)')
          .eq('category_id', categoryId)
          .range(offset, offset + limit - 1);

      // Get activities with categories
      final List<Activity> activities = [];

      for (final item in response) {
        // Skip if activity is null
        if (item['activity'] == null) {
          AppLogger.error(
            'Activity is null in activities_to_categories response',
            null,
            null,
          );
          continue;
        }

        try {
          // Get all categories for this activity
          final activityId = item['activity']['id'];
          if (activityId == null) {
            AppLogger.error('Activity ID is null', null, null);
            continue;
          }

          final categoriesResponse = await _supabase
              .from('activities_to_categories')
              .select('category:activities_categories(*)')
              .eq('activity_id', activityId);

          final List<Category> categories = [];
          for (final catItem in categoriesResponse) {
            if (catItem['category'] != null) {
              categories.add(Category.fromSupabase(catItem['category']));
            }
          }

          // Create activity with categories
          activities.add(Activity.fromSupabase(item['activity'], categories));
        } catch (activityError, activityStack) {
          AppLogger.error(
            'Error processing activity in category',
            activityError,
            activityStack,
          );
          // Continue with next activity instead of failing the whole operation
        }
      }

      return activities;
    } catch (e, stack) {
      AppLogger.error('Failed to get activities by category', e, stack);
      return [];
    }
  }
}
