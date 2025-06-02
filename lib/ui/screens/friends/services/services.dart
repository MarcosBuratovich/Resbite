// Export all friend feature services with a clean, modular architecture

// Core service implementations
export 'friend_service_impl.dart'; // Core friend management
export 'circle_service.dart'; // Circle management
export 'invitation_service.dart'; // Invitation management

// Export all providers for components to use
export 'friend_service_impl.dart'
    show
        friendServiceProvider,
        friendServiceImplProvider,
        directFriendsListProvider,
        pendingFriendRequestsProvider,
        networkConnectionsProvider;
export 'circle_service.dart' show circleServiceProvider, userCirclesProvider;
export 'invitation_service.dart'
    show invitationServiceProvider, pendingInvitationsProvider;

// Compatibility layer for components still using old provider names
import 'friend_service_impl.dart';
import 'circle_service.dart';
import 'invitation_service.dart';

// DEPRECATED: Legacy provider aliases to maintain backward compatibility during transition
// TODO: These should be phased out as components are updated to use the new provider names
// Do not use these in new code - instead use the properly named providers above
final friendsServiceProvider = friendServiceProvider;
final directFriendsProvider = directFriendsListProvider;
final extendedNetworkProvider = networkConnectionsProvider;
final circlesServiceProvider = circleServiceProvider;
final invitationsServiceProvider = invitationServiceProvider;

// Legacy services have been removed:
// - friends_service.dart (replaced by friend_service_impl.dart)
// - circles_service.dart (replaced by circle_service.dart)
// - invitations_service.dart (replaced by invitation_service.dart)
