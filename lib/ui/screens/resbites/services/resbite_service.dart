import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/resbite.dart';
import '../../../../models/user.dart';
import '../../../../services/providers.dart'; // For supabaseClientProvider, currentUserProvider

/// ResbiteService defines the interface for all resbite-related operations
abstract class ResbiteService {
  /// Get upcoming resbites for the current user
  Future<List<Resbite>> getUpcomingResbites();

  /// Get past resbites for the current user
  Future<List<Resbite>> getPastResbites();

  /// Get a specific resbite by ID
  Future<Resbite?> getResbiteById(String id);

  /// Create a new resbite
  Future<Resbite?> createResbite({
    required String title,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
    bool isMultiDay = false,
    String? meetingPoint,
    double? meetingLatitude,
    double? meetingLongitude,
    int? attendanceLimit,
    String? note,
    bool isPrivate = false,
    String? activityId,
    String? placeId,
    List<String> images = const [],
  });

  /// Update an existing resbite
  Future<Resbite?> updateResbite({
    required String id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    bool? isMultiDay,
    String? meetingPoint,
    double? meetingLatitude,
    double? meetingLongitude,
    int? attendanceLimit,
    String? note,
    ResbiteStatus? status,
    bool? isPrivate,
    List<String>? images,
    String? activityId,
    String? placeId,
  });

  /// Delete a resbite
  Future<bool> deleteResbite(String id);

  /// Get resbites by activity
  Future<List<Resbite>> getResbitesByActivity(String activityId);

  /// Get resbites by place
  Future<List<Resbite>> getResbitesByPlace(String placeId);

  /// Join a resbite as a participant
  Future<bool> joinResbite(String resbiteId);

  /// Leave a resbite (remove as participant)
  Future<bool> leaveResbite(String resbiteId, String id);

  /// Cancel a resbite (set status to cancelled)
  Future<bool> cancelResbite(String resbiteId);

  /// Get participants of a resbite
  Future<List<User>> getParticipants(String resbiteId);

  /// Toggle resbite status
  Future<Resbite?> updateResbiteStatus(String resbiteId, ResbiteStatus status);

  /// Get resbites created by a specific user
  Future<List<Resbite>> getResbitesByUser(String userId);

  /// Refresh resbites data
  Future<void> refreshResbites();

  /// Invite multiple users to a resbite
  Future<void> inviteUsers(String resbiteId, List<String> userIds);
}

/// Implementation of the ResbiteService interface
class ResbiteServiceImpl implements ResbiteService {
  final Ref _ref;

  const ResbiteServiceImpl(this._ref);

