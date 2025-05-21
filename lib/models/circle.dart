

/// Represents a friend circle that groups friends together
class Circle {
  /// Unique identifier for the circle
  final String id;
  
  /// Name of the circle
  final String name;
  
  /// Optional description of the circle
  final String description;
  
  /// Whether the circle is private (invitation only) or public
  final bool isPrivate;
  
  /// User ID who created the circle
  final String createdBy;
  
  /// When the circle was created
  final DateTime createdAt;
  
  /// IDs of users who are admins of this circle
  final List<String> adminIds;
  
  /// IDs of users who are members of this circle
  final List<String> memberIds;
  
  /// IDs of users who have pending invitations to join this circle
  final List<String> pendingInviteIds;
  
  /// Total count of all members (including admins)
  int get memberCount => memberIds.length + adminIds.length + 1; // +1 for creator

  /// Creates a new circle
  const Circle({
    required this.id,
    required this.name,
    this.description = '',
    required this.isPrivate,
    required this.createdBy,
    required this.createdAt,
    this.adminIds = const [],
    this.memberIds = const [],
    this.pendingInviteIds = const [],
  });
  
  /// Checks if a user is an admin of this circle
  bool isAdmin(String userId) {
    return createdBy == userId || adminIds.contains(userId);
  }
  
  /// Checks if a user is a member of this circle
  bool isMember(String userId) {
    return memberIds.contains(userId);
  }
}

/// Represents an invitation to join a circle
class CircleInvitation {
  /// Unique identifier for the invitation
  final String id;
  
  /// ID of the circle this invitation is for
  final String circleId;
  
  /// Name of the circle (cached for display purposes)
  final String circleName;
  
  /// Whether the circle is private
  final bool isCirclePrivate;
  
  /// ID of the user who sent the invitation
  final String invitedBy;
  
  /// Name of the user who sent the invitation (cached for display)
  final String invitedByName;
  
  /// When the invitation was sent
  final DateTime sentAt;

  /// Creates a new circle invitation
  const CircleInvitation({
    required this.id,
    required this.circleId,
    required this.circleName,
    required this.isCirclePrivate,
    required this.invitedBy,
    required this.invitedByName,
    required this.sentAt,
  });
}
