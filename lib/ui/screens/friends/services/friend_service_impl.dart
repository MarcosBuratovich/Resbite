import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:flutter_contacts/flutter_contacts.dart' as FlutterContactsPackage;
import '../../../../models/validated_contact.dart';
import '../../../../models/friend.dart';
import '../../../../models/user.dart' as app_user;
import '../../../../models/notification.dart';
import 'package:resbite_app/services/providers.dart' show supabaseClientProvider;
import 'package:resbite_app/services/notification_service.dart' show notificationServiceProvider;
import 'package:resbite_app/ui/screens/friends/services/services.dart' show circleServiceProvider, invitationServiceProvider;
import 'package:resbite_app/ui/screens/friends/services/circle_service.dart' show CircleService;
import 'package:resbite_app/ui/screens/friends/services/invitation_service.dart' show InvitationService;
import '../../../../utils/logger.dart';

/// Define a simple model for pending friend requests
/// This might be refined or moved to a separate models file later
class FriendRequest {
  final String connectionId; // The ID of the 'connections' table record
  final app_user.User requester; // Details of the user who sent the request
  final DateTime createdAt; // When the request was made

  FriendRequest({
    required this.connectionId,
    required this.requester,
    required this.createdAt,
  });
}

/// Service interface for friend-related operations
abstract class FriendService {
  /// Syncs device contacts with app
  Future<List<ValidatedContact>> syncContacts();

  /// Gets direct friends
  Future<List<FriendConnection>> getDirectFriends();

  /// Adds a user as a friend
  Future<void> addFriend(String userId);

  /// Adds a contact as a friend
  Future<void> addContactAsFriend(dynamic contact);

  /// Removes a friend
  Future<void> removeFriend(String connectionId);

  /// Utility to create validated contact from strings (for backward compatibility)
  ValidatedContact createContact({
    required String name,
    String? email,
    String? phone,
  });

  // Circle-related methods (now delegated to CircleService)
  /// Invites a contact to join a circle
  Future<void> inviteToCircle(String circleId, ValidatedContact contact);

  /// Creates a new circle
  Future<String> createCircle({
    required String name,
    required String description,
  });

  /// Invites multiple members to a circle
  Future<void> inviteMultipleToCircle({
    required String circleId,
    required List<ValidatedContact> contacts,
  });

  // Invitation-related methods (now delegated to InvitationService)
  /// Invites a contact to join the app
  Future<void> inviteContactToApp(dynamic contact);

  /// Gets network connections (friends of friends)
  Future<List<NetworkConnection>> getNetworkConnections();

  // New methods for friend request management
  Future<List<FriendRequest>> getPendingFriendRequests();
  Future<void> acceptFriendRequest(String connectionId);
  Future<void> declineFriendRequest(String connectionId);
}

/// Implementation of FriendService
class FriendServiceImpl implements FriendService {
  final SupabaseClient _supabase;
  final CircleService _circleService;
  final InvitationService _invitationService;
  final Ref _ref;

  FriendServiceImpl(
    this._supabase,
    this._circleService,
    this._invitationService,
    this._ref,
  );

  /// Gets the current Supabase user ID (UUID)
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Get the current user ID or throw error if not authenticated
  String get _requiredUserId {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return userId;
  }

