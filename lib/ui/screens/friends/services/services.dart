// Export all friend feature services with a clean, modular architecture

// Core service implementations
export 'friend_service_impl.dart'; // Core friend management
export 'circle_service.dart'; // Circle management (deprecated)
export 'invitation_service.dart'; // Invitation management

// Export all providers for components to use
export 'friend_service_impl.dart'
    show
        friendServiceProvider,
        friendServiceImplProvider,
        directFriendsListProvider,
        pendingFriendRequestsProvider,
        networkConnectionsProvider;
export 'group_service_impl.dart'
    show groupServiceProvider,
        userGroupsProvider,
        groupMembersProvider,
        groupDetailsProvider;
// TEMP: re-export circle-based providers for backward compatibility
export 'circle_service.dart'
    show circleServiceProvider,
        userCirclesProvider,
        circleMembersProvider,
        circleDetailsProvider;
export 'invitation_service.dart'
    show invitationServiceProvider, pendingInvitationsProvider;

// Compatibility layer for components still using old provider names
import 'friend_service_impl.dart';
import 'group_service_impl.dart' show groupServiceProvider;
import 'circle_service.dart'; // deprecated
import 'invitation_service.dart';

// Compatibility aliases -----------------------------------------------------
final friendsServiceProvider = friendServiceProvider;
final groupsServiceProvider = groupServiceProvider;
final directFriendsProvider = directFriendsListProvider;
final extendedNetworkProvider = networkConnectionsProvider;
@Deprecated('Use groupsServiceProvider')
final circlesServiceProvider = circleServiceProvider;
final invitationsServiceProvider = invitationServiceProvider;

// Legacy services have been removed:
// - friends_service.dart (replaced by friend_service_impl.dart)
// - circles_service.dart (replaced by circle_service.dart)
// - invitations_service.dart (replaced by invitation_service.dart)
