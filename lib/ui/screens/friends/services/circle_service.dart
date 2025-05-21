import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resbite_app/models/circle.dart';
import 'package:resbite_app/models/user.dart';
import 'package:resbite_app/models/validated_contact.dart';
import 'package:resbite_app/services/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
// Firebase Auth import removed

/// Service interface for managing friend circles
abstract class CircleService {
  /// Creates a new circle
  Future<String> createCircle({
    required String name,
    required String description,
    bool isPrivate = true,
  });

  /// Gets circles the user is a member of
  Future<List<Circle>> getUserCircles();

  /// Gets members of a specific circle
  Future<List<User>> getCircleMembers(String circleId);

  /// Invites a contact to join a circle
  Future<void> inviteToCircle(String circleId, ValidatedContact contact);

  /// Invites multiple contacts to a circle
  Future<void> inviteMultipleToCircle({
    required String circleId,
    required List<ValidatedContact> contacts,
  });

  /// Removes a member from a circle
  Future<void> removeMember(String circleId, String userId);

  /// Leaves a circle
  Future<void> leaveCircle(String circleId);
}

/// Implementation of CircleService
class CircleServiceImpl implements CircleService {
  final SupabaseClient _supabase;

  CircleServiceImpl(this._supabase);

  /// Get the current user ID or throw error if not authenticated
  String get _requiredUserId {
    final supabaseUser = _supabase.auth.currentUser;
    if (kDebugMode) {
      print('----------------------------------------------------');
      print('[CircleService - _requiredUserId] KDEBUGMODE IS TRUE. CHECKING AUTH.');
      print('[CircleService - _requiredUserId] supabaseUser is ${supabaseUser == null ? 'NULL' : 'NOT NULL'}');
      if (supabaseUser != null) {
        print('[CircleService - _requiredUserId] Supabase User ID: ${supabaseUser.id}');
      }
      print('----------------------------------------------------');
    }
    final userId = supabaseUser?.id;
    if (userId == null) {
      if (kDebugMode) {
        print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        print('[CircleService - _requiredUserId] ERROR: User not authenticated. Firebase currentUser is null or has no UID.');
        print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      }
      throw Exception('User not authenticated');
    }
    return userId;
  }

  @override
  Future<String> createCircle({
    required String name,
    required String description,
    bool isPrivate = true,
  }) async {
    if (kDebugMode) {
      print('****************************************************');
      print('[CircleService - createCircle] ATTEMPTING TO CREATE CIRCLE. Name: $name');
      print('****************************************************');
    }
    try {
      final userId = _requiredUserId;

      // Create the circle
      final result =
          await _supabase
              .from('circles')
              .insert({
                'name': name,
                'description': description,
                'is_private': isPrivate,
                'created_by': userId,
                'created_at': DateTime.now().toIso8601String(),
              })
              .select('id')
              .single();

      final circleId = result['id'] as String;

      // Add creator as a member and admin
      await _supabase.from('circle_members').insert({
        'circle_id': circleId,
        'user_id': userId,
        'role': 'admin',
        'joined_at': DateTime.now().toIso8601String(),
      });

      return circleId;
    } catch (e) {
      debugPrint('Error creating circle: $e');
      rethrow;
    }
  }

