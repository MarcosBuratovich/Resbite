import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resbite_app/services/providers.dart';

/// Provider to track the currently selected category for filtering activities
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// Future provider that loads the list of all categories
/// This is an alias for the existing categoriesProvider in providers.dart
/// Eventually we should migrate all providers to this directory
final allCategoriesProvider = categoriesProvider;
