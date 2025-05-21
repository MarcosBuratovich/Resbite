import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/activity.dart';
import '../models/place.dart';
import '../models/resbite.dart';
import '../models/user.dart' as app_user;
import '../utils/logger.dart';
import './providers.dart'; // For activityServiceProvider, userProfileServiceProvider, and databaseServiceProvider (temporary for getPlace)

class ResbiteService {
  final SupabaseClient _supabase;
  final Ref _ref;

  ResbiteService({SupabaseClient? supabase, required Ref ref})
    : _supabase = supabase ?? Supabase.instance.client,
      _ref = ref;

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
        AppLogger.error(
          'No user ID available for filtering resbites',
          null,
          null,
        );
        return []; // Return empty list if no user ID
      }

      // Get resbite IDs where user is participant
      final participantResbitesQuery = _supabase
          .from('resbite_participants')
          .select('resbite_id')
          .eq('user_id', currentUserId);

      final participantResbites = await participantResbitesQuery;
      final participantResbiteIds =
          participantResbites
              .map<String>((item) => item['resbite_id'] as String)
              .toList();

      final query = _supabase.from('resbites').select();

      if (participantResbiteIds.isNotEmpty) {
        final quotedIds = participantResbiteIds.map((id) => "'$id'").join(',');
        query.or("id.in.($quotedIds),owner_id.eq.'$currentUserId',is_private.eq.false");
      } else {
        query.or("owner_id.eq.'$currentUserId',is_private.eq.false");
      }

      if (upcoming) {
        query.gte('start_date', DateTime.now().toIso8601String());
        query.order('start_date', ascending: true);
      } else {
        query.lt('start_date', DateTime.now().toIso8601String());
        query.order('start_date', ascending: false);
      }

      query.range(offset, offset + limit - 1);

      final response = await query;
      final List<Resbite> resbites = [];

      for (final json in response) {
        try {
          if (json['id'] == null) {
            AppLogger.error(
              'Resbite ID is null in getResbites response',
              null,
              null,
            );
            continue;
          }

          Activity? activity;
          if (json['activity_id'] != null) {
            try {
              activity = await _ref
                  .read(activityServiceProvider)
                  .getActivity(json['activity_id']);
            } catch (activityError, activityStack) {
              AppLogger.error(
                'Error getting activity for resbite in getResbites',
                activityError,
                activityStack,
              );
            }
          }

          app_user.User? owner;
          if (json['owner_id'] != null) {
            try {
              owner = await _ref
                  .read(userProfileServiceProvider)
                  .getUser(json['owner_id']);
            } catch (ownerError, ownerStack) {
              AppLogger.error(
                'Error getting owner for resbite in getResbites',
                ownerError,
                ownerStack,
              );
            }
          }

          Place? place;
          if (json['place_id'] != null) {
            try {
              // Temporary: Call getPlace from DatabaseService via provider
              place = await _ref
                  .read(databaseServiceProvider)
                  .getPlace(json['place_id']);
            } catch (placeError, placeStack) {
              AppLogger.error(
                'Error getting place for resbite in getResbites',
                placeError,
                placeStack,
              );
            }
          }

          final List<app_user.User> participants = [];
          try {
            final participantsResponse = await _supabase
                .from('resbite_participants')
                .select('user_id, role')
                .eq('resbite_id', json['id']);

            for (final participantData in participantsResponse) {
              if (participantData['user_id'] == null) {
                AppLogger.error(
                  'User ID is null in resbite_participants response for getResbites',
                  null,
                  null,
                );
                continue;
              }
              try {
                final user = await _ref
                    .read(userProfileServiceProvider)
                    .getUser(participantData['user_id']);
                if (user != null) {
                  participants.add(user);
                }
              } catch (userError, userStack) {
                AppLogger.error(
                  'Error getting participant user for resbite in getResbites',
                  userError,
                  userStack,
                );
              }
            }
          } catch (participantsError, participantsStack) {
            AppLogger.error(
              'Error getting participants list for resbite in getResbites',
              participantsError,
              participantsStack,
            );
          }

          resbites.add(
            Resbite.fromSupabase(
              json,
              activity: activity,
              owner: owner,
              place: place,
              participants: participants,
            ),
          );
          AppLogger.info(
            'Resbite processed successfully in getResbites: ${json['title']}',
            null,
            null,
          );
        } catch (resbiteError, resbiteStack) {
          AppLogger.error(
            'Error processing individual resbite in getResbites',
            resbiteError,
            resbiteStack,
          );
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
      final response =
          await _supabase
              .from('resbites')
              .select()
              .eq('id', resbiteId)
              .maybeSingle();

      if (response == null) return null;

      Activity? activity;
      if (response['activity_id'] != null) {
        try {
          activity = await _ref
              .read(activityServiceProvider)
              .getActivity(response['activity_id']);
        } catch (activityError, activityStack) {
          AppLogger.error(
            'Error getting activity for resbite details',
            activityError,
            activityStack,
          );
        }
      }

      app_user.User? owner;
      if (response['owner_id'] != null) {
        try {
          owner = await _ref
              .read(userProfileServiceProvider)
              .getUser(response['owner_id']);
        } catch (ownerError, ownerStack) {
          AppLogger.error(
            'Error getting owner for resbite details',
            ownerError,
            ownerStack,
          );
        }
      }

      Place? place;
      if (response['place_id'] != null) {
        try {
          // Temporary: Call getPlace from DatabaseService via provider
          place = await _ref
              .read(databaseServiceProvider)
              .getPlace(response['place_id']);
        } catch (placeError, placeStack) {
          AppLogger.error(
            'Error getting place for resbite details',
            placeError,
            placeStack,
          );
        }
      }

      final List<app_user.User> participants = [];
      try {
        final participantsResponse = await _supabase
            .from('resbite_participants')
            .select('user_id, role')
            .eq('resbite_id', resbiteId);

        for (final participantData in participantsResponse) {
          if (participantData['user_id'] == null) {
            AppLogger.error(
              'User ID is null in resbite_participants for getResbite',
              null,
              null,
            );
            continue;
          }
          try {
            final user = await _ref
                .read(userProfileServiceProvider)
                .getUser(participantData['user_id']);
            if (user != null) {
              participants.add(user);
            }
          } catch (userError, userStack) {
            AppLogger.error(
              'Error getting participant user for resbite details',
              userError,
              userStack,
            );
          }
        }
      } catch (participantsError, participantsStack) {
        AppLogger.error(
          'Error getting participants list for resbite details',
          participantsError,
          participantsStack,
        );
      }

      AppLogger.info(
        'Resbite detail retrieved successfully: ${response['title']}',
        null,
        null,
      );
      return Resbite.fromSupabase(
        response,
        activity: activity,
        owner: owner,
        place: place,
        participants: participants,
      );
    } catch (e, stack) {
      AppLogger.error('Failed to get resbite details for $resbiteId', e, stack);
      return null;
    }
  }

  // Create resbite
  Future<Resbite?> createResbite(Resbite resbite) async {
    try {
      final response =
          await _supabase
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
        AppLogger.error(
          'Failed to create resbite: response is null',
          null,
          null,
        );
        return null;
      }

      if (response['id'] == null) {
        AppLogger.error(
          'Failed to create resbite: ID is null in response',
          null,
          null,
        );
        return null;
      }

      final String resbiteId = response['id'];

      if (resbite.ownerId != null) {
        try {
          await _supabase.from('resbite_participants').insert({
            'resbite_id': resbiteId,
            'user_id': resbite.ownerId,
            'role': 'organizer', // TODO: make role dynamic if needed
            'status': 'confirmed',
            'joined_at': DateTime.now().toIso8601String(),
          });
          AppLogger.info(
            'Added owner as participant successfully for $resbiteId',
            null,
            null,
          );
        } catch (participantError, participantStack) {
          AppLogger.error(
            'Failed to add owner as participant for $resbiteId',
            participantError,
            participantStack,
          );
        }
      }
      AppLogger.info(
        'Resbite created successfully with ID: $resbiteId',
        null,
        null,
      );
      return getResbite(resbiteId); // Call local getResbite
    } catch (e, stack) {
      AppLogger.error('Failed to create resbite', e, stack);
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

      AppLogger.info(
        'Resbite updated successfully with ID: ${resbite.id}',
        null,
        null,
      );
      return getResbite(resbite.id); // Call local getResbite
    } catch (e, stack) {
      AppLogger.error('Failed to update resbite ${resbite.id}', e, stack);
      return null;
    }
  }

  // Private helper to update attendance count
  Future<void> _updateResbiteAttendance(String resbiteId) async {
    try {
      // Fetch the count of confirmed participants directly
      final count = await _supabase
          .from('resbite_participants')
          .count(CountOption.exact) // Use the .count() method
          .eq('resbite_id', resbiteId)
          .eq('status', 'confirmed');

      await _supabase
          .from('resbites')
          .update({'current_attendance': count})
          .eq('id', resbiteId);
      AppLogger.info(
        'Updated attendance count for resbite $resbiteId to $count',
        null,
        null,
      );
    } catch (e, stack) {
      AppLogger.error(
        'Failed to update attendance count for resbite $resbiteId',
        e,
        stack,
      );
      // Don't rethrow, critical but not blocking for join/leave
    }
  }

  // Join resbite
  Future<void> joinResbite(String resbiteId, String userId) async {
    try {
      if (resbiteId.isEmpty) {
        AppLogger.error(
          'Failed to join resbite: resbiteId is empty',
          null,
          null,
        );
        return;
      }
      if (userId.isEmpty) {
        AppLogger.error('Failed to join resbite: userId is empty', null, null);
        return;
      }

      final existing =
          await _supabase
              .from('resbite_participants')
              .select()
              .eq('resbite_id', resbiteId)
              .eq('user_id', userId)
              .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('resbite_participants')
            .update({
              'status': 'confirmed',
              'joined_at': DateTime.now().toIso8601String(),
            })
            .eq('resbite_id', resbiteId)
            .eq('user_id', userId);
        AppLogger.info(
          'Updated existing participant status for resbite: $resbiteId, user: $userId',
          null,
          null,
        );
      } else {
        await _supabase.from('resbite_participants').insert({
          'resbite_id': resbiteId,
          'user_id': userId,
          'role': 'participant', // TODO: make role dynamic if needed
          'status': 'confirmed',
          'joined_at': DateTime.now().toIso8601String(),
        });
        AppLogger.info(
          'Added new participant to resbite: $resbiteId, user: $userId',
          null,
          null,
        );
      }
      await _updateResbiteAttendance(resbiteId);
    } catch (e, stack) {
      AppLogger.error(
        'Failed to join resbite $resbiteId for user $userId',
        e,
        stack,
      );
      rethrow;
    }
  }

  // Leave resbite
  Future<void> leaveResbite(String resbiteId, String userId) async {
    try {
      if (resbiteId.isEmpty) {
        AppLogger.error(
          'Failed to leave resbite: resbiteId is empty',
          null,
          null,
        );
        return;
      }
      if (userId.isEmpty) {
        AppLogger.error('Failed to leave resbite: userId is empty', null, null);
        return;
      }

      await _supabase
          .from('resbite_participants')
          .delete()
          .eq('resbite_id', resbiteId)
          .eq('user_id', userId);
      AppLogger.info(
        'Removed participant from resbite: $resbiteId, user: $userId',
        null,
        null,
      );

      await _updateResbiteAttendance(resbiteId);
    } catch (e, stack) {
      AppLogger.error(
        'Failed to leave resbite $resbiteId for user $userId',
        e,
        stack,
      );
      rethrow;
    }
  }
}
