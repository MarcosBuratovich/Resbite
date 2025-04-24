import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';
import '../models/activity.dart';
import '../models/category.dart';
import '../models/resbite.dart';
import 'providers.dart';

// All providers moved to providers.dart

// Auth providers moved to providers.dart

// Current user provider moved to providers.dart

// Categories provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.getCategories();
});

// Activities providers
final activitiesProvider = FutureProvider<List<Activity>>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.getActivities(limit: AppConstants.paginationLimit);
});

final activitiesByCategoryProvider = FutureProvider.family<List<Activity>, String>((ref, categoryId) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.getActivitiesByCategory(categoryId, limit: AppConstants.paginationLimit);
});

final activityProvider = FutureProvider.family<Activity?, String>((ref, activityId) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.getActivity(activityId);
});

// Resbites providers
final resbitesProvider = FutureProvider.family<List<Resbite>, bool>((ref, upcoming) async {
  final databaseService = ref.watch(databaseServiceProvider);
  final authService = ref.watch(authServiceProvider);
  final userId = authService.currentUser?.id;
  
  return databaseService.getResbites(
    limit: AppConstants.paginationLimit, 
    upcoming: upcoming,
    userId: userId,
  );
});


final resbiteProvider = FutureProvider.family<Resbite?, String>((ref, resbiteId) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.getResbite(resbiteId);
});

// Theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }
  
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(AppConstants.prefKeyThemeMode);
    
    if (themeModeString != null) {
      if (themeModeString == 'light') {
        state = ThemeMode.light;
      } else if (themeModeString == 'dark') {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.system;
      }
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.light) {
      await prefs.setString(AppConstants.prefKeyThemeMode, 'light');
    } else if (mode == ThemeMode.dark) {
      await prefs.setString(AppConstants.prefKeyThemeMode, 'dark');
    } else {
      await prefs.setString(AppConstants.prefKeyThemeMode, 'system');
    }
  }
}
