import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../../../../models/user.dart';
import '../../../../../services/providers.dart';

/// ProfileService defines the interface for all user profile-related operations
abstract class ProfileService {
  /// Get the current user's profile
  Future<User?> getCurrentUserProfile();

  /// Get a user profile by ID
  Future<User?> getUserProfileById(String userId);

  /// Update the current user's profile information
  Future<User?> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? shortDescription,
    String? title,
  });

  /// Update user's profile image
  Future<String?> updateProfileImage(File imageFile);

  /// Delete user's profile image
  Future<bool> deleteProfileImage();

  /// Get user preferences
  Future<Map<String, dynamic>> getUserPreferences();

  /// Update user preferences
  Future<bool> updateUserPreferences(Map<String, dynamic> preferences);

  /// Update user email
  Future<bool> updateEmail(String newEmail, String password);

  /// Update user password
  Future<bool> updatePassword(String currentPassword, String newPassword);

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStatistics();
}

/// ProfileServiceImpl implements the ProfileService interface
class ProfileServiceImpl implements ProfileService {
  final Ref _ref;

  ProfileServiceImpl(this._ref);

  @override
  Future<User?> getCurrentUserProfile() async {
    try {
      // Return the current user from the provider
      final user = _ref.read(currentUserProvider).valueOrNull;
      return user;
    } catch (e) {
      print('Error getting current user profile: $e');
      return null;
    }
  }

  @override
  Future<User?> getUserProfileById(String userId) async {
    try {
      final supabase = _ref.read(supabaseClientProvider);

      final response =
          await supabase.from('profiles').select().eq('id', userId).single();

      return User.fromJson(response);
    } catch (e) {
      print('Error getting user profile by ID: $e');
      return null;
    }
  }

