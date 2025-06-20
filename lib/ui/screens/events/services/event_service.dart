import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import 'package:resbite_app/models/event.dart';
import 'package:resbite_app/models/event_invitation.dart';
import 'package:resbite_app/models/event_feedback.dart';
import 'package:resbite_app/services/providers.dart';

/// Service interface defining CRUD operations for events and related entities.
abstract class EventService {
  // Event CRUD
  Future<Event> createEvent(Event event);
  Future<void> updateEvent(Event event);
  Future<void> deleteEvent(String eventId);

  Future<List<Event>> getUserEvents(String userId);
  Future<Event?> getEvent(String eventId);

  // Invitations
  Future<EventInvitation> inviteUser(String eventId, String userId);
  Future<void> respondToInvitation(String invitationId, String status);

  // Query events the user is invited to (accepted or pending)
  Future<List<Event>> getInvitedEvents(String userId);

  // Feedback
  Future<EventFeedback> leaveFeedback(EventFeedback feedback);
  Future<List<EventFeedback>> getEventFeedback(String eventId);
}

class EventServiceImpl implements EventService {
  final SupabaseClient _supabase;


  EventServiceImpl(this._supabase);

  String get _requiredUserId =>
      _supabase.auth.currentUser?.id ?? (throw Exception('Not authenticated'));

  // -------------------- Events --------------------
  @override
  Future<Event> createEvent(Event event) async {
    final insertedRow = await _supabase
        .from('events')
        .insert(event.toJson())
        .select()
        .single();
    return Event.fromJson(insertedRow);
  }

  @override
  Future<void> updateEvent(Event event) async {
    await _supabase
        .from('events')
        .update(event.toJson())
        .eq('id', event.id);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await _supabase.from('events').delete().eq('id', eventId);
  }

  @override
  Future<Event?> getEvent(String eventId) async {
    final row =
        await _supabase.from('events').select().eq('id', eventId).maybeSingle();
    return row != null ? Event.fromJson(row) : null;
  }

  @override
  Future<List<Event>> getUserEvents(String userId) async {
    final rows =
        await _supabase.from('events').select().eq('created_by', userId);
    return rows.map<Event>((r) => Event.fromJson(r)).toList();
  }

  // ------------------- Queries -------------------
  @override
  Future<List<Event>> getInvitedEvents(String userId) async {
    try {
      final rows = await _supabase.rpc('events_user_invited_to', params: {'uid': userId});
      if (rows is List && rows.isNotEmpty && rows.first is Map<String, dynamic>) {
        return rows.map<Event>((r) => Event.fromJson(r)).toList();
      }
    } on PostgrestException catch (e) {
      // RPC doesn't exist; fall back to join approach.
      if (!e.message.contains('events_user_invited_to')) rethrow;
    }

    final joined = await _supabase
        .from('event_invitations')
        .select('events(*)')
        .eq('invitee_id', userId)
        .neq('status', 'declined');
    final events = <Event>[];
    for (final row in joined) {
      final e = row['events'];
      if (e != null) events.add(Event.fromJson(e as Map<String, dynamic>));
    }
    return events;
  }

  // ------------------ Invitations ----------------
  @override
  Future<EventInvitation> inviteUser(String eventId, String userId) async {
    final payload = {
      'event_id': eventId,
      'inviter_id': _requiredUserId,
      'invitee_id': userId,
      'status': 'pending',
    };
    final row = await _supabase
        .from('event_invitations')
        .insert(payload)
        .select()
        .single();
    return EventInvitation.fromJson(row);
  }

  @override
  Future<void> respondToInvitation(String invitationId, String status) async {
    await _supabase
        .from('event_invitations')
        .update({'status': status})
        .eq('id', invitationId);
  }

  // ------------------- Feedback ------------------
  @override
  Future<EventFeedback> leaveFeedback(EventFeedback feedback) async {
    final row = await _supabase
        .from('event_feedback')
        .insert(feedback.toJson())
        .select()
        .single();
    return EventFeedback.fromJson(row);
  }

  @override
  Future<List<EventFeedback>> getEventFeedback(String eventId) async {
    final rows =
        await _supabase.from('event_feedback').select().eq('event_id', eventId);
    return rows.map<EventFeedback>((r) => EventFeedback.fromJson(r)).toList();
  }
}

// ---------------------------------------------------------------------------
// Riverpod Providers
// ---------------------------------------------------------------------------

/// EventService provider so any widget / service can access it via Riverpod.
final eventServiceProvider = Provider<EventService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return EventServiceImpl(supabase);
});

/// Provider that fetches the current authenticated user's events.
// All relevant events (created OR invited)
final relevantEventsProvider = FutureProvider<List<Event>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  final service = ref.watch(eventServiceProvider);
  final created = await service.getUserEvents(userId);
  final invited = await service.getInvitedEvents(userId);
  // Merge without duplicates
  final map = {for (var e in created) e.id: e}..addEntries(invited.map((e) => MapEntry(e.id, e)));
  return map.values.toList()..sort((a,b)=>a.startAt.compareTo(b.startAt));
});

final userEventsProvider = FutureProvider<List<Event>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  final eventService = ref.watch(eventServiceProvider);
  return eventService.getUserEvents(userId);
});

/// Provider for a single event's details by its ID.
final eventDetailsProvider = FutureProvider.family<Event?, String>(
  (ref, eventId) async {
    final eventService = ref.watch(eventServiceProvider);
    return eventService.getEvent(eventId);
  },
);
