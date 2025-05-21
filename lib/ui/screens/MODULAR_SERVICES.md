# Modular Services Architecture

This document outlines the modular services architecture implemented in the Resbite app. The architecture follows core principles of maintainability, testability, and clear separation of concerns.

## Core Principles

1. **Service Interface Abstraction**  
   Each domain has a clear interface that defines all operations, allowing for easy mocking and testing.

2. **Provider-Based Dependency Injection**  
   Services use Riverpod providers for dependency injection, making them easily accessible throughout the app.

3. **Strong Typing**  
   All models and method parameters use strong typing to reduce errors and improve code clarity.

4. **Error Handling**  
   Consistent try/catch blocks with appropriate error logging in all service methods.

5. **Backwards Compatibility**  
   Aliases for legacy provider names to ensure a smooth transition from the old architecture.

## Service Organization

Each domain follows a consistent organizational pattern:

```
/lib/ui/screens/{domain}/services/
├── {domain}_service.dart     # Interface + implementation
├── services.dart             # Barrel file for exporting
```

## Implemented Domains

### 1. Friends Domain

The Friends domain was the first to be fully modularized, consisting of:

- `FriendService` / `FriendServiceImpl`
- `CircleService` / `CircleServiceImpl`
- `InvitationService` / `InvitationServiceImpl`

For detailed documentation, see [Friends Architecture Documentation](./friends/ARCHITECTURE.md).

### 2. Activities Domain

The Activities domain handles all activity-related operations:

#### Key Components
- **Interface**: `ActivityService`
- **Implementation**: `ActivityServiceImpl`
- **Core Methods**:
  - `getActivities()`: Fetch all activities
  - `getActivitiesByCategory(categoryId)`: Filter activities by category
  - `getActivityById(id)`: Get details for a specific activity
  - `getFeaturedActivities()`: Get featured activities
  - `getRecommendedActivities()`: Get personalized recommendations
  - `toggleFavorite(activityId)`: Add/remove an activity from favorites
  - `markAsCompleted(activityId)`: Mark an activity as completed

#### Providers
- `activityServiceProvider`: Main service provider
- `featuredActivitiesProvider`: Provides featured activities
- `recommendedActivitiesProvider`: Provides recommended activities
- `recentActivitiesProvider`: Provides recently added activities

### 3. Resbites Domain

The Resbites domain manages scheduled activities (resbites):

#### Key Components
- **Interface**: `ResbiteService`
- **Implementation**: `ResbiteServiceImpl`
- **Core Methods**:
  - `getUpcomingResbites()`: Fetch upcoming resbites
  - `getPastResbites()`: Fetch past resbites
  - `getResbiteById(id)`: Get details for a specific resbite
  - `createResbite(...)`: Create a new resbite
  - `updateResbite(...)`: Update an existing resbite
  - `deleteResbite(id)`: Delete a resbite
  - `joinResbite(resbiteId)`: Join as a participant
  - `leaveResbite(resbiteId)`: Leave a resbite
  - `getParticipants(resbiteId)`: Get all participants

#### Providers
- `resbiteServiceProvider`: Main service provider
- `upcomingResbitesProvider`: Provides upcoming resbites
- `pastResbitesProvider`: Provides past resbites
- `resbiteParticipantsProvider`: Provides participants for a resbite

### 4. Profile Domain

The Profile domain handles user profile management:

#### Key Components
- **Interface**: `ProfileService`
- **Implementation**: `ProfileServiceImpl`
- **Core Methods**:
  - `getCurrentUserProfile()`: Get the current user's profile
  - `updateProfile(...)`: Update profile information
  - `updateProfileImage(imageFile)`: Update profile image
  - `deleteProfileImage()`: Delete profile image
  - `getUserPreferences()`: Get user preferences
  - `updateUserPreferences(preferences)`: Update user preferences
  - `getUserStatistics()`: Get user statistics

#### Providers
- `profileServiceProvider`: Main service provider
- `currentUserProfileProvider`: Provides current user profile
- `userPreferencesProvider`: Provides user preferences
- `userStatisticsProvider`: Provides user statistics

## Usage Examples

### Importing Services

Use the barrel files to import services:

```dart
// Import all friend-related services
import 'package:resbite_app/ui/screens/friends/services/services.dart' as friend_services;

// Import all activity-related services
import 'package:resbite_app/ui/screens/activities/services/services.dart' as activity_services;

// Import all resbite-related services
import 'package:resbite_app/ui/screens/resbites/services/services.dart' as resbite_services;

// Import all profile-related services
import 'package:resbite_app/ui/screens/profile/services/services.dart' as profile_services;
```

### Using Services and Providers

Services can be accessed through their providers:

```dart
// In a ConsumerWidget or using WidgetRef
final friendService = ref.watch(friend_services.friendServiceProvider);
final activityService = ref.watch(activity_services.activityServiceProvider);
final resbiteService = ref.watch(resbite_services.resbiteServiceProvider);
final profileService = ref.watch(profile_services.profileServiceProvider);

// Using providers directly
final directFriends = ref.watch(friend_services.directFriendsListProvider);
final featuredActivities = ref.watch(activity_services.featuredActivitiesProvider);
final upcomingResbites = ref.watch(resbite_services.upcomingResbitesProvider);
final userProfile = ref.watch(profile_services.currentUserProfileProvider);
```

## Transitioning from Legacy Code

When updating UI components to use the new modular services:

1. Import the appropriate service barrel file
2. Replace references to legacy providers with modular providers
3. Update any provider refresh calls to use `ref.invalidate(provider)` pattern
4. Remove imports of legacy service files

## Best Practices

1. **Always use interfaces** for service access to maintain abstraction
2. **Don't access database directly** from UI components; use services instead
3. **Handle errors consistently** in UI layers that interact with services
4. **Refresh providers correctly** using `ref.invalidate()` when data changes
5. **Be mindful of service dependencies** to avoid circular dependencies

## Further Development

Future domain services should follow the same pattern:

1. Define a clear interface with all required operations
2. Implement with proper error handling
3. Create appropriate providers
4. Add a barrel file for exports
5. Include backward compatibility aliases if needed
