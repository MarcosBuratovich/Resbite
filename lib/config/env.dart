import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // Log error but continue - use default values if .env not found
      print('Error loading .env file: $e');
    }
  }
  
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';
  static String get firebaseMessagingSenderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? 'resbite-bc3fd';
  static String get firebaseStorageBucket => dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  static bool get isProduction => dotenv.env['ENVIRONMENT'] == 'production';
  static bool get isStaging => dotenv.env['ENVIRONMENT'] == 'staging';
  static bool get isDevelopment => dotenv.env['ENVIRONMENT'] == 'development' || !isProduction && !isStaging;
}