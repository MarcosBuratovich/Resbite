import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resbite_app/models/user.dart';
import 'package:resbite_app/services/providers.dart'; 
import 'package:resbite_app/utils/logger.dart';

// Import new services
import '../ui/screens/friends/services/friend_service_impl.dart'; // Corrected path to the implementation file which also defines the interface and provider alias

/// Contact model to represent a phone contact
class PhoneContact {
  final String id;
  final String displayName;
  final List<String> phoneNumbers;
  final List<String> emails;
  final bool isResbiteUser;
  final String? resbiteUserId;
  final String? profileImageUrl;

  PhoneContact({
    required this.id,
    required this.displayName,
    required this.phoneNumbers,
    required this.emails,
    this.isResbiteUser = false,
    this.resbiteUserId,
    this.profileImageUrl,
  });

  @override
  String toString() {
    return 'PhoneContact{id: $id, displayName: $displayName, phoneNumbers: $phoneNumbers, emails: $emails, isResbiteUser: $isResbiteUser, resbiteUserId: $resbiteUserId, profileImageUrl: $profileImageUrl}';
  }
}

// DO NOT define contactServiceProvider here to avoid circular dependencies
// The actual provider is now defined in app_state.dart

// Contact providers are defined in app_state.dart to avoid circular dependencies

// All providers moved to app_state.dart

/// Service for accessing and managing device contacts
class ContactService {
  final Ref _ref;

  ContactService(this._ref);

  /// Check if contacts permission is granted
  Future<bool> hasContactsPermission() async {
    try {
      var status = await Permission.contacts.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      AppLogger.error('Error checking contacts permission', e);
      return false;
    }
  }

  /// Request contacts permission
  Future<bool> requestContactsPermission() async {
    try {
      var status = await Permission.contacts.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      AppLogger.error('Error requesting contacts permission', e);
      return false;
    }
  }

  /// Get all device contacts
  Future<List<PhoneContact>> getContacts() async {
    try {
      final hasPermission = await hasContactsPermission();
      if (!hasPermission) {
        bool granted = await requestContactsPermission();
        if (!granted) {
          AppLogger.error('Contacts permission denied');
          return [];
        }
      }
      
      // Request permission
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        AppLogger.error('Contacts permission denied');
        return [];
      }
      
      // Get all contacts (lightly fetched)
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: false,
      );
      