  @override
  Future<List<ValidatedContact>> syncContacts() async {
    List<ValidatedContact> syncedContacts = [];

    if (await FlutterContactsPackage.FlutterContacts.requestPermission()) {
      List<FlutterContactsPackage.Contact> deviceContacts =
          await FlutterContactsPackage.FlutterContacts.getContacts(
            withProperties: true, // Fetches phone numbers, emails, etc.
            withPhoto: false, // Optionally fetch photo, can be slow
          );

      for (var deviceContact in deviceContacts) {
        if (deviceContact.phones.isNotEmpty) {
          String? resbiteUserId;
          app_user.User? foundUser;

          // Attempt to find a Resbite user by any of the contact's phone numbers
          for (var phone in deviceContact.phones) {
            if (phone.number.isNotEmpty) {
              // Basic normalization: remove non-digits. Consider more robust normalization.
              String normalizedPhone = phone.number.replaceAll(
                RegExp(r'\D'),
                '',
              );
              if (normalizedPhone.isEmpty) continue;

              try {
                final response =
                    await _supabase
                        .from('users')
                        .select(
                          'id, display_name, email, phone_number, profile_image_url',
                        ) // Assuming 'id' is the primary user ID
                        .filter(
                          'phone_number',
                          'in',
                          [normalizedPhone, '+\$normalizedPhone'],
                        )
                        .maybeSingle();

                if (response != null) {
                  foundUser = app_user.User.fromSupabase(response);
                  resbiteUserId =
                      foundUser.id; // Use the 'id' from the users table
                  break; // Found a match, no need to check other numbers for this contact
                }
              } catch (e) {
                // Log error, e.g., to your AppLogger
                debugPrint('Error querying user by phone $normalizedPhone: $e');
              }
            }
          }

          syncedContacts.add(
            ValidatedContact(
              id:
                  resbiteUserId ??
                  deviceContact
                      .id, // Use Resbite user ID if found, else device contact ID
              name: deviceContact.displayName,
              contactInfo: ContactInfo(
                email:
                    deviceContact.emails.isNotEmpty
                        ? deviceContact.emails.first.address
                        : null,
                phone: deviceContact.phones.first.number, // Primary phone
                displayName: deviceContact.displayName,
              ),
            ),
          );
        } else {
          // Handle contacts with no phone numbers if necessary, or skip them
          // For now, we are only interested in contacts with phone numbers
        }
      }
    }
    return syncedContacts;
  }

  @override
  Future<void> inviteToCircle(String circleId, ValidatedContact contact) async {
    // Delegate to circle service
    await _circleService.inviteToCircle(circleId, contact);
  }

  @override
  Future<String> createCircle({
    required String name,
    required String description,
  }) async {
    // Delegate to circle service
    return await _circleService.createCircle(
      name: name,
      description: description,
    );
  }

  @override
  Future<void> inviteMultipleToCircle({
    required String circleId,
    required List<ValidatedContact> contacts,
  }) async {
    // Delegate to circle service
    await _circleService.inviteMultipleToCircle(
      circleId: circleId,
      contacts: contacts,
    );
  }

