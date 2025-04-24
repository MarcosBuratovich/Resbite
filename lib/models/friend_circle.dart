import 'package:flutter/foundation.dart';
import 'user.dart';

/// Represents a connection level in the friend network
enum ConnectionLevel {
  /// Direct friends - people the user has added themselves
  direct,
  
  /// Friends of friends - 2nd degree connections
  secondDegree,
  
  /// Friends of friends of friends - 3rd degree connections
  thirdDegree,
}

/// Represents a friend connection with metadata about the relationship
class FriendConnection {
  final String id;
  final User user;
  final ConnectionLevel level;
  final String? connectedThrough; // ID of the user who connected them
  final DateTime connectedAt;
  final bool isFavorite;
  final List<String> groupIds; // Groups this friend belongs to

  FriendConnection({
    required this.id,
    required this.user,
    required this.level,
    this.connectedThrough,
    required this.connectedAt,
    this.isFavorite = false,
    this.groupIds = const [],
  });

  FriendConnection copyWith({
    String? id,
    User? user,
    ConnectionLevel? level,
    String? connectedThrough,
    DateTime? connectedAt,
    bool? isFavorite,
    List<String>? groupIds,
  }) {
    return FriendConnection(
      id: id ?? this.id,
      user: user ?? this.user,
      level: level ?? this.level,
      connectedThrough: connectedThrough ?? this.connectedThrough,
      connectedAt: connectedAt ?? this.connectedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      groupIds: groupIds ?? this.groupIds,
    );
  }
}

/// Represents a group or circle of friends
class FriendCircle {
  final String id;
  final String name;
  final String description;
  final String createdBy; // User ID of creator
  final DateTime createdAt;
  final List<String> adminIds; // User IDs of admins
  final List<String> memberIds; // User IDs of members
  final List<String> pendingInviteIds; // User IDs of pending invites
  final bool isPrivate; // If true, only admins can add members
  final String? avatarUrl;
  final Map<String, dynamic>? metadata; // Additional data

  FriendCircle({
    required this.id,
    required this.name,
    this.description = '',
    required this.createdBy,
    required this.createdAt,
    this.adminIds = const [],
    this.memberIds = const [],
    this.pendingInviteIds = const [],
    this.isPrivate = false,
    this.avatarUrl,
    this.metadata,
  });

  /// Check if a user is an admin
  bool isAdmin(String userId) {
    return adminIds.contains(userId) || createdBy == userId;
  }

  /// Check if a user is a member
  bool isMember(String userId) {
    return memberIds.contains(userId) || isAdmin(userId);
  }

  /// Check if a user has a pending invite
  bool hasPendingInvite(String userId) {
    return pendingInviteIds.contains(userId);
  }

  /// Get the number of members including admins
  int get memberCount {
    // Use a Set to avoid counting admins twice if they're also in memberIds
    return ({...adminIds, createdBy, ...memberIds}).length;
  }

  FriendCircle copyWith({
    String? id,
    String? name,
    String? description,
    String? createdBy,
    DateTime? createdAt,
    List<String>? adminIds,
    List<String>? memberIds,
    List<String>? pendingInviteIds,
    bool? isPrivate,
    ValueGetter<String?>? avatarUrl,
    ValueGetter<Map<String, dynamic>?>? metadata,
  }) {
    return FriendCircle(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      adminIds: adminIds ?? this.adminIds,
      memberIds: memberIds ?? this.memberIds,
      pendingInviteIds: pendingInviteIds ?? this.pendingInviteIds,
      isPrivate: isPrivate ?? this.isPrivate,
      avatarUrl: avatarUrl != null ? avatarUrl() : this.avatarUrl,
      metadata: metadata != null ? metadata() : this.metadata,
    );
  }
}

/// Represents an invitation to join a friend circle
class CircleInvitation {
  final String id;
  final String circleId;
  final String inviterId; // User ID who sent the invite
  final String inviteeId; // User ID being invited
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String? message;
  final InvitationStatus status;

  CircleInvitation({
    required this.id,
    required this.circleId,
    required this.inviterId,
    required this.inviteeId,
    required this.createdAt,
    this.expiresAt,
    this.message,
    this.status = InvitationStatus.pending,
  });

  /// Check if the invitation has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  CircleInvitation copyWith({
    String? id,
    String? circleId,
    String? inviterId,
    String? inviteeId,
    DateTime? createdAt,
    ValueGetter<DateTime?>? expiresAt,
    ValueGetter<String?>? message,
    InvitationStatus? status,
  }) {
    return CircleInvitation(
      id: id ?? this.id,
      circleId: circleId ?? this.circleId,
      inviterId: inviterId ?? this.inviterId,
      inviteeId: inviteeId ?? this.inviteeId,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt != null ? expiresAt() : this.expiresAt,
      message: message != null ? message() : this.message,
      status: status ?? this.status,
    );
  }
}

enum InvitationStatus {
  pending,
  accepted,
  declined,
  cancelled,
  expired,
}