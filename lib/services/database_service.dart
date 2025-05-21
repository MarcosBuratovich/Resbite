import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../models/place.dart';
import '../utils/logger.dart';

class DatabaseService {
  final SupabaseClient _supabase;

  DatabaseService({required Ref ref, SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  // Getter for supabase client instance
  SupabaseClient get supabase => _supabase;

  // ======== PLACES ========

  // Get place
  Future<Place?> getPlace(String placeId) async {
    try {
      final response =
          await _supabase
              .from('places')
              .select()
              .eq('id', placeId)
              .maybeSingle();

      if (response == null) return null;

      return Place.fromSupabase(response);
    } catch (e, stack) {
      AppLogger.error('Failed to get place', e, stack);
      return null;
    }
  }
}