  @override
  Future<List<Circle>> getUserCircles() async {
    try {
      final userId = _requiredUserId;

      // Get circles where user is a member
      final memberships = await _supabase
          .from('circle_members')
          .select('*, circles(*)')
          .eq('user_id', userId);

      // Transform to Circle objects
      return memberships.map<Circle>((membership) {
        final circle = membership['circles'];
        return Circle(
          id: circle['id'],
          name: circle['name'],
          description: circle['description'] ?? '',
          isPrivate: circle['is_private'] ?? true,
          createdAt: DateTime.parse(circle['created_at']),
          createdBy: circle['created_by'],
          memberIds: [], // Will be populated elsewhere as needed
          adminIds: [], // Will be populated elsewhere as needed
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting user circles: $e');
      rethrow;
    }
  }

  @override
  Future<List<User>> getCircleMembers(String circleId) async {
    try {
      // Get members of the circle with user details
      final members = await _supabase
          .from('circle_members')
          .select('*, users:user_id(*)')
          .eq('circle_id', circleId);

      // Transform to User objects
      return members.map<User>((member) {
        final user = member['users'];
        return User(
          id: member['user_id'],
          email: user['email'] ?? '',
          displayName: user['display_name'] ?? 'User',
          profileImageUrl: user['profile_image_url'],
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting circle members: $e');
      rethrow;
    }
  }

  @override
  Future<void> inviteToCircle(String circleId, ValidatedContact contact) async {
    try {
      final userId = _requiredUserId;

      // Check if user exists by email or phone
      final userByEmail =
          contact.contactInfo.email != null
              ? await _supabase
                  .from('users')
                  .select()
                  .eq('email', contact.contactInfo.email as Object)
                  .maybeSingle()
              : null;

      final userByPhone =
          contact.contactInfo.phoneNumber != null
              ? await _supabase
                  .from('users')
                  .select()
                  .eq('phone', contact.contactInfo.phoneNumber as Object)
                  .maybeSingle()
              : null;

      final foundUser = userByEmail ?? userByPhone;

      if (foundUser != null) {
        // Add user directly to circle
        await _addUserToCircle(circleId, foundUser['id']);
      } else {
        // Create invitation record
        await _supabase.from('circle_invitations').insert({
          'circle_id': circleId,
          'inviter_id': userId,
          'invited_email': contact.contactInfo.email,
          'invited_phone': contact.contactInfo.phoneNumber,
          'contact_info': contact.contactInfo.toJson(),
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Error inviting to circle: $e');
      rethrow;
    }
  }

  @override
  Future<void> inviteMultipleToCircle({
    required String circleId,
    required List<ValidatedContact> contacts,
  }) async {
    for (final contact in contacts) {
      await inviteToCircle(circleId, contact);
    }
  }

  @override
  Future<void> removeMember(String circleId, String userIdToRemove) async {
    try {
      final currentUserId = _requiredUserId;

      // Check if the current user is an admin or the creator of the circle
      final circleData = await _supabase
          .from('circles')
          .select('created_by')
          .eq('id', circleId)
          .single();
      final creatorId = circleData['created_by'] as String;

      bool isAdmin = false;
      if (creatorId != currentUserId) { // Creator is always an admin
        final adminCheck = await _supabase
            .from('circle_members')
            .select('role')
            .eq('circle_id', circleId)
            .eq('user_id', currentUserId)
            .single();
        isAdmin = (adminCheck['role'] == 'admin');
      }

      // Only creator or admin can remove members, unless user is removing themselves
      if (creatorId == currentUserId || isAdmin || currentUserId == userIdToRemove) {
         // Prevent creator from being removed by other admins (creator can leave though)
        if (userIdToRemove == creatorId && currentUserId != creatorId) {
          throw Exception('Cannot remove the circle creator.');
        }
        await _supabase
            .from('circle_members')
            .delete()
            .eq('circle_id', circleId)
            .eq('user_id', userIdToRemove);
      } else {
        throw Exception('User does not have permission to remove members.');
      }
    } catch (e) {
      debugPrint('Error removing member: $e');
      rethrow;
    }
  }

  @override
  Future<void> leaveCircle(String circleId) async {
    try {
      final userId = _requiredUserId;
      // Check if the user is the creator, special handling might be needed
      // (e.g., assign new admin or delete circle if last member)
      // For now, just allow leaving.
      final circleData = await _supabase
          .from('circles')
          .select('created_by')
          .eq('id', circleId)
          .single();
      final creatorId = circleData['created_by'] as String;

      if (userId == creatorId) {
        // Optional: Add logic here if the creator leaves.
        // For example, check if there are other admins. If not, promote one or delete the circle.
        // This example just allows leaving.
        debugPrint("Circle creator is leaving. Consider transfer of ownership or deletion logic.");
      }

      await _supabase
          .from('circle_members')
          .delete()
          .eq('circle_id', circleId)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Error leaving circle: $e');
      rethrow;
    }
  }

  // Helper method to add user directly to circle
  Future<void> _addUserToCircle(String circleId, String userIdToInvite) async {
    // Check if user is already a member (to avoid duplicates or errors)
    final existingMember = await _supabase
        .from('circle_members')
        .select()
        .eq('circle_id', circleId)
        .eq('user_id', userIdToInvite)
        .maybeSingle();

    if (existingMember == null) {
      await _supabase.from('circle_members').insert({
        'circle_id': circleId,
        'user_id': userIdToInvite,
        // 'is_admin': false, // Default to non-admin when invited directly like this
        'role': 'member', // Use the 'role' column as defined in SQL
        'joined_at': DateTime.now().toIso8601String(),
      });
    } else {
      // User is already a member, you might want to log this or handle it
      debugPrint('User $userIdToInvite is already a member of circle $circleId.');
    }
  }
}

/// Circle service provider
final circleServiceProvider = Provider<CircleService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return CircleServiceImpl(supabase);
});

/// User circles provider
final userCirclesProvider = FutureProvider<List<Circle>>((ref) async {
  final circleService = ref.watch(circleServiceProvider);
  return circleService.getUserCircles();
});

/// Circle members provider - requires circleId parameter
final circleMembersProvider = FutureProvider.family<List<User>, String>((ref, circleId) async {
  final circleService = ref.watch(circleServiceProvider);
  return circleService.getCircleMembers(circleId);
});

/// Provider to get details of a specific circle
final circleDetailsProvider = FutureProvider.family<Circle, String>((ref, circleId) async {
  // This is a simplified version. You might need a dedicated service method if your
  // Circle model needs more data than what getUserCircles provides for a single circle.
  final circles = await ref.watch(userCirclesProvider.future);
  return circles.firstWhere((c) => c.id == circleId, orElse: () => throw Exception('Circle not found'));
});
