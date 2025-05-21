import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // Removed unused import

import '../models/user.dart' as app_user;
import '../utils/logger.dart';

class UserDBService {
  final SupabaseClient _supabase;

  UserDBService({required SupabaseClient supabase}) : _supabase = supabase;

  // ======== USERS ======== - Methods for creating and finding users

  // Create user
  Future<void> createUser(app_user.User user) async {
    try {
      // Use RPC call to bypass Row-Level Security policies
      // This requires a stored procedure in Supabase that can insert users
      await _supabase.rpc(
        'create_user',
        params: {
          'p_id': user.id, // TEXT column
          'p_email': user.email,
          'p_display_name': user.displayName ?? '',
          'p_phone_number': user.phoneNumber ?? '',
          'p_profile_image_url': user.profileImageUrl ?? '',
          'p_short_description': user.shortDescription ?? '',
          'p_role': user.role,
          'p_title': user.title ?? '',
          // 'p_date_of_birth' removed: DB/function doesn't support this param
        },
      );
      AppLogger.info('User created successfully via RPC');
    } catch (e, stack) {
      AppLogger.error('Failed to create user via RPC', e, stack);

      // Código de manejo de error existente
      try {
        // Intento de fallback...
        final Map<String, dynamic> userData = {
          'id': user.id, // Now using primary key column
          'email': user.email,
          'display_name': user.displayName,
          'phone_number': user.phoneNumber,
          'profile_image_url': user.profileImageUrl,
          'short_description': user.shortDescription,
          'role': user.role,
          'title': user.title,
          // 'date_of_birth' removed: users table has no such column
          // Supabase automatically handles created_at and updated_at if defined with defaults
        };

        // Remove null values to avoid errors if columns don't have defaults for null
        userData.removeWhere((key, value) => value == null);

        await _supabase.from('users').insert(userData);
        AppLogger.info(
          'User created successfully via direct insert fallback: ${user.email}',
        );
      } catch (sqlError, sqlStack) {
        AppLogger.error(
          'Fallback direct insert also failed for user ${user.email}',
          sqlError,
          sqlStack,
        );
        rethrow; // Rethrow the original error if fallback also fails
      }
    }
  }

