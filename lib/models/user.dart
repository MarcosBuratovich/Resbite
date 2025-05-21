import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? displayName,
    String? phoneNumber,
    String? profileImageUrl,
    String? shortDescription,
    DateTime? dateOfBirth,
    @Default('user')
    String role, // Must be one of: 'user', 'admin', 'moderator'
    String? title,
    DateTime? createdAt,
    DateTime? lastActive,
    @Default(false) bool emailVerified,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  static User empty() =>
      const User(id: '', email: '', emailVerified: false, role: 'user', dateOfBirth: null);

  static User fromFirebase(Map<String, dynamic> json, String uid) {
    return User(
      id: uid,
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['photoUrl'] ?? json['profileImageUrl'],
      shortDescription: json['shortDescription'],
      dateOfBirth: json['dateOfBirth'] != null
          ? (json['dateOfBirth'] as dynamic).toDate()
          : null,
      role: json['role'] ?? 'user',
      title: json['title'],
      emailVerified: json['emailVerified'] ?? false,
      createdAt:
          json['createdTime'] != null
              ? (json['createdTime'] as dynamic).toDate()
              : DateTime.now(),
      lastActive:
          json['lastActiveTime'] != null
              ? (json['lastActiveTime'] as dynamic).toDate()
              : DateTime.now(),
    );
  }

  // Renamed to avoid conflict with the new factory that takes a supabase_flutter.User object
  static User fromSupabase(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['display_name'], // Supabase uses user_metadata.name or raw_user_meta_data.name
      phoneNumber: json['phone_number'], // Supabase uses phone
      profileImageUrl: json['profile_image_url'], // Supabase uses user_metadata.avatar_url or raw_user_meta_data.avatar_url
      shortDescription: json['short_description'],
      role: json['role'] ?? 'user', // Supabase stores role in app_metadata.roles or a custom claim
      title: json['title'],
      emailVerified:
          true, // Supabase users are assumed to be verified through Firebase if this path is taken
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      lastActive:
          json['last_active'] != null
              ? DateTime.parse(json['last_active'])
              : DateTime.now(),
      dateOfBirth: null, // Added dateOfBirth
    );
  }

  // New factory to create a User from a supabase_flutter.User object
  factory User.fromSupabaseUser(supabase_flutter.User supabaseUser) {
    // Access metadata carefully, as it can be null or not contain expected fields.
    final userMetadata = supabaseUser.userMetadata ?? {};
    // final appMetadata = supabaseUser.appMetadata ?? {}; // For roles if stored there

    return User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      displayName: userMetadata['name'] as String? ?? userMetadata['display_name'] as String? ?? supabaseUser.email?.split('@')[0],
      phoneNumber: supabaseUser.phone ?? userMetadata['phone_number'] as String?,
      profileImageUrl: userMetadata['avatar_url'] as String? ?? userMetadata['profile_image_url'] as String?,
      shortDescription: userMetadata['short_description'] as String?,
      // Role might be in app_metadata or a custom claim in the JWT, adjust as needed.
      // For now, defaulting to 'user' or what's in user_metadata if you place it there.
      role: userMetadata['role'] as String? ?? 'user', 
      title: userMetadata['title'] as String?,
      emailVerified: supabaseUser.emailConfirmedAt != null || (userMetadata['email_verified'] as bool? ?? false),
      createdAt: supabaseUser.createdAt != null ? DateTime.parse(supabaseUser.createdAt!) : DateTime.now(),
      lastActive: supabaseUser.updatedAt != null ? DateTime.parse(supabaseUser.updatedAt!) : DateTime.now(), // Or lastSignInAt
      dateOfBirth: null, // Added dateOfBirth
    );
  }
}
