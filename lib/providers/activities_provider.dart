import 'package:flutter_riverpod/flutter_riverpod.dart';

// Re-export the providers from providers.dart for easier access
export '../services/providers.dart' show 
  activitiesProvider,
  activitiesByCategoryProvider,
  activityProvider,
  categoriesProvider;

// Provider for user's favorite activities - this will be implemented later
final userFavoritesProvider = StateProvider<List<String>>((ref) => []);
