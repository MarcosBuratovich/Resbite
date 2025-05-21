import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'env.dart';

/// FeatureFlags provides a centralized way to control feature availability
/// across the Resbite app. It supports both local flags and remote configuration
/// for A/B testing and phased feature rollout.
class FeatureFlags {
  static const String _prefKey = 'resbite_feature_flags';
  static final FeatureFlags _instance = FeatureFlags._internal();
  static SharedPreferences? _prefs;
  static Map<String, dynamic> _remoteFlags = {};
  static bool _initialized = false;

  /// Factory constructor to return the singleton instance
  factory FeatureFlags() {
    return _instance;
  }

  FeatureFlags._internal();

  /// Initialize the feature flags system
  static Future<void> initialize() async {
    if (_initialized) return;

    _prefs = await SharedPreferences.getInstance();
    await _loadPersistedFlags();
    await _loadRemoteConfig();

    _initialized = true;
    print(
      'FeatureFlags initialized. Environment: ${Env.isDevelopment ? 'Development' : (Env.isStaging ? 'Staging' : 'Production')}',
    );
  }

  /// Load persisted feature flags from SharedPreferences
  static Future<void> _loadPersistedFlags() async {
    final String? persisted = _prefs?.getString(_prefKey);
    if (persisted != null) {
      try {
        _remoteFlags = Map<String, dynamic>.from(jsonDecode(persisted));
      } catch (e) {
        print('Error loading persisted feature flags: $e');
      }
    }
  }

  /// Load remote configuration for feature flags
  static Future<void> _loadRemoteConfig() async {
    // TODO: Implement integration with Firebase Remote Config or similar
    // For now, we'll use local values with environment-specific overrides

    // In a real implementation, you would fetch from Firebase/Supabase here
    // Example:
    // final remoteConfig = FirebaseRemoteConfig.instance;
    // await remoteConfig.fetchAndActivate();
    // _remoteFlags['enableCircles'] = remoteConfig.getBool('enableCircles');

    // Persist the remote flags
    _persistFlags();
  }

  /// Save flags to persistent storage
  static void _persistFlags() {
    if (_prefs != null) {
      _prefs!.setString(_prefKey, jsonEncode(_remoteFlags));
    }
  }

  /// Get a feature flag value
  static bool _getFlag(String key, bool defaultValue) {
    // Environment overrides for local development
    if (Env.isDevelopment) {
      switch (key) {
        // Override specific flags in development
        case 'enableAllFeatures':
          return true;
      }
    }

    return _remoteFlags[key] as bool? ?? defaultValue;
  }

  //
  // FEATURE FLAGS
  // Add new flags here with appropriate documentation
  //

  /// UI & DESIGN SYSTEM FLAGS

  /// Enables the enhanced activity details screen with tag cloud, cards, and animations
  static bool get enableNewActivityDetails =>
      _getFlag('enableNewActivityDetails', true);

  /// Enables the modernized onboarding flow with SVG illustrations
  static bool get enableNewOnboarding => _getFlag('enableNewOnboarding', true);

  /// Enables responsive layouts and adaptive UI features
  static bool get enableResponsiveUI => _getFlag('enableResponsiveUI', false);

  /// CORE FEATURE FLAGS

  /// Enables advanced search capabilities for activities
  static bool get enableAdvancedSearch =>
      _getFlag('enableAdvancedSearch', false);

  /// Enables activity recommendation system based on user preferences
  static bool get enableRecommendations =>
      _getFlag('enableRecommendations', false);

  /// Enables activity filtering by multiple criteria
  static bool get enableAdvancedFiltering =>
      _getFlag('enableAdvancedFiltering', false);

  /// SOCIAL FEATURE FLAGS

  /// Enables circles/groups functionality
  static bool get enableCircles => _getFlag('enableCircles', false);

  /// Enables friend connections and social graph
  static bool get enableFriendConnections =>
      _getFlag('enableFriendConnections', true);

  /// Enables in-app chat for resbite coordination
  static bool get enableChatting => _getFlag('enableChatting', false);

  /// ADVANCED FEATURE FLAGS

  /// Enables offline support for viewing activities and resbites
  static bool get enableOfflineMode => _getFlag('enableOfflineMode', false);

  /// Enables analytics tracking for user engagement
  static bool get enableAnalytics =>
      _getFlag('enableAnalytics', Env.isProduction);

  /// Enable all features for testing (DEV ONLY)
  static bool get enableAllFeatures => _getFlag('enableAllFeatures', false);
  
  /// Enable debugging UI elements for development and testing
  static bool get enableDebugging => _getFlag('enableDebugging', Env.isDevelopment);
  
  /// UI ENHANCEMENT FEATURE FLAGS
  
  /// Enable animations throughout the app
  static bool get useAnimations => _getFlag('useAnimations', true);
  
  /// Enable modern UI styling and elements
  static bool get useModernUI => _getFlag('useModernUI', enableNewActivityDetails);

  /// Updates a feature flag locally
  /// Only used in development for testing features
  static void setLocalFlag(String key, bool value) {
    if (!Env.isDevelopment) return;

    _remoteFlags[key] = value;
    _persistFlags();
    print('Feature flag updated: $key = $value');
  }

  /// Reset all feature flags to their default values
  /// Only used in development
  static void resetFlags() {
    if (!Env.isDevelopment) return;

    _remoteFlags.clear();
    _persistFlags();
    print('Feature flags reset to defaults');
  }
}
