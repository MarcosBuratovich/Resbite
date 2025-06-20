// Temporary implementation shim that aliases the existing CircleService to
// GroupService until the migration from *circle* → *group* is complete.
//
// IMPORTANT:
// - This file intentionally contains **no business logic**.  It re-exports the
//   production implementation that still lives in `circle_service.dart` to
//   avoid code duplication during the transition.
// - Once every call-site has been migrated to the `group*` names, the full
//   implementation will be moved here and `circle_service.dart` will be
//   deleted.
//
// 2025-06-17 – Resbite Migration Sprint 1

import 'circle_service.dart' as circle;

// ---------------------------------------------------------------------------
// Type aliases — new preferred names
// ---------------------------------------------------------------------------

typedef GroupService = circle.CircleService;
typedef GroupServiceImpl = circle.CircleServiceImpl;

// ---------------------------------------------------------------------------
// Provider aliases — use these in NEW code
// ---------------------------------------------------------------------------

/// Provides the `GroupService` instance.  Prefer this over
/// `circleServiceProvider` going forward.
final groupServiceProvider = circle.circleServiceProvider;

/// List of groups the current user belongs to.
final userGroupsProvider = circle.userCirclesProvider;

/// Members of a particular group (parameter: `groupId`).
final groupMembersProvider = circle.circleMembersProvider;

/// Details of a specific group (parameter: `groupId`).
final groupDetailsProvider = circle.circleDetailsProvider;

// ---------------------------------------------------------------------------
// Deprecated shims pointing back to the old names.  These will be removed
// once no references remain.
// ---------------------------------------------------------------------------

@Deprecated('Use groupServiceProvider instead')
final circleServiceProvider = groupServiceProvider;

@Deprecated('Use userGroupsProvider instead')
final userCirclesProvider = userGroupsProvider;

@Deprecated('Use groupMembersProvider instead')
final circleMembersProvider = groupMembersProvider;

@Deprecated('Use groupDetailsProvider instead')
final circleDetailsProvider = groupDetailsProvider;
