class AppConstants {
  // App information
  static const String appName = 'Resbite';
  static const String appTagline = 'Connect through activities';
  static const String appVersion = '1.0.0';
  
  // API endpoints
  static const String firebaseProjectId = 'resbite-bc3fd';
  static const String apiBaseUrl = 'https://api.resbite.com';
  
  // Assets
  static const String logoPath = 'assets/images/wordmark-blue-nobg400.png';
  
  // Navigation
  static const int navigationAnimationDuration = 200; // milliseconds
  
  // Animation
  static const int defaultAnimationDuration = 300; // milliseconds
  
  // Pagination
  static const int paginationLimit = 20;
  
  // Cache
  static const int cacheDuration = 60 * 60 * 24; // 24 hours in seconds
  
  // Location
  static const double defaultLocationLatitude = 40.7128; // Default: New York
  static const double defaultLocationLongitude = -74.0060;
  static const double defaultMapZoom = 13.0;
  static const double maxSearchRadius = 100.0; // kilometers
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 1000;
  
  // Timeouts
  static const int connectionTimeout = 30000; // milliseconds
  static const int receiveTimeout = 30000; // milliseconds
  
  // Shared Preferences Keys
  static const String prefKeyAuthToken = 'auth_token';
  static const String prefKeyUserId = 'user_id';
  static const String prefKeyUserEmail = 'user_email';
  static const String prefKeyUserName = 'user_name';
  static const String prefKeyUserPhotoUrl = 'user_photo_url';
  static const String prefKeyThemeMode = 'theme_mode';
  static const String prefKeyLocale = 'locale';
  static const String prefKeyLastSync = 'last_sync';
  static const String prefKeyOnboardingComplete = 'onboarding_complete';
  
  // Error messages
  static const String errorNetworkMessage = 'Please check your internet connection';
  static const String errorGeneralMessage = 'Something went wrong. Please try again later';
  static const String errorAuthMessage = 'Authentication failed. Please sign in again';
  static const String errorValidationMessage = 'Please check your input and try again';
  static const String errorLocationMessage = 'Unable to get your location';
  static const String errorPermissionMessage = 'Permission denied. Some features may not work properly';
}