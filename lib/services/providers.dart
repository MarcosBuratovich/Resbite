// providers.dart - Centralized provider definitions to avoid circular dependencies
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/notification.dart';

// NOTE: Modular services should be imported directly in files that need them

import '../config/constants.dart';
import '../models/user.dart';
import '../models/activity.dart';
import '../models/category.dart';
import '../models/resbite.dart';
import '../models/resbite_filter.dart';
import 'auth_service.dart';
import 'database_service.dart';
import 'contact_service.dart';
import 'notification_service.dart';
import 'user_db_service.dart';
import 'user_profile_service.dart';
import 'category_service.dart';
import 'activity_service.dart';
import 'resbite_service.dart';
// friend_service.dart was removed in the modular refactoring

// Re-export AuthStatus enum for use in other files
export 'auth_service.dart' show AuthStatus;
export 'storage_service.dart' show storageServiceProvider;

// Core service providers
final authServiceProvider = Provider<AuthService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider); // Get Supabase client
  return AuthService(supabaseClient);
});
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  // Pass the ref to the DatabaseService constructor
  return DatabaseService(ref: ref, supabase: supabaseClient);
});

// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Current user ID provider - convenient way to access the current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(supabaseClientProvider).auth.currentUser?.id;
});

// Auth providers
final authStatusProvider = StreamProvider<AuthStatus>((ref) {
  final authService = ref.watch(authServiceProvider);
  // First emit the current status immediately
  final initialStatus = authService.status;

  // Then check periodically until we get a non-uninitialized status
  return Stream<AuthStatus>.fromIterable([initialStatus]).asyncExpand((_) {
    if (initialStatus != AuthStatus.uninitialized) {
      return Stream.value(initialStatus);
    }
    return Stream.periodic(
      const Duration(seconds: 1),
      (_) => authService.status,
    ).where((status) => status != AuthStatus.uninitialized).take(1);
  });
});

final currentUserProvider = StreamProvider<User?>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);

  return supabaseClient.auth.onAuthStateChange
      .map<User?>((AuthState authState) { // Explicitly type AuthState and return User?
    final event = authState.event;
    if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.userUpdated) {
      final supabaseUser = authState.session?.user;
      return supabaseUser != null ? User.fromSupabaseUser(supabaseUser) : null;
    } else if (event == AuthChangeEvent.signedOut) {
      return null;
    }
    // For other events, reflect the current Supabase user state
    final currentSupabaseUser = supabaseClient.auth.currentUser;
    return currentSupabaseUser != null ? User.fromSupabaseUser(currentSupabaseUser) : null;
  })
  .distinct(); // Use distinct to avoid unnecessary rebuilds if user object hasn't changed meaningfully
});

// Contact service provider
final contactServiceProvider = Provider<ContactService>((ref) {
  return ContactService(ref);
});

// Notifications list provider
final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  final service = ref.watch(notificationServiceProvider);
  return service.getNotifications(userId);
});

// Unread notification count
final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final list = await ref.watch(notificationsProvider.future);
  return list.where((n) => n.readAt == null).length;
});

// UserDB service provider
final userDbServiceProvider = Provider<UserDBService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return UserDBService(supabase: supabaseClient);
});

// UserProfile service provider
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return UserProfileService(supabaseClient);
});

// Category service provider
final categoryServiceProvider = Provider<CategoryService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return CategoryService(supabase: supabaseClient);
});

// Activity service provider
final activityServiceProvider = Provider<ActivityService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return ActivityService(supabase: supabaseClient);
});

// Resbite service provider
final resbiteServiceProvider = Provider<ResbiteService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return ResbiteService(supabase: supabaseClient, ref: ref);
});

// Contact-related data providers
final contactsProvider = FutureProvider<List<PhoneContact>>((ref) async {
  final contactService = ref.watch(contactServiceProvider);
  return await contactService.getContacts();
});

// Contacts on device with Resbite flag (includes users and non-users)
final resbiteContactsProvider = FutureProvider<List<PhoneContact>>((ref) async {
  final contactService = ref.watch(contactServiceProvider);
  // Fetch all contacts and mark those with Resbite accounts
  return await contactService.getContactsWithUsers();
});

// Categories provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  // TODO: Update this to use categoryServiceProvider once call sites are updated
  return ref.watch(categoryServiceProvider).getCategories(); // Temporary direct use, will be updated
});

// Activities providers
final activitiesProvider = FutureProvider<List<Activity>>((ref) async {
  // final databaseService = ref.watch(databaseServiceProvider);
  // return databaseService.getActivities(limit: AppConstants.paginationLimit);
  // TODO: Implement proper pagination if needed, for now, get all activities from ActivityService
  return ref.watch(activityServiceProvider).getActivities(limit: AppConstants.paginationLimit);
});

final activitiesByCategoryProvider = FutureProvider.family<List<Activity>, String>((ref, categoryId) async {
  // TODO: Update this to use categoryServiceProvider once call sites are updated
  return await ref.watch(categoryServiceProvider).getActivitiesByCategory(categoryId); // Temporary direct use, will be updated
});

final activityProvider = FutureProvider.family<Activity?, String>((
  ref,
  activityId,
) async {
  // final databaseService = ref.watch(databaseServiceProvider);
  // return databaseService.getActivity(activityId);
  return ref.watch(activityServiceProvider).getActivity(activityId);
});

// Resbites providers
final resbitesProvider = FutureProvider.family<List<Resbite>, ResbiteFilter>((ref, filter) async {
  // final databaseService = ref.watch(databaseServiceProvider);
  // return databaseService.getResbites(
  //   upcoming: filter.upcoming,
  //   userId: filter.userId,
  // );
  return ref.watch(resbiteServiceProvider).getResbites(
    upcoming: filter.upcoming,
    userId: filter.userId,
    limit: filter.limit,
    offset: filter.offset,
  );
});

final resbiteDetailProvider = FutureProvider.family<Resbite?, String>((
  ref,
  resbiteId,
) async {
  // final databaseService = ref.watch(databaseServiceProvider);
  // return databaseService.getResbite(resbiteId);
  return ref.watch(resbiteServiceProvider).getResbite(resbiteId);
});

// Theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
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
