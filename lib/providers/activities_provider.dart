import 'package:flutter_riverpod/flutter_riverpod.dart';


// Re-export the providers from app_state.dart for easier access
export '../services/app_state.dart' show 
  activitiesProvider,
  activitiesByCategoryProvider,
  activityProvider,
  categoriesProvider;

// Provider for user's favorite activities - this will be implemented later
final userFavoritesProvider = StateProvider<List<String>>((ref) => []);
