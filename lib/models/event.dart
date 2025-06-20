/// Event domain model representing a planned Resbite activity.
///
/// Keys intentionally match the Supabase `events` table columns so that we can
/// map rows directly using `fromJson`/`toJson` without hard-coded conversions.
class Event {
  final String id;
  final String title;
  final String? description;
  final DateTime startAt;
  final DateTime endAt;
  final bool isPrivate;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    required this.id,
    required this.title,
    this.description,
    required this.startAt,
    required this.endAt,
    this.isPrivate = true,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startAt: DateTime.parse(json['start_at'] as String),
      endAt: DateTime.parse(json['end_at'] as String),
      isPrivate: (json['is_private'] as bool?) ?? true,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'is_private': isPrivate,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    }..removeWhere((_, value) => value == null);
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startAt,
    DateTime? endAt,
    bool? isPrivate,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      isPrivate: isPrivate ?? this.isPrivate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
