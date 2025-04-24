import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user.dart' as app_user;
import '../models/activity.dart';
import '../models/category.dart';
import '../models/place.dart';
import '../models/resbite.dart';
import '../utils/logger.dart';

class DatabaseService {
  final SupabaseClient _supabase;
  
  // Constructor
  DatabaseService({SupabaseClient? supabase}) 
      : _supabase = supabase ?? Supabase.instance.client;
  
  // ======== USERS ========
  
  // Get user
  Future<app_user.User?> getUser(String userId) async {
    try {
      final response = await _supabase
        .from('users')
        .select()
        .eq('firebase_uid', userId) // TEXT column comparison
        .maybeSingle();
      
      if (response == null) return null;
      
      return app_user.User.fromSupabase(response);
    } catch (e, stack) {
      AppLogger.error('Failed to get user', e, stack);
      return null;
    }
  }
  
  // Create user
  Future<void> createUser(app_user.User user) async {
    try {
      // Use RPC call to bypass Row-Level Security policies
      // This requires a stored procedure in Supabase that can insert users
      await _supabase.rpc('create_user', params: {
        'p_firebase_uid': user.id, // TEXT column
        'p_email': user.email,
        'p_display_name': user.displayName ?? '',
        'p_phone_number': user.phoneNumber ?? '',
        'p_profile_image_url': user.profileImageUrl ?? '',
        'p_short_description': user.shortDescription ?? '',
        'p_role': user.role,
        'p_title': user.title ?? '',
      });
      AppLogger.error('User created successfully via RPC', null, null);
    } catch (e, stack) {
      AppLogger.error('Failed to create user via RPC', e, stack);
      
      try {
        // Try using raw SQL as fallback (this can bypass RLS if the connection has permission)
        final result = await _supabase.rpc('execute_sql', params: {
          'query': '''
            INSERT INTO users(
              firebase_uid, email, display_name, phone_number, 
              profile_image_url, short_description, role, title, 
              created_at, last_active
            ) VALUES(
              '${user.id}', '${user.email}', '${user.displayName ?? ''}', 
              '${user.phoneNumber ?? ''}', '${user.profileImageUrl ?? ''}', 
              '${user.shortDescription ?? ''}', '${user.role}'::user_role, '${user.title ?? ''}',
              NOW(), NOW()
            ) RETURNING id;
          '''
        });
        
        AppLogger.error('User created successfully via SQL: $result', null, null);
      } catch (sqlError, sqlStack) {
        AppLogger.error('Failed to create user via SQL', sqlError, sqlStack);
        
        try {
          // Try direct insert as a last resort - with role cast
          await _supabase.rpc('execute_direct_insert', params: {
            'p_uid': user.id,
            'p_email': user.email,
            'p_name': user.displayName ?? '',
            'p_phone': user.phoneNumber ?? '',
            'p_image': user.profileImageUrl ?? '',
            'p_bio': user.shortDescription ?? '',
            'p_role': user.role,
            'p_title': user.title ?? ''
          });
          AppLogger.error('User created successfully via direct insert', null, null);
        } catch (insertError, insertStack) {
          AppLogger.error('Failed to create user via direct insert', insertError, insertStack);
          
          // Log the error but don't crash the app
          AppLogger.error('Working with temporary user data that is not persisted to database', e, stack);
        }
      }
    }
  }
  
