import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/activity.dart';
import '../models/category.dart';
import '../utils/logger.dart';

class ActivityService {
  final SupabaseClient _supabase;

  ActivityService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  // Helper method to fetch categories for a specific activity_id
  Future<List<Category>> _getCategoriesForActivity(String activityId) async {
    try {
      final categoriesResponse = await _supabase
          .from('activities_to_categories')
          .select('category:activities_categories(*)')
          .eq('activity_id', activityId);

      final List<Category> categories = [];
      for (final item in categoriesResponse) {
        if (item['category'] != null) {
          categories.add(Category.fromSupabase(item['category']));
        }
      }
      return categories;
    } catch (e, stack) {
      AppLogger.error('Failed to get categories for activity $activityId', e, stack);
      return [];
    }
  }

  // Get activities
  Future<List<Activity>> getActivities({int limit = 20, int offset = 0}) async {
    try {
      final response = await _supabase
          .from('activities')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final List<Activity> activities = [];
      for (final json in response) {
        try {
          if (json['id'] == null) {
            AppLogger.error('Activity ID is null in getActivities response', null, null);
            continue;
          }
          final List<Category> categories = await _getCategoriesForActivity(json['id']);
          activities.add(Activity.fromSupabase(json, categories));
        } catch (activityError, activityStack) {
          AppLogger.error(
            'Error processing individual activity in getActivities',
            activityError,
            activityStack,
          );
          // Continue with next activity instead of failing the whole operation
        }
      }
      return activities;
    } catch (e, stack) {
      AppLogger.error('Failed to get activities', e, stack);
      return [];
    }
  }

  // Get activity details
  Future<Activity?> getActivity(String activityId) async {
    try {
      final response =
          await _supabase
              .from('activities')
              .select()
              .eq('id', activityId)
              .maybeSingle();

      if (response == null) return null;

      final List<Category> categories = await _getCategoriesForActivity(activityId);
      
      // Changed from AppLogger.error to AppLogger.info as it's a success message
      AppLogger.info(
        'Activity retrieved successfully: ${response['title']}',
        null,
        null,
      );
      return Activity.fromSupabase(response, categories);
    } catch (e, stack) {
      AppLogger.error('Failed to get activity $activityId', e, stack);
      return null;
    }
  }
}
