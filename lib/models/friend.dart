import 'package:resbite_app/models/user.dart';

/// Represents a friend connection between two users
class FriendConnection {
  /// The connected user
  final User user;
  
  /// When the friendship was established
  final DateTime connectedAt;
  
  /// Number of shared circles with this friend
  final int sharedCirclesCount;
  
  /// Mutual friends count
  final int mutualFriendsCount;

  /// Creates a new friend connection
  const FriendConnection({
    required this.user,
    required this.connectedAt,
    this.sharedCirclesCount = 0,
    this.mutualFriendsCount = 0,
  });

  factory FriendConnection.fromSupabase(Map<String, dynamic> connectionData, Map<String, dynamic> friendProfileData) {
    return FriendConnection(
      user: User.fromSupabase(friendProfileData),
      connectedAt: DateTime.parse(connectionData['updated_at'] ?? connectionData['created_at'] ?? DateTime.now().toIso8601String()), // Use updated_at (when accepted) or created_at
      // sharedCirclesCount and mutualFriendsCount would require more complex queries.
      // Defaulting to 0 for now.
      sharedCirclesCount: 0, 
      mutualFriendsCount: 0,
    );
  }
}

/// Represents a contact from the user's phone contacts
class Contact {
  /// Contact's name
  final String name;
  
  /// Contact's phone number
  final String phoneNumber;
  
  /// Contact's email address
  final String? email;
  
  /// Whether the contact is already a Resbite user
  final bool isResbiteUser;
  
  /// User ID if the contact is a Resbite user
  final String? userId;

  /// Creates a new contact
  const Contact({
    required this.name,
    required this.phoneNumber,
    this.email,
    this.isResbiteUser = false,
    this.userId,
  });
}

/// Represents a second-degree connection (friend of friend)
class NetworkConnection {
  /// The connected user
  final User user;
  
  /// The mutual friend that connects both users
  final User mutualFriend;
  
  /// Number of mutual friends
  final int mutualFriendsCount;

  /// Creates a new network connection
  const NetworkConnection({
    required this.user,
    required this.mutualFriend,
    this.mutualFriendsCount = 1,
  });
}