      // Convert to PhoneContact model
      return contacts.map((contact) => PhoneContact(
        id: contact.id,
        displayName: contact.displayName,
        phoneNumbers: contact.phones.map((phone) => phone.number).toList(),
        emails: contact.emails.map((email) => email.address).toList(),
        isResbiteUser: false, // Will be updated later
      )).toList();

    } catch (e) {
      AppLogger.error('Error fetching contacts', e);
      return [];
    }
  }

  /// Get all device contacts with Resbite user flags
  Future<List<PhoneContact>> getContactsWithUsers() async {
    // Fetch raw contacts
    final contacts = await getContacts();
    if (contacts.isEmpty) return [];
    // Extract emails and phone numbers
    final allEmails = <String>[];
    final allPhones = <String>[];
    for (var c in contacts) {
      allEmails.addAll(c.emails.where((e) => e.isNotEmpty));
      allPhones.addAll(c.phoneNumbers.where((p) => p.isNotEmpty).map(_normalizePhoneNumber));
    }
    // Lookup matching users
    final userDbService = _ref.read(userDbServiceProvider);
    final matchedUsers = await userDbService.findUsersByContactInfo(
      emails: allEmails.toSet().toList(),
      phones: allPhones.toSet().toList(),
    );
    // Build lookup maps
    final Map<String, User> userByPhone = {};
    final Map<String, User> userByEmail = {};
    for (var u in matchedUsers) {
      if (u.phoneNumber != null) {
        userByPhone[_normalizePhoneNumber(u.phoneNumber!)] = u;
      }
      if (u.email.isNotEmpty) {
        userByEmail[u.email.toLowerCase()] = u;
      }
    }
    // Flag contacts and return
    return contacts.map((c) {
      User? found;
      for (var phone in c.phoneNumbers) {
        final norm = _normalizePhoneNumber(phone);
        if (userByPhone.containsKey(norm)) {
          found = userByPhone[norm];
          break;
        }
      }
      if (found == null) {
        for (var email in c.emails) {
          final normEmail = email.toLowerCase();
          if (userByEmail.containsKey(normEmail)) {
            found = userByEmail[normEmail];
            break;
          }
        }
      }
      if (found != null) {
        return PhoneContact(
          id: c.id,
          displayName: c.displayName,
          phoneNumbers: c.phoneNumbers,
          emails: c.emails,
          isResbiteUser: true,
          resbiteUserId: found.id,
          profileImageUrl: found.profileImageUrl,
        );
      }
      return c;
    }).toList();
  }

  /// Sync contacts with Resbite users database
  Future<List<User>> syncContactsWithDatabase() async {
    try {
      // Get database service from app_state
      final userDbService = _ref.read(userDbServiceProvider);
      final contacts = await getContacts();
      
      // Skip empty contacts list
      if (contacts.isEmpty) {
        AppLogger.info('No contacts found to sync');
        return [];
      }
      
      // Extract emails and phone numbers to match against users
      final List<String> emails = [];
      final List<String> phones = [];
      
      for (var contact in contacts) {
        // Add non-empty emails and phones
        emails.addAll(contact.emails.where((email) => email.isNotEmpty));
        phones.addAll(contact.phoneNumbers.where((phone) => phone.isNotEmpty));
      }
      
      // Skip if no contact info to match
      if (emails.isEmpty && phones.isEmpty) {
        AppLogger.info('No valid contact information to match users with');
        return [];
      }
      
      // Normalize phone numbers to digits only
      final cleanedPhones = phones
          .map((p) => p.replaceAll(RegExp(r'\D'), ''))
          .where((p) => p.isNotEmpty)
          .toSet()
          .toList();

      // Query database for matching users using normalized phone numbers
      final matchedUsers = await userDbService.findUsersByContactInfo(
        emails: emails,
        phones: cleanedPhones,
      );
      
      // Update local contacts with the matched users info
      await _updateContactsWithMatchedUsers(contacts, matchedUsers);
      
      // Store contacts for quicker access in future
      _saveContactsToLocalStorage(contacts);
      
      return matchedUsers;
    } catch (e) {
      AppLogger.error('Error syncing contacts', e);
      return [];
    }
  }

  /// Add a Resbite user as a friend
  Future<bool> addContactAsFriend(String userId) async {
    try {
      // Get services from app_state
      final friendService = _ref.read(friendServiceProvider);
      final authService = _ref.read(authServiceProvider);
      
      // Get current user ID
      final currentUser = authService.currentUser;
      if (currentUser == null) {
        AppLogger.error('Unable to add friend: No current user');
        return false;
      }
      
      // Add friend relationship
      await friendService.addFriend(userId);
      
      return true;
    } catch (e) {
      AppLogger.error('Error adding contact as friend', e);
      return false;
    }
  }

  /// Invite contact to Resbite app
  Future<bool> inviteContact(dynamic contact) async {
    try {
      final displayName = contact is Map ? contact['displayName'] ?? 'Unknown' : 'Unknown';
      final phoneNumbers = contact is Map ? (contact['phoneNumbers'] ?? []) : [];
      final emails = contact is Map ? (contact['emails'] ?? []) : [];
      
      // Log the action
      AppLogger.info('Inviting contact: $displayName');
      
      // Get current user for personalized invitation
      final authService = _ref.read(authServiceProvider);
      final currentUser = authService.currentUser;
      final inviterName = currentUser?.displayName ?? 'A friend';
      
      // Create invitation message
      final inviteMessage = 'Hi $displayName! $inviterName invites you to join Resbite, an app for planning family activities. Download it here: https://resbite.app/invite';
      
      // Store the invitation record
      // In a real implementation, you would track this in the database
      AppLogger.info('Invitation prepared for $displayName with message: $inviteMessage');
      
      // Mock implementation of sharing functionality
      if (phoneNumbers.isNotEmpty) {
        AppLogger.info('Would send SMS to: ${phoneNumbers[0]} with message: $inviteMessage');
      } else if (emails.isNotEmpty) {
        AppLogger.info('Would send email to: ${emails[0]} with message: $inviteMessage');
      }
      
      // TODO: Implement actual sharing with url_launcher
      // For SMS: uri_launcher.launch(Uri.parse('sms:${phoneNumbers[0]}?body=$inviteMessage'))
      // For Email: uri_launcher.launch(Uri.parse('mailto:${emails[0]}?subject=Join me on Resbite&body=$inviteMessage'))
      
      return true;
    } catch (e) {
      AppLogger.error('Error inviting contact', e);
      return false;
    }
  }

  /// Private method to update local contacts with matched users
  Future<void> _updateContactsWithMatchedUsers(
    List<PhoneContact> contacts,
    List<User> matchedUsers,
  ) async {
    // Match contacts with users by email or phone
    for (var user in matchedUsers) {
      for (var contact in contacts) {
        bool isMatch = false;
        
        // Check if any email matches
        if (contact.emails.contains(user.email)) {
          isMatch = true;
        }
        
        // Check if any phone number matches
        if (user.phoneNumber != null) {
          for (var phone in contact.phoneNumbers) {
            // Normalize phone numbers for comparison
            if (_normalizePhoneNumber(phone) == _normalizePhoneNumber(user.phoneNumber!)) {
              isMatch = true;
              break;
            }
          }
        }
        
        if (isMatch) {
          // Update the contact object
          // In a real app, you might use a local database to persist this information
          // For the mock implementation, we can't actually update the original objects
          AppLogger.info('Matched contact ${contact.displayName} with Resbite user ${user.displayName}');
        }
      }
    }
  }
  
  /// Save contacts to local storage for quicker access
  Future<void> _saveContactsToLocalStorage(List<PhoneContact> contacts) async {
    try {
      // In a real implementation, you would save this to shared_preferences or a local database
      // Here we'll just log the action
      final resbiteUsers = contacts.where((c) => c.isResbiteUser).length;
      final nonResbiteUsers = contacts.length - resbiteUsers;
      
      AppLogger.info('Contact sync results: $resbiteUsers Resbite users, $nonResbiteUsers non-users');
      
      // Example of how you might save this with shared_preferences:
      // final prefs = await SharedPreferences.getInstance();
      // prefs.setInt('resbite_contacts_count', resbiteUsers);
      // prefs.setInt('total_contacts_count', contacts.length);
      // prefs.setString('last_contacts_sync', DateTime.now().toIso8601String());
    } catch (e, stack) {
      AppLogger.error('Error saving contacts to local storage', e, stack);
    }
  }

  /// Private helper to normalize phone numbers for comparison
  String _normalizePhoneNumber(String phone) {
    // Remove non-digit characters
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  /// Private helper to get mock contacts (temporary implementation)
  /*
  Future<List<PhoneContact>> _fetchMockContacts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Create a larger, more diverse list of mock contacts
    return [
      PhoneContact(
        id: '1',
        displayName: 'John Smith',
        phoneNumbers: ['+1 (555) 123-4567'],
        emails: ['john.smith@example.com'],
        isResbiteUser: true,
        resbiteUserId: 'user123',
        profileImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
      ),
      PhoneContact(
        id: '2',
        displayName: 'Jane Doe',
        phoneNumbers: ['+1 (555) 987-6543'],
        emails: ['jane.doe@example.com'],
        isResbiteUser: false,
      ),
      PhoneContact(
        id: '3',
        displayName: 'Alice Johnson',
        phoneNumbers: ['+1 (555) 444-3333'],
        emails: ['alice@example.com'],
        isResbiteUser: true,
        resbiteUserId: 'user456',
        profileImageUrl: 'https://randomuser.me/api/portraits/women/1.jpg',
      ),
      PhoneContact(
        id: '4',
        displayName: 'Bob Williams',
        phoneNumbers: ['+1 (555) 222-1111'],
        emails: ['bob@example.com'],
        isResbiteUser: false,
      ),
      PhoneContact(
        id: '5',
        displayName: 'Carol Brown',
        phoneNumbers: ['+1 (555) 777-8888'],
        emails: ['carol@example.com'],
        isResbiteUser: true,
        resbiteUserId: 'user789',
        profileImageUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
      ),
      PhoneContact(
        id: '6',
        displayName: 'David Taylor',
        phoneNumbers: ['+1 (555) 333-2222'],
        emails: ['david.t@example.com'],
        isResbiteUser: false,
      ),
      PhoneContact(
        id: '7',
        displayName: 'Eva Garcia',
        phoneNumbers: ['+1 (555) 444-5555'],
        emails: ['eva.g@example.com'],
        isResbiteUser: false,
      ),
      PhoneContact(
        id: '8',
        displayName: 'Frank Wilson',
        phoneNumbers: ['+1 (555) 666-7777'],
        emails: ['frank@example.com'],
        isResbiteUser: true,
        resbiteUserId: 'user101',
        profileImageUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
      ),
      PhoneContact(
        id: '9',
        displayName: 'Grace Lee',
        phoneNumbers: ['+1 (555) 888-9999', '+1 (555) 888-0000'],
        emails: ['grace@example.com', 'g.lee@work.com'],
        isResbiteUser: false,
      ),
      PhoneContact(
        id: '10',
        displayName: 'Henry Martinez',
        phoneNumbers: [],  // No phone number to test edge case
        emails: ['henry@example.com'],
        isResbiteUser: false,
      ),
      PhoneContact(
        id: '11',
        displayName: 'Isabella Kim',
        phoneNumbers: ['+1 (555) 111-0000'],
        emails: [],  // No email to test edge case
        isResbiteUser: false,
      ),
    ];
  }
  */
}