  // Update user
  Future<void> updateUser(app_user.User user) async {
    try {
      // Use RPC call to bypass Row-Level Security policies
      // This requires a stored procedure in Supabase
      await _supabase.rpc('update_user', params: {
        'p_firebase_uid': user.id, // Now using TEXT column
        'p_email': user.email,
        'p_display_name': user.displayName ?? '',
        'p_phone_number': user.phoneNumber ?? '',
        'p_profile_image_url': user.profileImageUrl ?? '',
        'p_short_description': user.shortDescription ?? '',
        'p_role': user.role,
        'p_title': user.title ?? '',
      });
      AppLogger.error('User updated successfully via RPC', null, null);
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
            'last_active': user.lastActive?.toIso8601String() ?? DateTime.now().toIso8601String(),
          })
          .eq('firebase_uid', user.id); // Now using TEXT column
        AppLogger.error('User updated successfully via direct update', null, null);
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
        AppLogger.error('Failed to update user data: userId is empty or no data provided', null, null);
        return;
      }
      
      // Add last_active field
      data['last_active'] = DateTime.now().toIso8601String();
      
      // Try direct update
      await _supabase
        .from('users')
        .update(data)
        .eq('firebase_uid', userId);
      
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
      await _supabase.rpc('update_user_last_active', params: {
        'p_firebase_uid': userId, // Now using TEXT column
      });
      AppLogger.error('User last active updated successfully via RPC', null, null);
    } catch (e) {
      try {
        // Try direct update as fallback
        await _supabase
          .from('users')
          .update({
            'last_active': DateTime.now().toIso8601String(),
          })
          .eq('firebase_uid', userId); // Now using TEXT column
        AppLogger.error('User last active updated successfully via direct update', null, null);
      } catch (updateError, updateStack) {
        AppLogger.error('Failed to update user last active', updateError, updateStack);
        // Don't rethrow - this is a non-critical operation
      }
    }
  }
  
  // ======== CATEGORIES ========
  
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
  
  // ======== ACTIVITIES ========
  
  // Get activities
  Future<List<Activity>> getActivities({int limit = 20, int offset = 0}) async {
    try {
      final response = await _supabase
        .from('activities')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
      
      // Get activities with categories
      final List<Activity> activities = [];
      
      for (final json in response) {
        try {
          if (json['id'] == null) {
            AppLogger.error('Activity ID is null', null, null);
            continue;
          }
          
          // Get categories for this activity
          final categoriesResponse = await _supabase
            .from('activities_to_categories')
            .select('category:activities_categories(*)')
            .eq('activity_id', json['id']);
          
          final List<Category> categories = [];
          for (final item in categoriesResponse) {
            if (item['category'] != null) {
              categories.add(Category.fromSupabase(item['category']));
            }
          }
          
          // Create activity with categories
          activities.add(Activity.fromSupabase(json, categories));
        } catch (activityError, activityStack) {
          AppLogger.error('Error processing activity', activityError, activityStack);
          // Continue with next activity instead of failing the whole operation
        }
      }
      
      return activities;
    } catch (e, stack) {
      AppLogger.error('Failed to get activities', e, stack);
      return [];
    }
  }
  
  // Get activities by category
  Future<List<Activity>> getActivitiesByCategory(String categoryId, {int limit = 20, int offset = 0}) async {
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
          AppLogger.error('Activity is null in activities_to_categories response', null, null);
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
          AppLogger.error('Error processing activity in category', activityError, activityStack);
          // Continue with next activity instead of failing the whole operation
        }
      }
      
      return activities;
    } catch (e, stack) {
      AppLogger.error('Failed to get activities by category', e, stack);
      return [];
    }
  }
  
  // Get activity details
  Future<Activity?> getActivity(String activityId) async {
    try {
      final response = await _supabase
        .from('activities')
        .select()
        .eq('id', activityId)
        .maybeSingle();
      
      if (response == null) return null;
      
      // Get categories for this activity
      final categoriesResponse = await _supabase
        .from('activities_to_categories')
        .select('category:activities_categories(*)')
        .eq('activity_id', activityId);
      
      final List<Category> categories = [];
      for (final item in categoriesResponse) {
        if (item['category'] == null) {
          AppLogger.error('Category is null in activities_to_categories response', null, null);
          continue;
        }
        try {
          categories.add(Category.fromSupabase(item['category']));
        } catch (categoryError, categoryStack) {
          AppLogger.error('Error processing category in activity', categoryError, categoryStack);
          // Continue with next category instead of failing the whole operation
        }
      }
      
      AppLogger.error('Activity retrieved successfully: ${response['title']}', null, null);
      return Activity.fromSupabase(response, categories);
    } catch (e, stack) {
      AppLogger.error('Failed to get activity', e, stack);
      return null;
    }
  }
  
  // ======== PLACES ========
  
  // Get place
  Future<Place?> getPlace(String placeId) async {
    try {
      final response = await _supabase
        .from('places')
        .select()
        .eq('id', placeId)
        .maybeSingle();
      
      if (response == null) return null;
      
      return Place.fromSupabase(response);
    } catch (e, stack) {
      AppLogger.error('Failed to get place', e, stack);
      return null;
    }
  }
  
  // ======== RESBITES ========
  
  // Get resbites
  Future<List<Resbite>> getResbites({
    int limit = 20, 
    int offset = 0, 
    bool upcoming = true,
    String? userId,
  }) async {
    try {
      // Current user ID from auth - if not provided as parameter
      final currentUserId = userId ?? _supabase.auth.currentUser?.id;
      
      if (currentUserId == null) {
        AppLogger.error('No user ID available for filtering resbites', null, null);
        return []; // Return empty list if no user ID
      }
      
      // Get resbite IDs where user is participant
      final participantResbitesQuery = _supabase
        .from('resbite_participants')
        .select('resbite_id')
        .eq('user_id', currentUserId);
      
      final participantResbites = await participantResbitesQuery;
      final participantResbiteIds = participantResbites
        .map<String>((item) => item['resbite_id'] as String)
        .toList();
      
      // Get resbites that are either owned by the user or user is a participant,
      // or they are public (not private)
      final query = _supabase
        .from('resbites')
        .select();
      
      if (participantResbiteIds.isNotEmpty) {
        // User is participant in these resbites
        query.or('id.in.(${participantResbiteIds.join(',')}),owner_id.eq.$currentUserId,is_private.eq.false');
      } else {
        // Only show resbites owned by user or public ones
        query.or('owner_id.eq.$currentUserId,is_private.eq.false');
      }
      
      // Filter by date
      if (upcoming) {
        query.gte('start_date', DateTime.now().toIso8601String());
        query.order('start_date', ascending: true);
      } else {
        query.lt('start_date', DateTime.now().toIso8601String());
        query.order('start_date', ascending: false);
      }
      
      // Apply pagination
      query.range(offset, offset + limit - 1);
      
      final response = await query;
      
      // Get resbites with related data
      final List<Resbite> resbites = [];
      
      for (final json in response) {
        try {
          if (json['id'] == null) {
            AppLogger.error('Resbite ID is null in response', null, null);
            continue;
          }
          
          // Get related data
          Activity? activity;
          if (json['activity_id'] != null) {
            try {
              activity = await getActivity(json['activity_id']);
            } catch (activityError, activityStack) {
              AppLogger.error('Error getting activity for resbite', activityError, activityStack);
              // Continue without activity data
            }
          }
          
          app_user.User? owner;
          if (json['owner_id'] != null) {
            try {
              owner = await getUser(json['owner_id']);
            } catch (ownerError, ownerStack) {
              AppLogger.error('Error getting owner for resbite', ownerError, ownerStack);
              // Continue without owner data
            }
          }
          
          Place? place;
          if (json['place_id'] != null) {
            try {
              place = await getPlace(json['place_id']);
            } catch (placeError, placeStack) {
              AppLogger.error('Error getting place for resbite', placeError, placeStack);
              // Continue without place data
            }
          }
          
          // Get participants
          final List<app_user.User> participants = [];
          try {
            final participantsResponse = await _supabase
              .from('resbite_participants')
              .select('user_id, role')
              .eq('resbite_id', json['id']);
            
            for (final participant in participantsResponse) {
              if (participant['user_id'] == null) {
                AppLogger.error('User ID is null in resbite_participants response', null, null);
                continue;
              }
              
              try {
                final user = await getUser(participant['user_id']);
                if (user != null) {
                  participants.add(user);
                }
              } catch (userError, userStack) {
                AppLogger.error('Error getting participant for resbite', userError, userStack);
                // Continue with next participant
              }
            }
          } catch (participantsError, participantsStack) {
            AppLogger.error('Error getting participants for resbite', participantsError, participantsStack);
            // Continue without participants data
          }
          
          // Create resbite with all related data
          resbites.add(Resbite.fromSupabase(
            json,
            activity: activity,
            owner: owner,
            place: place,
            participants: participants,
          ));
          
          AppLogger.error('Resbite processed successfully: ${json['title']}', null, null);
        } catch (resbiteError, resbiteStack) {
          AppLogger.error('Error processing resbite', resbiteError, resbiteStack);
          // Continue with next resbite instead of failing the whole operation
        }
      }
      
      return resbites;
    } catch (e, stack) {
      AppLogger.error('Failed to get resbites', e, stack);
      return [];
    }
  }
  
  // Get resbite details
  Future<Resbite?> getResbite(String resbiteId) async {
    try {
      final response = await _supabase
        .from('resbites')
        .select()
        .eq('id', resbiteId)
        .maybeSingle();
      
      if (response == null) return null;
      
      // Get related data
      Activity? activity;
      if (response['activity_id'] != null) {
        try {
          activity = await getActivity(response['activity_id']);
        } catch (activityError, activityStack) {
          AppLogger.error('Error getting activity for resbite details', activityError, activityStack);
          // Continue without activity data
        }
      }
      
      app_user.User? owner;
      if (response['owner_id'] != null) {
        try {
          owner = await getUser(response['owner_id']);
        } catch (ownerError, ownerStack) {
          AppLogger.error('Error getting owner for resbite details', ownerError, ownerStack);
          // Continue without owner data
        }
      }
      
      Place? place;
      if (response['place_id'] != null) {
        try {
          place = await getPlace(response['place_id']);
        } catch (placeError, placeStack) {
          AppLogger.error('Error getting place for resbite details', placeError, placeStack);
          // Continue without place data
        }
      }
      
      // Get participants
      final List<app_user.User> participants = [];
      try {
        final participantsResponse = await _supabase
          .from('resbite_participants')
          .select('user_id, role')
          .eq('resbite_id', resbiteId);
        
        for (final participant in participantsResponse) {
          if (participant['user_id'] == null) {
            AppLogger.error('User ID is null in resbite_participants response', null, null);
            continue;
          }
          
          try {
            final user = await getUser(participant['user_id']);
            if (user != null) {
              participants.add(user);
            }
          } catch (userError, userStack) {
            AppLogger.error('Error getting participant for resbite details', userError, userStack);
            // Continue with next participant
          }
        }
      } catch (participantsError, participantsStack) {
        AppLogger.error('Error getting participants for resbite details', participantsError, participantsStack);
        // Continue without participants data
      }
      
      AppLogger.error('Resbite detail retrieved successfully: ${response['title']}', null, null);
      return Resbite.fromSupabase(
        response,
        activity: activity,
        owner: owner,
        place: place,
        participants: participants,
      );
    } catch (e, stack) {
      AppLogger.error('Failed to get resbite', e, stack);
      return null;
    }
  }
  
  // Create resbite
  Future<Resbite?> createResbite(Resbite resbite) async {
    try {
      // Insert resbite
      final response = await _supabase
        .from('resbites')
        .insert({
          'title': resbite.title,
          'description': resbite.description,
          'start_date': resbite.startDate.toIso8601String(),
          'end_date': resbite.endDate.toIso8601String(),
          'is_multi_day': resbite.isMultiDay,
          'meeting_point': resbite.meetingPoint,
          'attendance_limit': resbite.attendanceLimit,
          'note': resbite.note,
          'status': resbite.status.name,
          'is_private': resbite.isPrivate,
          'images': resbite.images,
          'activity_id': resbite.activityId,
          'owner_id': resbite.ownerId,
          'place_id': resbite.placeId,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .maybeSingle();
      
      if (response == null) {
        AppLogger.error('Failed to create resbite: response is null', null, null);
        return null;
      }
      
      if (response['id'] == null) {
        AppLogger.error('Failed to create resbite: ID is null in response', null, null);
        return null;
      }
      
      final String resbiteId = response['id'];
      
      // Add owner as participant
      if (resbite.ownerId != null) {
        try {
          await _supabase
            .from('resbite_participants')
            .insert({
              'resbite_id': resbiteId,
              'user_id': resbite.ownerId,
              'role': 'organizer',
              'status': 'confirmed',
              'joined_at': DateTime.now().toIso8601String(),
            });
          AppLogger.error('Added owner as participant successfully', null, null);
        } catch (participantError, participantStack) {
          AppLogger.error('Failed to add owner as participant', participantError, participantStack);
          // Continue without adding owner as participant
        }
      }
      
      // Return created resbite
      AppLogger.error('Resbite created successfully with ID: $resbiteId', null, null);
      return getResbite(resbiteId);
    } catch (e, stack) {
      AppLogger.error('Failed to create resbite', e, stack);
      // Don't rethrow to prevent app crash - return null instead
      return null;
    }
  }
  
  // Update resbite
  Future<Resbite?> updateResbite(Resbite resbite) async {
    try {
      if (resbite.id.isEmpty) {
        AppLogger.error('Failed to update resbite: ID is empty', null, null);
        return null;
      }
      
      // Update resbite
      await _supabase
        .from('resbites')
        .update({
          'title': resbite.title,
          'description': resbite.description,
          'start_date': resbite.startDate.toIso8601String(),
          'end_date': resbite.endDate.toIso8601String(),
          'is_multi_day': resbite.isMultiDay,
          'meeting_point': resbite.meetingPoint,
          'attendance_limit': resbite.attendanceLimit,
          'note': resbite.note,
          'status': resbite.status.name,
          'is_private': resbite.isPrivate,
          'images': resbite.images,
          'activity_id': resbite.activityId,
          'place_id': resbite.placeId,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', resbite.id);
      
      // Return updated resbite
      AppLogger.error('Resbite updated successfully with ID: ${resbite.id}', null, null);
      return getResbite(resbite.id);
    } catch (e, stack) {
      AppLogger.error('Failed to update resbite', e, stack);
      // Don't rethrow to prevent app crash - return null instead
      return null;
    }
  }
  
  // Join resbite
  Future<void> joinResbite(String resbiteId, String userId) async {
    try {
      if (resbiteId.isEmpty) {
        AppLogger.error('Failed to join resbite: resbiteId is empty', null, null);
        return;
      }
      
      if (userId.isEmpty) {
        AppLogger.error('Failed to join resbite: userId is empty', null, null);
        return;
      }
      
      // Check if already a participant
      try {
        final existing = await _supabase
          .from('resbite_participants')
          .select()
          .eq('resbite_id', resbiteId)
          .eq('user_id', userId)
          .maybeSingle();
        
        if (existing != null) {
          // Already a participant - update status
          await _supabase
            .from('resbite_participants')
            .update({
              'status': 'confirmed',
              'joined_at': DateTime.now().toIso8601String(),
            })
            .eq('resbite_id', resbiteId)
            .eq('user_id', userId);
          AppLogger.error('Updated existing participant status for resbite: $resbiteId', null, null);
        } else {
          // Add as participant
          await _supabase
            .from('resbite_participants')
            .insert({
              'resbite_id': resbiteId,
              'user_id': userId,
              'role': 'participant',
              'status': 'confirmed',
              'joined_at': DateTime.now().toIso8601String(),
            });
          AppLogger.error('Added new participant to resbite: $resbiteId', null, null);
        }
      } catch (participantError, participantStack) {
        AppLogger.error('Error checking/updating participant status', participantError, participantStack);
        // Try direct insert as fallback
        try {
          await _supabase
            .from('resbite_participants')
            .insert({
              'resbite_id': resbiteId,
              'user_id': userId,
              'role': 'participant',
              'status': 'confirmed',
              'joined_at': DateTime.now().toIso8601String(),
            });
          AppLogger.error('Added participant to resbite via fallback: $resbiteId', null, null);
        } catch (insertError, insertStack) {
          AppLogger.error('Failed to add participant via fallback', insertError, insertStack);
          throw insertError; // Rethrow for UI error handling
        }
      }
      
      // Update current attendance count
      try {
        await _updateResbiteAttendance(resbiteId);
      } catch (attendanceError, attendanceStack) {
        AppLogger.error('Failed to update attendance count', attendanceError, attendanceStack);
        // Continue without updating attendance count
      }
    } catch (e, stack) {
      AppLogger.error('Failed to join resbite', e, stack);
      rethrow; // Rethrow for UI error handling
    }
  }
  
  // Leave resbite
  Future<void> leaveResbite(String resbiteId, String userId) async {
    try {
      if (resbiteId.isEmpty) {
        AppLogger.error('Failed to leave resbite: resbiteId is empty', null, null);
        return;
      }
      
      if (userId.isEmpty) {
        AppLogger.error('Failed to leave resbite: userId is empty', null, null);
        return;
      }
      
      // Remove participant
      try {
        await _supabase
          .from('resbite_participants')
          .delete()
          .eq('resbite_id', resbiteId)
          .eq('user_id', userId);
        AppLogger.error('Removed participant from resbite: $resbiteId', null, null);
      } catch (deleteError, deleteStack) {
        AppLogger.error('Failed to remove participant', deleteError, deleteStack);
        throw deleteError; // Rethrow for UI error handling
      }
      
      // Update current attendance count
      try {
        await _updateResbiteAttendance(resbiteId);
      } catch (attendanceError, attendanceStack) {
        AppLogger.error('Failed to update attendance count after leaving', attendanceError, attendanceStack);
        // Continue without updating attendance count
      }
    } catch (e, stack) {
      AppLogger.error('Failed to leave resbite', e, stack);
      rethrow; // Rethrow for UI error handling
    }
  }
  
  // Update resbite attendance count
  Future<void> _updateResbiteAttendance(String resbiteId) async {
    try {
      if (resbiteId.isEmpty) {
        AppLogger.error('Failed to update attendance: resbiteId is empty', null, null);
        return;
      }
      
      // Get all confirmed participants and count them manually
      final response = await _supabase
        .from('resbite_participants')
        .select('user_id')
        .eq('resbite_id', resbiteId)
        .eq('status', 'confirmed');
      
      final int count = response.length;
      
      // Update resbite
      await _supabase
        .from('resbites')
        .update({
          'current_attendance': count,
        })
        .eq('id', resbiteId);
      
      AppLogger.error('Updated attendance count for resbite $resbiteId: $count', null, null);
    } catch (e, stack) {
      AppLogger.error('Failed to update resbite attendance', e, stack);
      // Don't rethrow - non-critical operation
    }
  }
  
  // ======== CONTACTS & FRIENDS ========

  // Find users by email or phone numbers
  Future<List<app_user.User>> findUsersByContactInfo({
    required List<String> emails,
    required List<String> phones,
  }) async {
    try {
      if (emails.isEmpty && phones.isEmpty) {
        AppLogger.error('No emails or phones provided to findUsersByContactInfo', null, null);
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
            final int end = (i + batchSize < emails.length) ? i + batchSize : emails.length;
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
                AppLogger.error('Error parsing user from email lookup', parseError, parseStack);
                // Continue with next user
              }
            }
          }
        } catch (emailError, emailStack) {
          AppLogger.error('Error finding users by email', emailError, emailStack);
          // Continue with phone lookup
        }
      }
      
      // Find users by phone number
      if (phones.isNotEmpty) {
        try {
          // We need to run multiple queries if there are many phone numbers
          const int batchSize = 50;
          for (int i = 0; i < phones.length; i += batchSize) {
            final int end = (i + batchSize < phones.length) ? i + batchSize : phones.length;
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
                AppLogger.error('Error parsing user from phone lookup', parseError, parseStack);
                // Continue with next user
              }
            }
          }
        } catch (phoneError, phoneStack) {
          AppLogger.error('Error finding users by phone', phoneError, phoneStack);
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
  
  // Add a friendship between two users
  Future<bool> addFriendship({
    required String userId1,
    required String userId2,
  }) async {
    try {
      if (userId1.isEmpty || userId2.isEmpty) {
        AppLogger.error('Failed to add friendship: userId is empty', null, null);
        return false;
      }
      
      // Check if friendship already exists
      final existingResponse = await _supabase
        .from('friendships')
        .select()
        .or('user1_id.eq.$userId1,user1_id.eq.$userId2')
        .or('user2_id.eq.$userId1,user2_id.eq.$userId2')
        .maybeSingle();
      
      if (existingResponse != null) {
        AppLogger.info('Friendship already exists between $userId1 and $userId2');
        return true;
      }
      
      // Insert friendship
      await _supabase.from('friendships').insert({
        'user1_id': userId1,
        'user2_id': userId2,
        'created_at': DateTime.now().toIso8601String(),
        'status': 'accepted', // Direct add as accepted
      });
      
      AppLogger.info('Added friendship between $userId1 and $userId2');
      return true;
    } catch (e, stack) {
      AppLogger.error('Failed to add friendship', e, stack);
      return false;
    }
  }
  
  // ======== NOTIFICATIONS ========
  
  // Get notifications for a user
  Future<List<Map<String, dynamic>>> getNotifications(String userId, {int limit = 20, int offset = 0}) async {
    try {
      if (userId.isEmpty) {
        AppLogger.error('Failed to get notifications: userId is empty', null, null);
        return [];
      }
      
      final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('timestamp', ascending: false)
        .range(offset, offset + limit - 1);
      
      return response;
    } catch (e, stack) {
      AppLogger.error('Failed to get notifications', e, stack);
      return [];
    }
  }
  
  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      if (notificationId.isEmpty) {
        AppLogger.error('Failed to mark notification as read: notificationId is empty', null, null);
        return;
      }
      
      await _supabase
        .from('notifications')
        .update({
          'is_read': true,
        })
        .eq('id', notificationId);
      
      AppLogger.error('Marked notification as read: $notificationId', null, null);
    } catch (e, stack) {
      AppLogger.error('Failed to mark notification as read', e, stack);
      // Don't rethrow - non-critical operation
    }
  }
  
  // Mark all notifications as read for a user
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      if (userId.isEmpty) {
        AppLogger.error('Failed to mark all notifications as read: userId is empty', null, null);
        return;
      }
      
      await _supabase
        .from('notifications')
        .update({
          'is_read': true,
        })
        .eq('user_id', userId);
      
      AppLogger.error('Marked all notifications as read for user: $userId', null, null);
    } catch (e, stack) {
      AppLogger.error('Failed to mark all notifications as read', e, stack);
      // Don't rethrow - non-critical operation
    }
  }
  
  // Send a notification to a user
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? resbiteId,
    String? activityId,
    String? senderId,
    String? imageUrl,
  }) async {
    try {
      if (userId.isEmpty) {
        AppLogger.error('Failed to send notification: userId is empty', null, null);
        return;
      }
      
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'type': type,
        'resbite_id': resbiteId,
        'activity_id': activityId,
        'sender_id': senderId,
        'is_read': false,
        'image_url': imageUrl,
      });
      
      AppLogger.error('Notification sent to user: $userId', null, null);
    } catch (e, stack) {
      AppLogger.error('Failed to send notification', e, stack);
      // Don't rethrow - non-critical operation
    }
  }
}
