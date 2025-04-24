import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/friend_circle.dart';
import '../services/contact_service.dart';
import '../services/providers.dart';
import '../utils/logger.dart';

// All providers are now defined in providers.dart

/// Service for managing friend relationships and circles
class FriendService {
  final Ref _ref;

  FriendService(this._ref);
  
  // Current user ID (would be fetched from authentication in a real app)
  String get _currentUserId {
    // Try to get actual user ID from auth service
    final authService = _ref.read(authServiceProvider);
    final currentUser = authService.currentUser;
    return currentUser?.id ?? 'current-user-id';
  }
  
  // Mock data
  final _mockUsers = <String, User>{
    'current-user-id': User(
      id: 'current-user-id',
      email: 'current.user@example.com',
      displayName: 'Current User',
      profileImageUrl: 'https://i.pravatar.cc/150?img=1',
    ),
    'user-1': User(
      id: 'user-1',
      email: 'sarah.j@example.com',
      displayName: 'Sarah Johnson',
      profileImageUrl: 'https://i.pravatar.cc/150?img=5',
    ),
    'user-2': User(
      id: 'user-2',
      email: 'mike.r@example.com',
      displayName: 'Michael Rodriguez',
      profileImageUrl: 'https://i.pravatar.cc/150?img=3',
    ),
    'user-3': User(
      id: 'user-3',
      email: 'emma.w@example.com',
      displayName: 'Emma Wilson',
      profileImageUrl: 'https://i.pravatar.cc/150?img=8',
    ),
    'user-4': User(
      id: 'user-4',
      email: 'david.l@example.com',
      displayName: 'David Lee',
      profileImageUrl: 'https://i.pravatar.cc/150?img=4',
    ),
    'user-5': User(
      id: 'user-5',
      email: 'alex.k@example.com',
      displayName: 'Alex Kim',
      profileImageUrl: 'https://i.pravatar.cc/150?img=7',
    ),
  };
  