  @override
  Future<List<Resbite>> getUpcomingResbites() async {
    try {
      final supabase = _ref.read(supabaseClientProvider);
      final user = _ref.read(currentUserProvider).valueOrNull;

      if (user == null) {
        return [];
      }

      final response = await supabase
          .from('resbites')
          .select('*, activity(*), place(*), owner:user_id(*)')
          .eq('user_id', user.id)
          .gt('start_date', DateTime.now().toIso8601String())
          .order('start_date');

      return response.map((data) => Resbite.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching upcoming resbites: $e');
      return [];
    }
  }

  @override
  Future<List<Resbite>> getPastResbites() async {
    try {
      final supabase = _ref.read(supabaseClientProvider);
      final user = _ref.read(currentUserProvider).valueOrNull;

      if (user == null) {
        return [];
      }

      final response = await supabase
          .from('resbites')
          .select('*, activity(*), place(*), owner:user_id(*)')
          .eq('user_id', user.id)
          // Past resbites are those whose start_date is on or before NOW.
          .lte('start_date', DateTime.now().toIso8601String())
          .order('start_date', ascending: false);

      return response.map((data) => Resbite.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching past resbites: $e');
      return [];
    }
  }

  @override
  Future<Resbite?> getResbiteById(String id) async {
    try {
      final supabase = _ref.read(supabaseClientProvider);

      final response =
          await supabase
              .from('resbites')
              .select('*, activity(*), place(*), owner:user_id(*)')
              .eq('id', id)
              .single();

      return Resbite.fromJson(response);
    } catch (e) {
      print('Error fetching resbite by id: $e');
      return null;
    }
  }

  @override
  Future<Resbite?> createResbite({
    required String title,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
    bool isMultiDay = false,
    String? meetingPoint,
    double? meetingLatitude,
    double? meetingLongitude,
    int? attendanceLimit,
    String? note,
    bool isPrivate = false,
    String? activityId,
    String? placeId,
    List<String> images = const [],
  }) async {
    try {
      final supabase = _ref.read(supabaseClientProvider);
      final user = _ref.read(currentUserProvider).valueOrNull;

      if (user == null) {
        return null;
      }

      final resbiteData = {
        'title': title,
        'description': description,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'is_multi_day': isMultiDay,
        'meeting_point': meetingPoint,
        'meeting_latitude': meetingLatitude,
        'meeting_longitude': meetingLongitude,
        'attendance_limit': attendanceLimit,
        'note': note,
        'status': ResbiteStatus.planned.name,
        'is_private': isPrivate,
        'images': images,
        'activity_id': activityId,
        'place_id': placeId,
        'user_id': user.id,
        'created_at': DateTime.now().toIso8601String(),
        'current_attendance': 1, // Owner is first participant
      };

      final response =
          await supabase
              .from('resbites')
              .insert(resbiteData)
              .select('*, activity(*), place(*), owner:user_id(*)')
              .single();

      // Add the owner as a participant
      await supabase.from('resbite_participants').insert({
        'resbite_id': response['id'],
        'user_id': user.id,
        'joined_at': DateTime.now().toIso8601String(),
        'is_owner': true,
      });

      // Refresh resbites
      refreshResbites();

      return Resbite.fromJson(response);
    } catch (e) {
      print('Error creating resbite: $e');
      return null;
    }
  }

  @override
  Future<Resbite?> updateResbite({
    required String id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    bool? isMultiDay,
    String? meetingPoint,
    double? meetingLatitude,
    double? meetingLongitude,
    int? attendanceLimit,
    String? note,
    ResbiteStatus? status,
    bool? isPrivate,
    List<String>? images,
    String? activityId,
    String? placeId,
  }) async {
    try {
      final supabase = _ref.read(supabaseClientProvider);
      final user = _ref.read(currentUserProvider).valueOrNull;

      if (user == null) {
        return null;
      }

      // Check if user is the owner of the resbite
      final ownerCheck =
          await supabase
              .from('resbites')
              .select('user_id')
              .eq('id', id)
              .eq('user_id', user.id)
              .maybeSingle();

      if (ownerCheck == null) {
        print('User is not the owner of this resbite');
        return null;
      }

      final updateData = <String, dynamic>{};

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (startDate != null)
        updateData['start_date'] = startDate.toIso8601String();
      if (endDate != null) updateData['end_date'] = endDate.toIso8601String();
      if (isMultiDay != null) updateData['is_multi_day'] = isMultiDay;
      if (meetingPoint != null) updateData['meeting_point'] = meetingPoint;
      if (meetingLatitude != null)
        updateData['meeting_latitude'] = meetingLatitude;
      if (meetingLongitude != null)
        updateData['meeting_longitude'] = meetingLongitude;
      if (attendanceLimit != null)
        updateData['attendance_limit'] = attendanceLimit;
      if (note != null) updateData['note'] = note;
      if (status != null) updateData['status'] = status.name;
      if (isPrivate != null) updateData['is_private'] = isPrivate;
      if (images != null) updateData['images'] = images;
      if (activityId != null) updateData['activity_id'] = activityId;
      if (placeId != null) updateData['place_id'] = placeId;

      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response =
          await supabase
              .from('resbites')
              .update(updateData)
              .eq('id', id)
              .select('*, activity(*), place(*), owner:user_id(*)')
              .single();

      // Refresh resbites
      refreshResbites();

      return Resbite.fromJson(response);
    } catch (e) {
      print('Error updating resbite: $e');
      return null;
    }
  }

  @override
  Future<bool> deleteResbite(String id) async {
    try {
      final supabase = _ref.read(supabaseClientProvider);
      final user = _ref.read(currentUserProvider).valueOrNull;

      if (user == null) {
        return false;
      }

      // Check if user is the owner of the resbite
      final ownerCheck =
          await supabase
              .from('resbites')
              .select('user_id')
              .eq('id', id)
              .eq('user_id', user.id)
              .maybeSingle();

      if (ownerCheck == null) {
        print('User is not the owner of this resbite');
        return false;
      }

      // First delete all participants
      await supabase.from('resbite_participants').delete().eq('resbite_id', id);

      // Then delete the resbite
      await supabase.from('resbites').delete().eq('id', id);

      // Refresh resbites
      refreshResbites();

      return true;
    } catch (e) {
      print('Error deleting resbite: $e');
      return false;
    }
  }

  @override
  Future<List<Resbite>> getResbitesByActivity(String activityId) async {
    try {
      final supabase = _ref.read(supabaseClientProvider);

      final response = await supabase
          .from('resbites')
          .select('*, activity(*), place(*), owner:user_id(*)')
          .eq('activity_id', activityId)
          .order('start_date');

      return response.map((data) => Resbite.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching resbites by activity: $e');
      return [];
    }
  }

  @override
  Future<List<Resbite>> getResbitesByPlace(String placeId) async {
    try {
      final supabase = _ref.read(supabaseClientProvider);

      final response = await supabase
          .from('resbites')
          .select('*, activity(*), place(*), owner:user_id(*)')
          .eq('place_id', placeId)
          .order('start_date');

      return response.map((data) => Resbite.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching resbites by place: $e');
      return [];
    }
  }

  @override
  Future<bool> joinResbite(String resbiteId) async {
    try {
      final supabase = _ref.read(supabaseClientProvider);
      final user = _ref.read(currentUserProvider).valueOrNull;

      if (user == null) {
        return false;
      }

      // Check if resbite exists
      final resbite =
          await supabase
              .from('resbites')
              .select('*, attendance_limit, current_attendance')
              .eq('id', resbiteId)
              .single();

      // Check if user is already a participant
      final existingParticipant =
          await supabase
              .from('resbite_participants')
              .select()
              .eq('resbite_id', resbiteId)
              .eq('user_id', user.id)
              .maybeSingle();

      if (existingParticipant != null) {
        // Already joined
        return true;
      }

      // Check if there's still space available
      final attendanceLimit = resbite['attendance_limit'];
      final currentAttendance = resbite['current_attendance'] ?? 0;

      if (attendanceLimit != null && currentAttendance >= attendanceLimit) {
        print('Resbite has reached its attendance limit');
        return false;
      }

      // Add user as participant
      await supabase.from('resbite_participants').insert({
        'resbite_id': resbiteId,
        'user_id': user.id,
        'joined_at': DateTime.now().toIso8601String(),
        'is_owner': false,
      });

      // Update current attendance
      await supabase
          .from('resbites')
          .update({'current_attendance': currentAttendance + 1})
          .eq('id', resbiteId);

      // Refresh resbites
      refreshResbites();

      return true;
    } catch (e) {
      print('Error joining resbite: $e');
      return false;
    }
  }

  @override
  Future<bool> leaveResbite(String resbiteId, String userId) async {
    try {
      final supabase = _ref.read(supabaseClientProvider);
      final user = _ref.read(currentUserProvider).valueOrNull;

      if (user == null) {
        return false;
      }

      // Check if user is a participant
      final participant =
          await supabase
              .from('resbite_participants')
              .select('is_owner')
              .eq('resbite_id', resbiteId)
              .eq('user_id', userId)
              .maybeSingle();

      if (participant == null) {
        // Not a participant
        return false;
      }

      // Check if user is the owner
      final isOwner = participant['is_owner'] == true;

      if (isOwner) {
        print('Owner cannot leave the resbite. Delete it instead.');
        return false;
      }

      // Get current attendance
      final resbite =
          await supabase
              .from('resbites')
              .select('current_attendance')
              .eq('id', resbiteId)
              .single();

      final currentAttendance = resbite['current_attendance'] ?? 1;

      // Remove user as participant
      await supabase
          .from('resbite_participants')
          .delete()
          .eq('resbite_id', resbiteId)
          .eq('user_id', user.id);

      // Update current attendance
      await supabase
          .from('resbites')
          .update({
            'current_attendance':
                currentAttendance > 0 ? currentAttendance - 1 : 0,
          })
          .eq('id', resbiteId);

      // Refresh resbites
      refreshResbites();

      return true;
    } catch (e) {
      print('Error leaving resbite: $e');
      return false;
    }
  }

  @override
  Future<bool> cancelResbite(String resbiteId) async {
    try {
      final updated = await updateResbiteStatus(
        resbiteId,
        ResbiteStatus.cancelled,
      );
      await refreshResbites();
      return updated != null;
    } catch (e) {
      print('Error cancelling resbite: $e');
      return false;
    }
  }

  @override
  Future<List<User>> getParticipants(String resbiteId) async {
    try {
      final supabase = _ref.read(supabaseClientProvider);

      final response = await supabase
          .from('resbite_participants')
          .select('user:user_id(*)')
          .eq('resbite_id', resbiteId);

      return response.map((data) => User.fromJson(data['user'])).toList();
    } catch (e) {
      print('Error fetching resbite participants: $e');
      return [];
    }
  }

  @override
  Future<Resbite?> updateResbiteStatus(
    String resbiteId,
    ResbiteStatus status,
  ) async {
    try {
      return await updateResbite(id: resbiteId, status: status);
    } catch (e) {
      print('Error updating resbite status: $e');
      return null;
    }
  }

  @override
  Future<List<Resbite>> getResbitesByUser(String userId) async {
    try {
      final supabase = _ref.read(supabaseClientProvider);

      final response = await supabase
          .from('resbites')
          .select('*, activity(*), place(*), owner:user_id(*)')
          .eq('user_id', userId)
          .order('start_date', ascending: false);

      return response.map((data) => Resbite.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching resbites by user: $e');
      return [];
    }
  }

  @override
  Future<void> refreshResbites() async {
    try {
      // Invalidate all resbite-related providers
      _ref.invalidate(upcomingResbitesProvider);
      _ref.invalidate(pastResbitesProvider);
    } catch (e) {
      print('Error refreshing resbites: $e');
    }
  }

  @override
  Future<void> inviteUsers(String resbiteId, List<String> userIds) async {
    final supabase = _ref.read(supabaseClientProvider);
    if (userIds.isEmpty) return;
    final rows = [
      for (final uid in userIds)
        {
          'resbite_id': resbiteId,
          'user_id': uid,
          'status': 'invited',
          'joined_at': DateTime.now().toIso8601String(),
        },
    ];
    await supabase.from('resbite_participants').insert(rows, defaultToNull: true);
  }
}

// Provider for resbite service
final resbiteServiceProvider = Provider<ResbiteService>((ref) {
  return ResbiteServiceImpl(ref);
});

// Providers for resbites data using the service
final upcomingResbitesProvider = FutureProvider<List<Resbite>>((ref) async {
  final resbiteService = ref.watch(resbiteServiceProvider);
  return resbiteService.getUpcomingResbites();
});

final pastResbitesProvider = FutureProvider<List<Resbite>>((ref) async {
  final resbiteService = ref.watch(resbiteServiceProvider);
  return resbiteService.getPastResbites();
});

// Additional providers
final resbiteParticipantsProvider = FutureProvider.family<List<User>, String>((
  ref,
  resbiteId,
) async {
  final resbiteService = ref.watch(resbiteServiceProvider);
  return resbiteService.getParticipants(resbiteId);
});

final resbitesByActivityProvider = FutureProvider.family<List<Resbite>, String>(
  (ref, activityId) async {
    final resbiteService = ref.watch(resbiteServiceProvider);
    return resbiteService.getResbitesByActivity(activityId);
  },
);

final resbitesByPlaceProvider = FutureProvider.family<List<Resbite>, String>((
  ref,
  placeId,
) async {
  final resbiteService = ref.watch(resbiteServiceProvider);
  return resbiteService.getResbitesByPlace(placeId);
});

final resbitesByUserProvider = FutureProvider.family<List<Resbite>, String>((
  ref,
  userId,
) async {
  final resbiteService = ref.watch(resbiteServiceProvider);
  return resbiteService.getResbitesByUser(userId);
});
