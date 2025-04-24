// providers.dart - Centralized provider definitions to avoid circular dependencies
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';
import '../models/user.dart';
import '../models/activity.dart';
import '../models/category.dart';
import '../models/resbite.dart';
import 'auth_service.dart';
import 'database_service.dart';
import 'contact_service.dart';
import 'friend_service.dart';

// Re-export AuthStatus enum for use in other files
export 'auth_service.dart' show AuthStatus;
export 'storage_service.dart' show storageServiceProvider;

// Core service providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService());

// Auth providers
final authStatusProvider = StreamProvider<AuthStatus>((ref) {
  final authService = ref.watch(authServiceProvider);
  // First emit the current status immediately
  final initialStatus = authService.status;
  
  // Then check periodically until we get a non-uninitialized status
  return Stream<AuthStatus>.fromIterable([initialStatus])
    .asyncExpand((_) {
      if (initialStatus != AuthStatus.uninitialized) {
        return Stream.value(initialStatus);
      }
      return Stream.periodic(const Duration(seconds: 1), (_) => authService.status)
        .where((status) => status != AuthStatus.uninitialized)
        .take(1);
    });
});

final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  final initialUser = authService.currentUser;
  
  return Stream<User?>.value(initialUser)
    .asyncExpand((_) {
      return authService.authStateChanges.map((_) => authService.currentUser);
    });
});

// Contact service provider
final contactServiceProvider = Provider<ContactService>((ref) {
  return ContactService(ref);
});

// Friend service provider
final friendServiceProvider = Provider<FriendService>((ref) {
  return FriendService(ref);
});

// Friend-related data providers
final directFriendsProvider = FutureProvider<List<dynamic>>((ref) async {
  final friendService = ref.watch(friendServiceProvider);
  return await friendService.getDirectFriends();
});

final extendedNetworkProvider = FutureProvider<List<dynamic>>((ref) async {
  final friendService = ref.watch(friendServiceProvider);
  return await friendService.getExtendedNetwork();
});

final friendCirclesProvider = FutureProvider<List<dynamic>>((ref) async {
  final friendService = ref.watch(friendServiceProvider);
  return await friendService.getFriendCircles();
});

final pendingInvitationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final friendService = ref.watch(friendServiceProvider);
  return await friendService.getPendingInvitations();
});

final friendCircleProvider = FutureProvider.family<dynamic, String>((ref, circleId) async {
  final friendService = ref.watch(friendServiceProvider);
  return await friendService.getFriendCircleById(circleId);
});

// Contact-related data providers
final contactsProvider = FutureProvider<List<PhoneContact>>((ref) async {
  final contactService = ref.watch(contactServiceProvider);
  return await contactService.getContacts();
});

final resbiteContactsProvider = FutureProvider<List<PhoneContact>>((ref) async {
  final contactService = ref.watch(contactServiceProvider);
  final contacts = await contactService.getContacts();
  return contacts.where((contact) => contact.isResbiteUser).toList();
});

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