/// This file exports all service-related components for the profile module
/// to simplify imports throughout the application
///
/// Usage:
/// ```dart
/// import 'package:resbite_app/ui/screens/profile/services/services.dart' as profile_services;
///
/// // Then use the exported providers:
/// final profileService = ref.watch(profile_services.profileServiceProvider);
/// ```
library;

// Export service interfaces and implementations
export 'profile_service.dart';

// Export specific providers with their original names
export 'profile_service.dart'
    show
        profileServiceProvider,
        currentUserProfileProvider,
        userPreferencesProvider,
        userStatisticsProvider;