  final _mockFriendConnections = <FriendConnection>[
    // Direct friends
    FriendConnection(
      id: 'conn-1',
      user: User(
        id: 'user-1',
        email: 'sarah.j@example.com',
        displayName: 'Sarah Johnson',
        profileImageUrl: 'https://i.pravatar.cc/150?img=5',
      ),
      level: ConnectionLevel.direct,
      connectedAt: DateTime.now().subtract(const Duration(days: 120)),
      isFavorite: true,
      groupIds: ['circle-1', 'circle-2'],
    ),
    FriendConnection(
      id: 'conn-2',
      user: User(
        id: 'user-2',
        email: 'mike.r@example.com',
        displayName: 'Michael Rodriguez',
        profileImageUrl: 'https://i.pravatar.cc/150?img=3',
      ),
      level: ConnectionLevel.direct,
      connectedAt: DateTime.now().subtract(const Duration(days: 90)),
      groupIds: ['circle-1'],
    ),
    // Friends of friends
    FriendConnection(
      id: 'conn-3',
      user: User(
        id: 'user-3',
        email: 'emma.w@example.com',
        displayName: 'Emma Wilson',
        profileImageUrl: 'https://i.pravatar.cc/150?img=8',
      ),
      level: ConnectionLevel.secondDegree,
      connectedThrough: 'user-1', // Connected through Sarah
      connectedAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    FriendConnection(
      id: 'conn-4',
      user: User(
        id: 'user-4',
        email: 'david.l@example.com',
        displayName: 'David Lee',
        profileImageUrl: 'https://i.pravatar.cc/150?img=4',
      ),
      level: ConnectionLevel.secondDegree,
      connectedThrough: 'user-2', // Connected through Michael
      connectedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    // 3rd degree connections
    FriendConnection(
      id: 'conn-5',
      user: User(
        id: 'user-5',
        email: 'alex.k@example.com',
        displayName: 'Alex Kim',
        profileImageUrl: 'https://i.pravatar.cc/150?img=7',
      ),
      level: ConnectionLevel.thirdDegree,
      connectedThrough: 'user-3', // Connected through Emma, who is connected through Sarah
      connectedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];
  
  final _mockFriendCircles = <FriendCircle>[
    FriendCircle(
      id: 'circle-1',
      name: 'Close Friends',
      description: 'My closest friends',
      createdBy: 'current-user-id',
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
      adminIds: ['current-user-id'],
      memberIds: ['user-1', 'user-2'],
      isPrivate: true,
    ),
    FriendCircle(
      id: 'circle-2',
      name: 'Family',
      description: 'Family members',
      createdBy: 'current-user-id',
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      adminIds: ['current-user-id'],
      memberIds: ['user-1'],
      isPrivate: true,
    ),
    FriendCircle(
      id: 'circle-3',
      name: 'Sports Buddies',
      description: 'Friends for sports activities',
      createdBy: 'user-2',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      adminIds: ['user-2'],
      memberIds: ['current-user-id', 'user-4'],
      pendingInviteIds: ['user-3'],
      isPrivate: false,
    ),
  ];
  
  final _mockInvitations = <CircleInvitation>[
    CircleInvitation(
      id: 'invite-1',
      circleId: 'circle-3',
      inviterId: 'user-2',
      inviteeId: 'user-3',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      message: 'Hey Emma, join our sports group!',
      status: InvitationStatus.pending,
    ),
    CircleInvitation(
      id: 'invite-2',
      circleId: 'circle-4',
      inviterId: 'user-5',
      inviteeId: 'current-user-id',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      message: 'Join my book club circle!',
      status: InvitationStatus.pending,
    ),
  ];
  
  /// Get the current user's direct friends
  Future<List<FriendConnection>> getDirectFriends() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Filter for direct friends only
      return _mockFriendConnections
          .where((conn) => conn.level == ConnectionLevel.direct)
          .toList();
    } catch (e) {
      AppLogger.error('Error getting direct friends', e);
      return [];
    }
  }
  
  /// Get the current user's extended network (2nd and 3rd degree connections)
  Future<List<FriendConnection>> getExtendedNetwork() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Filter for 2nd and 3rd degree connections
      return _mockFriendConnections
          .where((conn) => 
              conn.level == ConnectionLevel.secondDegree || 
              conn.level == ConnectionLevel.thirdDegree)
          .toList();
    } catch (e) {
      AppLogger.error('Error getting extended network', e);
      return [];
    }
  }
  
  /// Get all friend circles for the current user
  Future<List<FriendCircle>> getFriendCircles() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 900));
      
      // Filter for circles where the user is a member or admin
      return _mockFriendCircles
          .where((circle) => 
              circle.createdBy == _currentUserId || 
              circle.adminIds.contains(_currentUserId) ||
              circle.memberIds.contains(_currentUserId))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting friend circles', e);
      return [];
    }
  }
  
  /// Get a specific friend circle by ID
  Future<FriendCircle?> getFriendCircleById(String circleId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Find the circle
      return _mockFriendCircles
          .firstWhere((circle) => circle.id == circleId, 
              orElse: () => throw Exception('Circle not found'));
    } catch (e) {
      AppLogger.error('Error getting friend circle by ID', e);
      return null;
    }
  }
  
  /// Get pending invitations for the current user
  Future<List<CircleInvitation>> getPendingInvitations() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Filter for pending invitations for the current user
      return _mockInvitations
          .where((invite) => 
              invite.inviteeId == _currentUserId && 
              invite.status == InvitationStatus.pending)
          .toList();
    } catch (e) {
      AppLogger.error('Error getting pending invitations', e);
      return [];
    }
  }
  
  /// Add a new friend
  Future<FriendConnection?> addFriend(String userId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1200));
      
      // Check if user exists
      final user = _mockUsers[userId];
      if (user == null) {
        throw Exception('User not found');
      }
      
      // Check if already friends
      final existingConn = _mockFriendConnections
          .where((conn) => conn.user.id == userId && conn.level == ConnectionLevel.direct)
          .toList();
      
      if (existingConn.isNotEmpty) {
        throw Exception('Already friends with this user');
      }
      
      // Create new connection
      final newConn = FriendConnection(
        id: 'conn-new-${const Uuid().v4()}',
        user: user,
        level: ConnectionLevel.direct,
        connectedAt: DateTime.now(),
      );
      
      // Would save to database in a real implementation
      _mockFriendConnections.add(newConn);
      
      return newConn;
    } catch (e) {
      AppLogger.error('Error adding friend', e);
      return null;
    }
  }
  
  /// Create a new friend circle
  Future<FriendCircle?> createFriendCircle({
    required String name, 
    String description = '', 
    bool isPrivate = false,
    List<String> initialMemberIds = const [],
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1200));
      
      // Create new circle
      final newCircle = FriendCircle(
        id: 'circle-new-${const Uuid().v4()}',
        name: name,
        description: description,
        createdBy: _currentUserId,
        createdAt: DateTime.now(),
        adminIds: [_currentUserId],
        memberIds: initialMemberIds,
        isPrivate: isPrivate,
      );
      
      // Would save to database in a real implementation
      _mockFriendCircles.add(newCircle);
      
      return newCircle;
    } catch (e) {
      AppLogger.error('Error creating friend circle', e);
      return null;
    }
  }
  
  /// Invite a user to a friend circle
  Future<CircleInvitation?> inviteToCircle({
    required String circleId,
    required String userId,
    String? message,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Check if circle exists
      final circle = _mockFriendCircles
          .firstWhere((c) => c.id == circleId, 
              orElse: () => throw Exception('Circle not found'));
      
      // Check if user exists
      final user = _mockUsers[userId];
      if (user == null) {
        throw Exception('User not found');
      }
      
      // Check if user is already a member
      if (circle.memberIds.contains(userId) || 
          circle.adminIds.contains(userId) || 
          circle.createdBy == userId) {
        throw Exception('User is already a member of this circle');
      }
      
      // Check if invitation already exists
      final existingInvite = _mockInvitations
          .where((i) => 
              i.circleId == circleId && 
              i.inviteeId == userId && 
              i.status == InvitationStatus.pending)
          .toList();
      
      if (existingInvite.isNotEmpty) {
        throw Exception('User has already been invited to this circle');
      }
      
      // Create new invitation
      final newInvite = CircleInvitation(
        id: 'invite-new-${const Uuid().v4()}',
        circleId: circleId,
        inviterId: _currentUserId,
        inviteeId: userId,
        createdAt: DateTime.now(),
        message: message,
        status: InvitationStatus.pending,
      );
      
      // Would save to database in a real implementation
      _mockInvitations.add(newInvite);
      
      // Update pending invites list in circle
      final updatedCircle = circle.copyWith(
        pendingInviteIds: [...circle.pendingInviteIds, userId],
      );
      
      // Update the circle in the mock data
      final index = _mockFriendCircles.indexWhere((c) => c.id == circleId);
      if (index >= 0) {
        _mockFriendCircles[index] = updatedCircle;
      }
      
      return newInvite;
    } catch (e) {
      AppLogger.error('Error inviting to circle', e);
      return null;
    }
  }
  
  /// Accept a circle invitation
  Future<bool> acceptInvitation(String invitationId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Find the invitation
      final index = _mockInvitations.indexWhere((i) => i.id == invitationId);
      if (index < 0) {
        throw Exception('Invitation not found');
      }
      
      final invitation = _mockInvitations[index];
      
      // Check if the invitation is for the current user
      if (invitation.inviteeId != _currentUserId) {
        throw Exception('Invitation is not for the current user');
      }
      
      // Check if the invitation is still pending
      if (invitation.status != InvitationStatus.pending) {
        throw Exception('Invitation is not pending');
      }
      
      // Update invitation status
      final updatedInvitation = invitation.copyWith(
        status: InvitationStatus.accepted,
      );
      
      _mockInvitations[index] = updatedInvitation;
      
      // Find the circle
      final circleIndex = _mockFriendCircles.indexWhere((c) => c.id == invitation.circleId);
      if (circleIndex < 0) {
        throw Exception('Circle not found');
      }
      
      final circle = _mockFriendCircles[circleIndex];
      
      // Add user to circle members
      final updatedCircle = circle.copyWith(
        memberIds: [...circle.memberIds, _currentUserId],
        pendingInviteIds: circle.pendingInviteIds.where((id) => id != _currentUserId).toList(),
      );
      
      _mockFriendCircles[circleIndex] = updatedCircle;
      
      return true;
    } catch (e) {
      AppLogger.error('Error accepting invitation', e);
      return false;
    }
  }
  
  /// Decline a circle invitation
  Future<bool> declineInvitation(String invitationId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Find the invitation
      final index = _mockInvitations.indexWhere((i) => i.id == invitationId);
      if (index < 0) {
        throw Exception('Invitation not found');
      }
      
      final invitation = _mockInvitations[index];
      
      // Check if the invitation is for the current user
      if (invitation.inviteeId != _currentUserId) {
        throw Exception('Invitation is not for the current user');
      }
      
      // Check if the invitation is still pending
      if (invitation.status != InvitationStatus.pending) {
        throw Exception('Invitation is not pending');
      }
      
      // Update invitation status
      final updatedInvitation = invitation.copyWith(
        status: InvitationStatus.declined,
      );
      
      _mockInvitations[index] = updatedInvitation;
      
      // Find the circle
      final circleIndex = _mockFriendCircles.indexWhere((c) => c.id == invitation.circleId);
      if (circleIndex < 0) {
        throw Exception('Circle not found');
      }
      
      final circle = _mockFriendCircles[circleIndex];
      
      // Remove user from pending invites
      final updatedCircle = circle.copyWith(
        pendingInviteIds: circle.pendingInviteIds.where((id) => id != _currentUserId).toList(),
      );
      
      _mockFriendCircles[circleIndex] = updatedCircle;
      
      return true;
    } catch (e) {
      AppLogger.error('Error declining invitation', e);
      return false;
    }
  }
  
  /// Remove a friend
  Future<bool> removeFriend(String userId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Find the connection
      final connectionIndex = _mockFriendConnections.indexWhere(
        (conn) => conn.user.id == userId && conn.level == ConnectionLevel.direct);
      
      if (connectionIndex < 0) {
        throw Exception('Friend connection not found');
      }
      
      // Remove the connection
      _mockFriendConnections.removeAt(connectionIndex);
      
      // Real implementation would also:
      // 1. Remove user from all personal circles
      // 2. Update the trust graph
      
      return true;
    } catch (e) {
      AppLogger.error('Error removing friend', e);
      return false;
    }
  }
  
  /// Leave a friend circle
  Future<bool> leaveCircle(String circleId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 900));
      
      // Find the circle
      final circleIndex = _mockFriendCircles.indexWhere((c) => c.id == circleId);
      if (circleIndex < 0) {
        throw Exception('Circle not found');
      }
      
      final circle = _mockFriendCircles[circleIndex];
      
      // Check if user is the creator
      if (circle.createdBy == _currentUserId) {
        throw Exception('Creator cannot leave the circle. Delete it instead.');
      }
      
      // Update circle members and admins
      final updatedCircle = circle.copyWith(
        memberIds: circle.memberIds.where((id) => id != _currentUserId).toList(),
        adminIds: circle.adminIds.where((id) => id != _currentUserId).toList(),
      );
      
      _mockFriendCircles[circleIndex] = updatedCircle;
      
      return true;
    } catch (e) {
      AppLogger.error('Error leaving circle', e);
      return false;
    }
  }

  /// Sync device contacts with app users
  Future<List<dynamic>> syncDeviceContacts() async {
    try {
      // Get contact service
      final contactService = _ref.read(contactServiceProvider);
      
      // Check if we have contacts permission
      final hasPermission = await contactService.hasContactsPermission();
      if (!hasPermission) {
        final granted = await contactService.requestContactsPermission();
        if (!granted) {
          throw Exception('Contacts permission not granted');
        }
      }
      
      // Sync contacts with database
      final matchedUsers = await contactService.syncContactsWithDatabase();
      AppLogger.info('Found ${matchedUsers.length} contacts who are Resbite users');
      
      // Get all contacts
      final contacts = await contactService.getContacts();
      
      // Process these contacts for display
      final processedContacts = _processContactsForDisplay(contacts, matchedUsers);
      
      // Update friend suggestions based on contacts
      _updateFriendSuggestions(processedContacts);
      
      return processedContacts;
    } catch (e) {
      AppLogger.error('Error syncing device contacts', e);
      return [];
    }
  }
  
  /// Add a contact as a friend directly from the contacts list
  Future<bool> addContactAsFriend(String resbiteUserId) async {
    try {
      // Get contact service
      final contactService = _ref.read(contactServiceProvider);
      
      // Add user as friend
      final success = await contactService.addContactAsFriend(resbiteUserId);
      
      if (success) {
        // Refresh friends list
        // In a real app, this would trigger a database refresh
        // For this mock implementation, simulate adding to mock data
        final user = _mockUsers[resbiteUserId];
        if (user != null) {
          final newConn = FriendConnection(
            id: 'conn-new-${const Uuid().v4()}',
            user: user,
            level: ConnectionLevel.direct,
            connectedAt: DateTime.now(),
          );
          
          _mockFriendConnections.add(newConn);
        }
      }
      
      return success;
    } catch (e) {
      AppLogger.error('Error adding contact as friend', e);
      return false;
    }
  }
  
  /// Invite a non-Resbite user to the app
  Future<bool> inviteContactToApp(dynamic contact) async {
    try {
      // Verify this is not a Resbite user before inviting
      if (contact is Map<String, dynamic> && (contact['isResbiteUser'] == true)) {
        AppLogger.info('Cannot invite: Contact is already a Resbite user');
        return false;
      }
      
      final contactService = _ref.read(contactServiceProvider);
      return await contactService.inviteContact(contact);
    } catch (e, stack) {
      AppLogger.error('Error inviting contact to app', e, stack);
      return false;
    }
  }
  
  /// Process contacts for display in the UI
  List<Map<String, dynamic>> _processContactsForDisplay(List<PhoneContact> contacts, List<User> matchedUsers) {
    // Sort contacts: Resbite users first, then alphabetically by name
    contacts.sort((a, b) {
      // First sort by Resbite user status
      if (a.isResbiteUser && !b.isResbiteUser) return -1;
      if (!a.isResbiteUser && b.isResbiteUser) return 1;
      
      // Then sort alphabetically
      return a.displayName.compareTo(b.displayName);
    });
    
    // Convert to maps for easier UI handling
    return contacts.map<Map<String, dynamic>>((contact) {
      // Find the matched user if this is a Resbite user
      User? matchedUser;
      if (contact.isResbiteUser && contact.resbiteUserId != null) {
        try {
          matchedUser = matchedUsers.firstWhere(
            (user) => user.id == contact.resbiteUserId,
          );
        } catch (_) {
          // No matching user found
          matchedUser = null;
        }
      }
      
      return {
        'id': contact.id,
        'displayName': contact.displayName,
        'phoneNumbers': contact.phoneNumbers,
        'emails': contact.emails,
        'isResbiteUser': contact.isResbiteUser,
        'resbiteUserId': contact.resbiteUserId,
        'profileImageUrl': matchedUser?.profileImageUrl,
        'alreadyFriend': matchedUser != null ? _isAlreadyFriend(matchedUser.id) : false,
      };
    }).toList();
  }
  
  /// Update friend suggestions based on contacts
  void _updateFriendSuggestions(List<Map<String, dynamic>> contacts) {
    try {
      // Find Resbite users who aren't already friends
      final suggestions = contacts.where((contact) {
        return contact['isResbiteUser'] == true && 
               contact['alreadyFriend'] == false && 
               contact['resbiteUserId'] != null;
      }).toList();
      
      if (suggestions.isEmpty) {
        AppLogger.info('No new friend suggestions found from contacts');
        return;
      }
      
      // In a real implementation, you'd store these suggestions
      // For now, just log the count
      AppLogger.info('Found ${suggestions.length} new friend suggestions from contacts');
    } catch (e, stack) {
      AppLogger.error('Error updating friend suggestions', e, stack);
    }
  }
  
  /// Check if a user is already a friend
  bool _isAlreadyFriend(String userId) {
    // Check if the user is already in direct friends
    return _mockFriendConnections.any((conn) => 
      conn.level == ConnectionLevel.direct && conn.user.id == userId
    );
  }
}