  // Create user profile (adapter method for RegisterService)
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required String displayName,
    required DateTime dateOfBirth,
    String? phoneNumber,
    String? bio,
    String? location,
    List<String>? interests,
  }) async {
    try {
      // Convert user data to a map for insertion for RPC call
      final rpcParams = {
        'p_id': uid,
        'p_email': email,
        'p_display_name': displayName,
        'p_phone_number': phoneNumber ?? '',
        'p_short_description': bio ?? '',
        'p_role': 'user',
      };

      // Try to create user via RPC first
      await _createUserViaRPC(rpcParams);

      // If RPC didn't throw, create user succeeded
      AppLogger.info('User profile created successfully: $displayName');
    } catch (e, stack) {
      AppLogger.error('Failed to create user profile', e, stack);
      // Fallback to standard method
      try {
        // Create user directly using the createUser method
        final user = app_user.User(
          id: uid,
          email: email,
          displayName: displayName,
          phoneNumber: phoneNumber,
          shortDescription: bio, // Mapped from bio
          role: 'user', // Default role
        );

        await createUser(user);
        AppLogger.info(
          'User profile created successfully via fallback: $displayName',
        );
      } catch (fallbackError, fallbackStack) {
        AppLogger.error(
          'Fallback creation also failed',
          fallbackError,
          fallbackStack,
        );
        rethrow;
      }
    }
  }

  // Method to create a user via RPC
  Future<void> _createUserViaRPC(Map<String, dynamic> userData) async {
    try {
      // Try to create the user via RPC first
      await _supabase.rpc('create_user', params: userData);
    } catch (e, stack) {
      AppLogger.error('Failed to create user via RPC', e, stack);

      // If RPC fails, attempt a direct insert as a fallback
      // This part needs to map p_id to id, etc.
      // And handle potential missing fields if userData comes from different sources.
      final Map<String, dynamic> directInsertData = {
        'id': userData['p_id'],
        'email': userData['p_email'],
        'display_name': userData['p_display_name'],
        'phone_number': userData['p_phone_number'],
        'short_description': userData['p_short_description'],
        'role': userData['p_role'] ?? 'user', // Default role if not provided
      };
      directInsertData.removeWhere((key, value) => value == null);

      try {
        await _supabase.from('users').insert(directInsertData);
        AppLogger.info(
          'User created successfully via direct insert fallback after RPC fail: ${directInsertData['email']}',
        );
      } catch (sqlError, sqlStack) {
        AppLogger.error(
          'Fallback direct insert also failed after RPC fail for user ${directInsertData['email']}',
          sqlError,
          sqlStack,
        );
        rethrow; // Rethrow the original RPC error
      }
    }
  }

  // Update user
  Future<void> updateUser(app_user.User user) async {
    try {
      // Use RPC call to bypass Row-Level Security policies
      // This requires a stored procedure in Supabase
      await _supabase.rpc(
        'update_user',
        params: {
          'p_id': user.id, // Now using TEXT column
          'p_email': user.email,
          'p_display_name': user.displayName ?? '',
          'p_phone_number': user.phoneNumber ?? '',
          'p_profile_image_url': user.profileImageUrl ?? '',
          'p_short_description': user.shortDescription ?? '',
          'p_role': user.role,
          'p_title': user.title ?? '',
        },
      );
      AppLogger.info('User updated successfully via RPC');
    } catch (e, stack) {
      AppLogger.error('Failed to update user via RPC', e, stack);

      try {
        // Try alternative direct update as fallback
        await _supabase
            .from('users')
            .update({
              'email': user.email,
              'display_name': user.displayName,
              'phone_number': user.phoneNumber,
              'profile_image_url': user.profileImageUrl,
              'short_description': user.shortDescription,
              'role': user.role,
              'title': user.title,
              'last_active':
                  user.lastActive?.toIso8601String() ??
                  DateTime.now().toIso8601String(),
            })
            .eq('id', user.id); // Querying by id (primary key)
        AppLogger.info(
          'User updated successfully via direct update',
          null,
          null,
        );
      } catch (updateError, updateStack) {
        AppLogger.error('Failed to update user', updateError, updateStack);
        // Do not rethrow to prevent app crash
      }
    }
  }

  // Update specific user data fields
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      if (userId.isEmpty || data.isEmpty) {
        AppLogger.error(
          'Failed to update user data: userId is empty or no data provided',
          null,
          null,
        );
        return;
      }

      // Add last_active field
      data['last_active'] = DateTime.now().toIso8601String();

      // Try direct update
      await _supabase.from('users').update(data).eq('id', userId);

      AppLogger.info('User data updated successfully', null);
    } catch (e, stack) {
      AppLogger.error('Failed to update user data', e, stack);
      // Don't rethrow to prevent app crash
    }
  }

  // Update user last active
  Future<void> updateUserLastActive(String userId) async {
    try {
      // Use RPC call to bypass Row-Level Security policies
      await _supabase.rpc(
        'update_user_last_active',
        params: {
          'p_id': userId, // Now using TEXT column
        },
      );
      AppLogger.info(
        'User last active updated successfully via RPC',
        null,
        null,
      );
    } catch (e) {
      try {
        // Try direct update as fallback
        await _supabase
            .from('users')
            .update({'last_active': DateTime.now().toIso8601String()})
            .eq('id', userId); // Querying by id (primary key)
        AppLogger.info(
          'User last active updated successfully via direct update',
          null,
          null,
        );
      } catch (updateError, updateStack) {
        AppLogger.error(
          'Failed to update user last active',
          updateError,
          updateStack,
        );
        // Don't rethrow - this is a non-critical operation
      }
    }
  }

  // Find users by email or phone numbers
  Future<List<app_user.User>> findUsersByContactInfo({
    required List<String> emails,
    required List<String> phones,
  }) async {
    try {
      if (emails.isEmpty && phones.isEmpty) {
        AppLogger.error(
          'No emails or phones provided to findUsersByContactInfo',
          null,
          null,
        );
        return [];
      }

      final List<app_user.User> matchedUsers = [];

      // Find users by email
      if (emails.isNotEmpty) {
        try {
          // We need to run multiple queries if there are many emails
          // Supabase in() operator has limits on number of items
          const int batchSize = 50;
          for (int i = 0; i < emails.length; i += batchSize) {
            final int end =
                (i + batchSize < emails.length) ? i + batchSize : emails.length;
            final List<String> batch = emails.sublist(i, end);

            // Convert to list of JSON
            final emailsJson = batch.map((e) => e).toList();

            // Use filter instead of in_ operator
            final response = await _supabase
                .from('users')
                .select()
                .filter('email', 'in', emailsJson);

            for (final user in response) {
              try {
                matchedUsers.add(app_user.User.fromSupabase(user));
              } catch (parseError, parseStack) {
                AppLogger.error(
                  'Error parsing user from email lookup',
                  parseError,
                  parseStack,
                );
                // Continue with next user
              }
            }
          }
        } catch (emailError, emailStack) {
          AppLogger.error(
            'Error finding users by email',
            emailError,
            emailStack,
          );
          // Continue with phone lookup
        }
      }

      // Find users by phone number
      if (phones.isNotEmpty) {
        try {
          // We need to run multiple queries if there are many phone numbers
          const int batchSize = 50;
          for (int i = 0; i < phones.length; i += batchSize) {
            final int end =
                (i + batchSize < phones.length) ? i + batchSize : phones.length;
            final List<String> batch = phones.sublist(i, end);

            // Convert to list of JSON
            final phonesJson = batch.map((e) => e).toList();

            // Use filter instead of in_ operator
            final response = await _supabase
                .from('users')
                .select()
                .filter('phone_number', 'in', phonesJson);

            for (final user in response) {
              try {
                final newUser = app_user.User.fromSupabase(user);

                // Check if user is already in matchedUsers list
                final isDuplicate = matchedUsers.any((u) => u.id == newUser.id);
                if (!isDuplicate) {
                  matchedUsers.add(newUser);
                }
              } catch (parseError, parseStack) {
                AppLogger.error(
                  'Error parsing user from phone lookup',
                  parseError,
                  parseStack,
                );
                // Continue with next user
              }
            }
          }
        } catch (phoneError, phoneStack) {
          AppLogger.error(
            'Error finding users by phone',
            phoneError,
            phoneStack,
          );
          // Continue with return
        }
      }

      AppLogger.info('Found ${matchedUsers.length} users by contact info');
      return matchedUsers;
    } catch (e, stack) {
      AppLogger.error('Failed to find users by contact info', e, stack);
      return [];
    }
  }
}
