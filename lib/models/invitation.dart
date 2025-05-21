
/// Represents an invitation in the application
class Invitation {
  /// Unique identifier for the invitation
  final String id;
  
  /// ID of the circle this invitation is for
  final String circleId;
  
  /// Name of the circle (cached for display purposes)
  final String circleName;
  
  /// Description of the circle (cached for display)
  final String? circleDescription;
  
  /// Whether the circle is private
  final bool isCirclePrivate;
  
  /// ID of the user who sent the invitation
  final String inviterId;
  
  /// Name of the user who sent the invitation (cached for display)
  final String inviterName;
  
  /// Profile image URL of the inviter (cached for display)
  final String? inviterImageUrl;
  
  /// When the invitation was sent
  final DateTime createdAt;

  /// Creates a new invitation
  const Invitation({
    required this.id,
    required this.circleId,
    required this.circleName,
    this.circleDescription,
    required this.isCirclePrivate,
    required this.inviterId,
    required this.inviterName,
    this.inviterImageUrl,
    required this.createdAt,
  });

  /// Factory method to create an Invitation from JSON
  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'],
      circleId: json['circle_id'],
      circleName: json['circle_name'],
      circleDescription: json['circle_description'],
      isCirclePrivate: json['is_circle_private'] ?? true,
      inviterId: json['inviter_id'],
      inviterName: json['inviter_name'],
      inviterImageUrl: json['inviter_image_url'],
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
    );
  }

  /// Convert invitation to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'circle_id': circleId,
      'circle_name': circleName,
      'circle_description': circleDescription,
      'is_circle_private': isCirclePrivate,
      'inviter_id': inviterId,
      'inviter_name': inviterName,
      'inviter_image_url': inviterImageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Invitation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