  @override
  Future<User?> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? shortDescription,
    String? title,
  }) async {
    try {
      final supabase = _ref.read(supabaseClientProvider);
      final currentUser = _ref.read(currentUserProvider).valueOrNull;

      if (currentUser == null) {
        return null;
      }

      final updateData = <String, dynamic>{};

      if (displayName != null) updateData['display_name'] = displayName;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
      if (shortDescription != null)
        updateData['short_description'] = shortDescription;
      if (title != null) updateData['title'] = title;

      // Return early if no updates to make
      if (updateData.isEmpty) {
        return currentUser;
      }

      final response =
          await supabase
              .from('profiles')
              .update(updateData)
              .eq('id', currentUser.id)
              .select()
              .single();

      // Refresh the current user provider
      _ref.invalidate(currentUserProvider);

      return User.fromJson(response);
    } catch (e) {
      print('Error updating profile: $e');
      return null;
    }
  }

  @override
  Future<String?> updateProfileImage(File imageFile) async {
    try {
      final supabase = _ref.read(supabaseClientProvider);
      final currentUser = _ref.read(currentUserProvider).valueOrNull;

      if (currentUser == null) {
        return null;
      }

      // Generate a unique file path for the image
      final fileExt = imageFile.path.split('.').last;
      final fileName =
          'profile_${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'profiles/${currentUser.id}/$fileName';

      // Upload the image to storage
      await supabase.storage.from('user_assets').upload(filePath, imageFile);

      // Get the public URL
      final imageUrl = supabase.storage
          .from('user_assets')
          .getPublicUrl(filePath);

      // Update the user's profile with the new image URL
      await supabase
          .from('profiles')
          .update({'profile_image_url': imageUrl})
          .eq('id', currentUser.id);

      // Refresh the current user provider
      _ref.invalidate(currentUserProvider);

      return imageUrl;
    } catch (e) {
      print('Error updating profile image: $e');
      return null;
    }
  }

  @override
  Future<bool> deleteProfileImage() async {
    try {
      final supabase = _ref.read(supabaseClientProvider);
      final currentUser = _ref.read(currentUserProvider).valueOrNull;

      if (currentUser == null) {
        return false;
      }

      // Update the user's profile to remove the image URL
      await supabase
          .from('profiles')
          .update({'profile_image_url': null})
          .eq('id', currentUser.id);

      // If the current user has a profile image URL, delete the file
      if (currentUser.profileImageUrl != null) {
        // Extract the file path from the URL
        final uri = Uri.parse(currentUser.profileImageUrl!);
        final pathSegments = uri.pathSegments;

        // The file path should be the last segments after the bucket name
        if (pathSegments.length > 2) {
          final filePath = pathSegments.sublist(2).join('/');

          // Delete the file from storage
          await supabase.storage.from('user_assets').remove([filePath]);
        }
      }

      // Refresh the current user provider
      _ref.invalidate(currentUserProvider);

      return true;
    } catch (e) {
      print('Error deleting profile image: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      final supabase = _ref.read(supabaseClientProvider);
      final currentUser = _ref.read(currentUserProvider).valueOrNull;

      if (currentUser == null) {
        return {};
      }

      final response =
          await supabase
              .from('user_preferences')
              .select()
              .eq('user_id', currentUser.id)
              .single();

      return response['preferences'] ?? {};
    } catch (e) {
      print('Error getting user preferences: $e');
      return {};
    }
  }

  @override
  Future<bool> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final supabase = _ref.read(supabaseClientProvider);
      final currentUser = _ref.read(currentUserProvider).valueOrNull;

      if (currentUser == null) {
        return false;
      }

      // Check if preferences exist for the user
      final existingPrefs =
          await supabase
              .from('user_preferences')
              .select()
              .eq('user_id', currentUser.id)
              .maybeSingle();

      if (existingPrefs == null) {
        // Create new preferences
        await supabase.from('user_preferences').insert({
          'user_id': currentUser.id,
          'preferences': preferences,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } else {
        // Update existing preferences
        await supabase
            .from('user_preferences')
            .update({
              'preferences': preferences,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', currentUser.id);
      }

      return true;
    } catch (e) {
      print('Error updating user preferences: $e');
      return false;
    }
  }

  @override
  Future<bool> updateEmail(String newEmail, String password) async {
    try {
      final supabase = _ref.read(supabaseClientProvider);

      // Update email in the auth system using the correct API
      final response = await supabase.auth.updateUser(
        UserAttributes(email: newEmail),
      );

      if (response.user != null) {
        // Refresh the current user provider
        _ref.invalidate(currentUserProvider);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating email: $e');
      return false;
    }
  }

  @override
  Future<bool> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final supabase = _ref.read(supabaseClientProvider);

      // Update password in the auth system using the correct API
      final response = await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return response.user != null;
    } catch (e) {
      print('Error updating password: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final supabase = _ref.read(supabaseClientProvider);
      final currentUser = _ref.read(currentUserProvider).valueOrNull;

      if (currentUser == null) {
        return {};
      }

      // Fetch various user statistics

      // 1. Count completed activities
      final completedActivitiesResponse = await supabase
          .from('activity_completions')
          .select('id')
          .eq('user_id', currentUser.id);
      final completedActivitiesCount = completedActivitiesResponse.length;

      // 2. Count created resbites
      final createdResbitesResponse = await supabase
          .from('resbites')
          .select('id')
          .eq('user_id', currentUser.id);
      final createdResbitesCount = createdResbitesResponse.length;

      // 3. Count friends
      final friendsResponse = await supabase
          .from('friends')
          .select('id')
          .eq('user_id', currentUser.id);
      final friendsCount = friendsResponse.length;

      // 4. Count circles
      final circlesQuery = await supabase
          .from('circles')
          .select('id, member_ids')
          .contains('member_ids', [currentUser.id]);

      final circlesCount = circlesQuery.length;

      return {
        'completed_activities_count': completedActivitiesCount,
        'created_resbites_count': createdResbitesCount,
        'friends_count': friendsCount,
        'circles_count': circlesCount,
        'account_age_days':
            currentUser.createdAt != null
                ? DateTime.now().difference(currentUser.createdAt!).inDays
                : 0,
        'last_active':
            currentUser.lastActive?.toIso8601String() ??
            DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error getting user statistics: $e');
      return {};
    }
  }
}

/// Provider for the ProfileService
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileServiceImpl(ref);
});

/// Provider for current user profile
final currentUserProfileProvider = FutureProvider<User?>((ref) async {
  final profileService = ref.watch(profileServiceProvider);
  return profileService.getCurrentUserProfile();
});

/// Provider for user preferences
final userPreferencesProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final profileService = ref.watch(profileServiceProvider);
  return profileService.getUserPreferences();
});

/// Provider for user statistics
final userStatisticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final profileService = ref.watch(profileServiceProvider);
  return profileService.getUserStatistics();
});
