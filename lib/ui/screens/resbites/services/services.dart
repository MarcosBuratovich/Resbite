/// This file exports all service-related components for the resbites module
/// to simplify imports throughout the application
///
/// Usage:
/// ```dart
/// import 'package:resbite_app/ui/screens/resbites/services/services.dart' as resbite_services;
///
/// // Then use the exported providers:
/// final resbiteService = ref.watch(resbite_services.resbiteServiceProvider);
/// ```
library;

// Export service interfaces and implementations
export 'resbite_service.dart';

// Export specific providers with their original names
export 'resbite_service.dart'
    show
        resbiteServiceProvider,
        upcomingResbitesProvider,
        pastResbitesProvider,
        resbiteParticipantsProvider,
        resbitesByActivityProvider,
        resbitesByPlaceProvider,
        resbitesByUserProvider;