  @override
  Future<List<FriendConnection>> getDirectFriends() async {
    AppLogger.debug('FriendServiceImpl: getDirectFriends called');
    final currentUserId = _requiredUserId;
    List<FriendConnection> friends = [];

    try {
      // Query connections where current user is user_id and status is connected
      final response1 = await _supabase
          .from('connections')
          .select(
            '*, friend_profile:connected_user_id(*)',
          ) // Fetch friend's profile
          .eq('user_id', currentUserId)
          .eq('status', 'connected');

      for (var row in response1) {
        if (row['friend_profile'] != null) {
          friends.add(
            FriendConnection.fromSupabase(row, row['friend_profile']),
          );
        }
      }

      // Query connections where current user is connected_user_id and status is connected
      final response2 = await _supabase
          .from('connections')
          .select('*, friend_profile:user_id(*)') // Fetch friend's profile
          .eq('connected_user_id', currentUserId)
          .eq('status', 'connected');

      for (var row in response2) {
        if (row['friend_profile'] != null) {
          // Ensure we don't add duplicates if a reflexive relationship was somehow added (should not happen with unique constraint)
          if (!friends.any((f) => f.user.id == row['friend_profile']['id'])) {
            friends.add(
              FriendConnection.fromSupabase(row, row['friend_profile']),
            );
          }
        }
      }

      AppLogger.debug(
        'Found ${friends.length} direct friends for user $currentUserId',
      );
      return friends;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error fetching direct friends for user $currentUserId',
        e,
        stackTrace,
      );
      return [];
    }
  }

  /// Create a ValidatedContact from basic contact information
  @override
  ValidatedContact createContact({
    required String name,
    String? email,
    String? phone,
  }) {
    // Delegate to invitation service
    return _invitationService.createContact(
      name: name,
      email: email,
      phone: phone,
    );
  }

  @override
  Future<void> inviteContactToApp(dynamic contact) async {
    // Delegate to invitation service
    await _invitationService.inviteContactToApp(contact);
  }

  @override
  Future<void> addFriend(String friendUserId) async {
    AppLogger.debug('FriendServiceImpl: addFriend called for $friendUserId');
    final currentUserId = _requiredUserId;

    if (currentUserId == friendUserId) {
      AppLogger.warning('User tried to add themselves as a friend.');
      throw Exception('You cannot add yourself as a friend.');
    }

    try {
      // Check if a connection already exists (pending, accepted, or declined)
      final existingConnection =
          await _supabase
              .from('connections')
              .select('id, status')
              .or(
                'and(user_id.eq.$currentUserId,connected_user_id.eq.$friendUserId),and(user_id.eq.$friendUserId,connected_user_id.eq.$currentUserId)',
              )
              .maybeSingle();

      if (existingConnection != null) {
        final status = existingConnection['status'];
        if (status == 'connected') {
          AppLogger.info(
            'Friendship with $friendUserId already exists and is connected.',
          );
          throw Exception('You are already friends with this user.');
        } else if (status == 'pending') {
          AppLogger.info(
            'Friend request with $friendUserId is already pending.',
          );
          throw Exception(
            'A friend request is already pending with this user.',
          );
        } else if (status == 'declined') {
          // If declined, perhaps allow a new request or resend? For now, let's allow creating a new one.
          // Or update the existing one to pending if that's the desired logic.
          // This example assumes we can create a new request if one was declined by either party.
          // If the user_id, connected_user_id constraint is strictly enforced and a declined record exists, this insert might fail.
          // A more robust approach might be to update the status of the declined record if it exists and was initiated by the other party,
          // or delete and re-insert if the policy is to allow re-requesting after a decline.
        }
      }

      // Create pending friend connection and notify recipient
      final inserted = await _supabase
          .from('connections')
          .insert({
            'user_id': currentUserId,
            'connected_user_id': friendUserId,
            'status': 'pending',
          })
          .select('id')
          .single();
      final connectionId = inserted['id'] as String;
      AppLogger.debug(
        'Friend request sent (pending) to $friendUserId from $currentUserId, id $connectionId',
      );
      final notificationService = _ref.read(notificationServiceProvider);
      await notificationService.sendNotification(
        userId: friendUserId,
        type: NotificationType.friendInvite,
        payload: {'connection_id': connectionId, 'sender_id': currentUserId},
        status: NotificationStatus.pending,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error sending friend request to $friendUserId',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> addContactAsFriend(dynamic contact) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) throw Exception('User not authenticated');
    await addFriend((contact as app_user.User).id);
  }

  @override
  Future<void> removeFriend(String connectionId) async {
    AppLogger.debug(
      'FriendServiceImpl: removeFriend called for connection $connectionId',
    );
    final currentUserId = _requiredUserId;
    try {
      // Verify the current user is part of this connection before deleting
      final connectionCheck =
          await _supabase
              .from('connections')
              .select('id, user_id, connected_user_id')
              .eq('id', connectionId)
              .or(
                'user_id.eq.$currentUserId,connected_user_id.eq.$currentUserId',
              )
              .maybeSingle();

      if (connectionCheck == null) {
        throw Exception(
          'Connection not found or user not authorized to remove this friend.',
        );
      }

      await _supabase.from('connections').delete().eq('id', connectionId);
      AppLogger.debug('Connection $connectionId removed.');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error removing friend from connection $connectionId',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<NetworkConnection>> getNetworkConnections() async {
    try {
      // Get all device contacts
      final deviceContacts = await FlutterContactsPackage.FlutterContacts.getContacts(
        withProperties: true, // Fetches phone numbers, emails, etc.
        withPhoto: false, // Optionally fetch photo, can be slow
      );

      // If no contacts, return empty list
      if (deviceContacts.isEmpty) {
        return [];
      }

      // Get current user ID to create temporary users for non-Resbite contacts
      final userId = _currentUserId;
      if (userId == null) {
        debugPrint('Cannot get network connections: User not authenticated');
        return [];
      }

      // Convert to NetworkConnection objects
      final List<NetworkConnection> connections = [];

      for (final contact in deviceContacts) {
        // Create placeholder network connection for each device contact
        final phoneNumber =
            contact.phones.isNotEmpty ? contact.phones.first.number : '';
        final email =
            contact.emails.isNotEmpty ? contact.emails.first.address : '';

        final contactUser = app_user.User(
          id: contact.id,
          email: email,
          displayName: contact.displayName,
          phoneNumber: phoneNumber,
        );

        final mutualFriend = app_user.User(
          id: userId,
          email: 'current.user@example.com', // Placeholder
          displayName: 'You',
        );

        connections.add(
          NetworkConnection(
            user: contactUser,
            mutualFriend: mutualFriend,
            mutualFriendsCount: 0,
          ),
        );
      }
      return connections;
    } catch (e) {
      debugPrint('Error getting network connections: $e');
      return [];
    }
  }

  @override
  Future<List<FriendRequest>> getPendingFriendRequests() async {
    final currentUserId = _requiredUserId;
    try {
      final response = await _supabase
          .from('connections')
          .select('id,created_at,requester:user_id(*)')
          .eq('connected_user_id', currentUserId)
          .eq('status', 'pending');
      return (response as List<dynamic>)
          .map((json) {
        final requesterJson = json['requester'] as Map<String, dynamic>;
        final requester = app_user.User.fromSupabase(requesterJson);
        final createdAt = DateTime.parse(json['created_at'] as String);
        return FriendRequest(
          connectionId: json['id'] as String,
          requester: requester,
          createdAt: createdAt,
        );
      }).toList();
    } catch (e, s) {
      AppLogger.error('Error fetching pending friend requests', e, s);
      return [];
    }
  }

  @override
  Future<void> acceptFriendRequest(String connectionId) async {
    final currentUserId = _requiredUserId;
    try {
      final conn = await _supabase
          .from('connections')
          .select('user_id')
          .eq('id', connectionId)
          .eq('connected_user_id', currentUserId)
          .single();
      final requesterId = conn['user_id'] as String;
      await _supabase
          .from('connections')
          .update({'status': 'connected'})
          .eq('id', connectionId);
      final notificationService = _ref.read(notificationServiceProvider);
      await notificationService.sendNotification(
        userId: requesterId,
        type: NotificationType.friendInvite,
        payload: {'connection_id': connectionId, 'recipient_id': currentUserId},
        status: NotificationStatus.accepted,
      );
    } catch (e, s) {
      AppLogger.error('Error accepting friend request', e, s);
      rethrow;
    }
  }

  @override
  Future<void> declineFriendRequest(String connectionId) async {
    final currentUserId = _requiredUserId;
    try {
      final conn = await _supabase
          .from('connections')
          .select('user_id')
          .eq('id', connectionId)
          .eq('connected_user_id', currentUserId)
          .single();
      final requesterId = conn['user_id'] as String;
      await _supabase
          .from('connections')
          .update({'status': 'declined'})
          .eq('id', connectionId);
      final notificationService = _ref.read(notificationServiceProvider);
      await notificationService.sendNotification(
        userId: requesterId,
        type: NotificationType.friendInvite,
        payload: {'connection_id': connectionId, 'recipient_id': currentUserId},
        status: NotificationStatus.declined,
      );
    } catch (e, s) {
      AppLogger.error('Error declining friend request', e, s);
      rethrow;
    }
  }
}

/// Provider for the FriendService implementation
final friendServiceImplProvider = Provider<FriendService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final circleService = ref.watch(circleServiceProvider);
  final invitationService = ref.watch(invitationServiceProvider);
  return FriendServiceImpl(supabase, circleService, invitationService, ref);
});

/// Alias for backwards compatibility - allows old code to keep working
final friendServiceProvider = friendServiceImplProvider;

/// Provider for synced contacts
final syncedContactsProvider = FutureProvider<List<ValidatedContact>>((
  ref,
) async {
  final friendService = ref.watch(friendServiceImplProvider);
  return await friendService.syncContacts();
});

/// Direct friends provider, renamed to avoid conflicts
final directFriendsListProvider = FutureProvider<List<FriendConnection>>((
  ref,
) async {
  final friendService = ref.watch(friendServiceImplProvider);
  return await friendService.getDirectFriends();
});

/// Provider for incoming pending friend requests
final pendingFriendRequestsProvider = FutureProvider<List<FriendRequest>>((ref) async {
  final friendService = ref.watch(friendServiceProvider);
  return await friendService.getPendingFriendRequests();
});

/// Original direct friends provider name for backwards compatibility
final directFriendsProvider = directFriendsListProvider;

/// Provider for network connections (friends of friends)
final networkConnectionsProvider = FutureProvider<List<NetworkConnection>>((
  ref,
) async {
  final friendService = ref.watch(friendServiceProvider);
  return friendService.getNetworkConnections();
});
