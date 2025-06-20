/// EventInvitation domain model.
/// Maps directly to `event_invitations` Supabase table.
class EventInvitation {
  final String id;
  final String eventId;
  final String inviterId;
  final String inviteeId;

  /// pending / accepted / declined
  final String status;
  final DateTime createdAt;

  const EventInvitation({
    required this.id,
    required this.eventId,
    required this.inviterId,
    required this.inviteeId,
    this.status = 'pending',
    required this.createdAt,
  });

  factory EventInvitation.fromJson(Map<String, dynamic> json) => EventInvitation(
        id: json['id'] as String,
        eventId: json['event_id'] as String,
        inviterId: json['inviter_id'] as String,
        inviteeId: json['invitee_id'] as String,
        status: json['status'] as String? ?? 'pending',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'inviter_id': inviterId,
      'invitee_id': inviteeId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    }..removeWhere((_, v) => v == null);
  }

  EventInvitation copyWith({
    String? id,
    String? eventId,
    String? inviterId,
    String? inviteeId,
    String? status,
    DateTime? createdAt,
  }) => EventInvitation(
        id: id ?? this.id,
        eventId: eventId ?? this.eventId,
        inviterId: inviterId ?? this.inviterId,
        inviteeId: inviteeId ?? this.inviteeId,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is EventInvitation && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
