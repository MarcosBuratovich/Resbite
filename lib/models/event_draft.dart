/// A transient model that stores the user's inputs while creating an Event.
/// This never leaves the client; it's just for the multi-step wizard.
class EventDraft {
  String? title;
  String? description;
  DateTime? startAt;
  DateTime? endAt;

  bool isPrivate = true;

  String? locationName; // simple text for MVP
  double? latitude;
  double? longitude;

  final Set<String> inviteeIds = {}; // friends & group members chosen

  bool get isValidStep1 =>
      (title?.trim().isNotEmpty ?? false) && startAt != null && endAt != null;
}
