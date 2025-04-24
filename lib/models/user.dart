import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? displayName,
    String? phoneNumber,
    String? profileImageUrl,
    String? shortDescription,
    @Default('user') String role, // Must be one of: 'user', 'admin', 'moderator'
    String? title,
    DateTime? createdAt,
    DateTime? lastActive,
    @Default(false) bool emailVerified,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  
  static User empty() => const User(
    id: '',
    email: '',
    emailVerified: false,
    role: 'user',
  );
  
  static User fromFirebase(Map<String, dynamic> json, String uid) {
    return User(
      id: uid,
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['photoUrl'] ?? json['profileImageUrl'],
      shortDescription: json['shortDescription'],
      role: json['role'] ?? 'user',
      title: json['title'],
      emailVerified: json['emailVerified'] ?? false,
      createdAt: json['createdTime'] != null 
          ? (json['createdTime'] as dynamic).toDate() 
          : DateTime.now(),
      lastActive: json['lastActiveTime'] != null 
          ? (json['lastActiveTime'] as dynamic).toDate() 
          : DateTime.now(),
    );
  }
  
  static User fromSupabase(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['display_name'],
      phoneNumber: json['phone_number'],
      profileImageUrl: json['profile_image_url'],
      shortDescription: json['short_description'],
      role: json['role'] ?? 'user',
      title: json['title'],
      emailVerified: true, // Supabase users are assumed to be verified through Firebase
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      lastActive: json['last_active'] != null 
          ? DateTime.parse(json['last_active']) 
          : DateTime.now(),
    );
  }
}