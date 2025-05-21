import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user.dart' as app_user;
import '../utils/logger.dart';
import 'providers.dart'; // For supabaseClientProvider

class UserProfileService {
  final SupabaseClient _supabase;

  UserProfileService(this._supabase);

  // Get user by id
  Future<app_user.User?> getUser(String id) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', id) // Querying by id (primary key)
          .maybeSingle();

      if (response == null) return null;

      return app_user.User.fromSupabase(response);
    } catch (e, stack) {
      AppLogger.error('Failed to get user by id: $id', e, stack);
      return null;
    }
  }

  // Update user profile by user.id (primary key)
  Future<void> updateUserProfile({
    required String userId, // This is the user.id (PK)
    required Map<String, dynamic> data,
  }) async {
    try {
      await _supabase.from('users').update(data).eq('id', userId); // Querying by id (PK)
      AppLogger.info('User profile updated successfully for user: $userId');
    } catch (e, stack) {
      AppLogger.error('Failed to update user profile for user: $userId', e, stack);
      rethrow;
    }
  }

  // Upload profile image
  Future<String?> uploadProfileImage({
    required String userId, // This is the user.id (PK) for storage path
    required dynamic imageFile,
  }) async {
    try {
      File file;
      if (imageFile is File) {
        file = imageFile;
      } else if (imageFile is XFile) {
        file = File(imageFile.path);
      } else {
        AppLogger.warning('uploadProfileImage: imageFile is not File or XFile, it is ${imageFile.runtimeType}');
        throw ArgumentError('imageFile must be a File or XFile');
      }

      final filename = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
      final storagePath = 'profiles/$userId/$filename'; // Using userId (PK) in path

      await _supabase.storage.from('user_images').upload(storagePath, file);

      final imageUrl = _supabase.storage.from('user_images').getPublicUrl(storagePath);

      AppLogger.info('Profile image uploaded successfully: $imageUrl for user $userId');
      return imageUrl;
    } catch (e, stack) {
      AppLogger.error('Failed to upload profile image for user $userId', e, stack);
      return null;
    }
  }
}

final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return UserProfileService(supabaseClient);
});
