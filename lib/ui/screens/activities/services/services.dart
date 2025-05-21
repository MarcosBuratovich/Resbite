/// This file exports all service-related components for the activities module
/// to simplify imports throughout the application
///
/// Usage:
/// ```dart
/// import 'package:resbite_app/ui/screens/activities/services/services.dart' as activity_services;
///
/// // Then use the exported providers:
/// final activityService = ref.watch(activity_services.activityServiceProvider);
/// ```
library;

// Export service interfaces and implementations
export 'activity_service.dart';

// Export specific providers with their original names
export 'activity_service.dart'
    show
        activityServiceProvider,
        featuredActivitiesProvider,
        recommendedActivitiesProvider,
        recentActivitiesProvider;

// Legacy compatibility aliases
// These allow existing code to continue working while transitioning to the new architecture
export 'activity_service.dart' show activitiesServiceProvider;
