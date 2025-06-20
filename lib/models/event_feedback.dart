/// EventFeedback domain model.
/// Represents feedback given by a participant after an event.
class EventFeedback {
  final String id;
  final String eventId;
  final String userId;
  final int rating; // 1-5
  final String? comment;
  final DateTime createdAt;

  const EventFeedback({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory EventFeedback.fromJson(Map<String, dynamic> json) => EventFeedback(
        id: json['id'] as String,
        eventId: json['event_id'] as String,
        userId: json['user_id'] as String,
        rating: (json['rating'] as num).toInt(),
        comment: json['comment'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    }..removeWhere((_, v) => v == null);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is EventFeedback && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
