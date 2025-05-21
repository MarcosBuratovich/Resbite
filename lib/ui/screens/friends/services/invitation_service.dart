import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resbite_app/models/invitation.dart';
import 'package:resbite_app/models/validated_contact.dart';
import 'package:resbite_app/services/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service interface for managing invitations
abstract class InvitationService {
  /// Invites a contact to join the app
  Future<void> inviteContactToApp(dynamic contact);

  /// Gets pending invitations for the current user
  Future<List<Invitation>> getPendingInvitations();

  /// Accepts an invitation
  Future<void> acceptInvitation(String invitationId);

  /// Declines an invitation
  Future<void> declineInvitation(String invitationId);

  /// Creates a ValidatedContact from basic info
  ValidatedContact createContact({
    required String name,
    String? email,
    String? phone,
  });
}

/// Implementation of InvitationService
class InvitationServiceImpl implements InvitationService {
  final SupabaseClient _supabase;

  InvitationServiceImpl(this._supabase);

  /// Get the current user ID or throw error if not authenticated
  String get _requiredUserId {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return userId;
  }

  /// Create a ValidatedContact from basic contact information
  @override
  ValidatedContact createContact({
    required String name,
    String? email,
    String? phone,
  }) {
    return ValidatedContact(
      id:
          '${name.toLowerCase().replaceAll(RegExp(r'\s+'), '-')}-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      contactInfo: ContactInfo(email: email, phone: phone, displayName: name),
    );
  }

  @override
  Future<void> inviteContactToApp(dynamic contact) async {
    try {
      final userId = _requiredUserId;

      // Convert parameters to ValidatedContact if needed (for backward compatibility)
      final ValidatedContact validatedContact;
      if (contact is ValidatedContact) {
        validatedContact = contact;
      } else if (contact is String) {
        // Handling legacy call format - contactName
        validatedContact = createContact(name: contact);
      } else if (contact is List && contact.length >= 2) {
        // Handling legacy call format - [contactName, contactPhone]
        final String name = contact[0]?.toString() ?? 'Unknown';
        final String? phone = contact[1]?.toString();
        validatedContact = createContact(name: name, phone: phone);
      } else {
        throw ArgumentError('Invalid contact format');
      }

      // Implementation would normally send invitation via email/SMS
      debugPrint(
        'Inviting contact ${validatedContact.contactInfo.name} to app',
      );

      // Track invitation in database
      await _supabase.from('app_invitations').insert({
        'inviter_id': userId,
        'contact_info': validatedContact.contactInfo.toJson(),
        'invited_email': validatedContact.contactInfo.email,
        'invited_phone': validatedContact.contactInfo.phoneNumber,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error inviting contact to app: $e');
      rethrow;
    }
  }

  @override
  Future<List<Invitation>> getPendingInvitations() async {
    try {
      final userId = _requiredUserId;

      // Get pending circle invitations
      final invitations = await _supabase
          .from('circle_invitations')
          .select('*, circles(*), users!inviter_id(*)')
          .eq('invited_user_id', userId)
          .eq('status', 'pending');

      // Transform to Invitation objects
      return invitations.map<Invitation>((invitation) {
        final circle = invitation['circles'];
        final inviter = invitation['users'];

        return Invitation(
          id: invitation['id'],
          circleId: invitation['circle_id'],
          circleName: circle['name'],
          circleDescription: circle['description'] ?? '',
          isCirclePrivate: circle['is_private'] ?? true,
          inviterId: invitation['inviter_id'],
          inviterName: inviter['display_name'] ?? 'User',
          inviterImageUrl: inviter['avatar_url'],
          createdAt: DateTime.parse(invitation['created_at']),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting pending invitations: $e');
      rethrow;
    }
  }

  @override
  Future<void> acceptInvitation(String invitationId) async {
    try {
      final userId = _requiredUserId;

      // Get the invitation details
      final invitation =
          await _supabase
              .from('circle_invitations')
              .select('*')
              .eq('id', invitationId)
              .eq('invited_user_id', userId)
              .single();

      // Add user to the circle
      await _supabase.from('circle_members').insert({
        'circle_id': invitation['circle_id'],
        'user_id': userId,
        'is_admin': false,
        'joined_at': DateTime.now().toIso8601String(),
      });

      // Update invitation status
      await _supabase
          .from('circle_invitations')
          .update({'status': 'accepted'})
          .eq('id', invitationId);
    } catch (e) {
      debugPrint('Error accepting invitation: $e');
      rethrow;
    }
  }

  @override
  Future<void> declineInvitation(String invitationId) async {
    try {
      final userId = _requiredUserId;

      // Update invitation status
      await _supabase
          .from('circle_invitations')
          .update({'status': 'declined'})
          .eq('id', invitationId)
          .eq('invited_user_id', userId);
    } catch (e) {
      debugPrint('Error declining invitation: $e');
      rethrow;
    }
  }
}

/// Invitation service provider
final invitationServiceProvider = Provider<InvitationService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return InvitationServiceImpl(supabase);
});

/// Pending invitations provider
final pendingInvitationsProvider = FutureProvider<List<Invitation>>((
  ref,
) async {
  final invitationService = ref.watch(invitationServiceProvider);
  return await invitationService.getPendingInvitations();
});
