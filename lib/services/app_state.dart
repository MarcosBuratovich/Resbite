import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';
// import '../models/category.dart'; // Removed unused import
// import '../models/resbite.dart'; // Import no longer needed as all Resbite providers are in providers.dart
// import 'providers.dart'; // Import no longer needed as all relevant providers are in providers.dart

// All providers moved to providers.dart

// Auth providers moved to providers.dart

// Current user provider moved to providers.dart

// Categories provider - This was moved to providers.dart
// final categoriesProvider = FutureProvider<List<Category>>((ref) async {
//   final databaseService = ref.watch(databaseServiceProvider);
//   return databaseService.getCategories();
// });

// Activities providers
// Removed to consolidate in providers.dart

// Resbites providers - This provider definition is outdated and has been removed.
// The correct provider is in providers.dart and uses ResbiteFilter.
// final resbitesProvider = FutureProvider.family<List<Resbite>, bool>((ref, upcoming) async {
//   final databaseService = ref.watch(databaseServiceProvider);
//   final authService = ref.watch(authServiceProvider);
//   final userId = authService.currentUser?.id;
  
//   return databaseService.getResbites(
//     limit: AppConstants.paginationLimit, 
//     upcoming: upcoming,
//     userId: userId,
//   );
// });

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
