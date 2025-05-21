import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user.dart';
import '../utils/logger.dart';

enum AuthStatus {
  authenticated,
  unauthenticated,
  uninitialized,
}

class AuthService with ChangeNotifier {
  final supabase.SupabaseClient _supabaseClient;
  
  User? _currentUser;
  AuthStatus _status = AuthStatus.uninitialized;
  
  User? get currentUser => _currentUser;
  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  
  AuthService(this._supabaseClient);
  
  Future<void> init() async {
    AppLogger.info('AuthService: Initializing...');
    
    // Set up auth state change listener
    _supabaseClient.auth.onAuthStateChange.listen(_handleAuthStateChange);
    
    // Check if already authenticated
    final session = _supabaseClient.auth.currentSession;
    if (session != null) {
      final user = _supabaseClient.auth.currentUser;
      if (user != null) {
        _currentUser = User.fromSupabaseUser(user);
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    
    notifyListeners();
    AppLogger.info('AuthService: Initialization complete. Status: $_status');
  }
  
  void _handleAuthStateChange(supabase.AuthState state) {
    if (state.event == supabase.AuthChangeEvent.signedIn) {
      final user = state.session?.user;
      if (user != null) {
        _currentUser = User.fromSupabaseUser(user);
        _status = AuthStatus.authenticated;
      }
    } else if (state.event == supabase.AuthChangeEvent.signedOut) {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    }
    
    notifyListeners();
  }
  
  // Phone sign-in method
  Future<void> signInWithPhone(String phoneNumber) async {
    try {
      await _supabaseClient.auth.signInWithOtp(
        phone: phoneNumber,
      );
      
      // Current version of Supabase Flutter doesn't return errors in the same way
      // It throws exceptions instead
      
      AppLogger.info('AuthService: OTP sent to $phoneNumber');
    } catch (e) {
      AppLogger.error('AuthService: Error sending OTP', e);
      rethrow;
    }
  }
  
  // Verify phone OTP
  Future<void> verifyOTP(String phoneNumber, String otp) async {
    try {
      await _supabaseClient.auth.verifyOTP(
        phone: phoneNumber,
        token: otp,
        type: supabase.OtpType.sms,
      );
      
      // Current version of Supabase Flutter doesn't return errors in the same way
      // It throws exceptions instead
      
      AppLogger.info('AuthService: OTP verified successfully');
    } catch (e) {
      AppLogger.error('AuthService: Error verifying OTP', e);
      rethrow;
    }
  }

  // Create user with email and password
  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final authResponse = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      // Supabase sends a confirmation email by default.
      // The user will be fully authenticated after confirming their email or if auto-confirm is enabled.
      // onAuthStateChange will handle updating the user state.
      AppLogger.info('AuthService: Sign-up request successful for $email. Waiting for confirmation.');
      if (authResponse.user != null) {
        // Note: _currentUser and _status will be updated by _handleAuthStateChange
        // once the user is effectively signed in (e.g., after email confirmation or if auto-confirm is on).
        // Here, we return the user object obtained from the signUp response directly.
        return User.fromSupabaseUser(authResponse.user!);
      } else {
        // This case might occur if sign-up was successful but didn't immediately yield a user object
        // (e.g. pending email confirmation and no immediate session created).
        AppLogger.warning('AuthService: Sign-up for $email completed, but no user object returned in the immediate response. Email confirmation might be required.');
        return null;
      }
    } catch (e) {
      AppLogger.error('AuthService: Error creating user with email and password', e);
      rethrow;
    }
  }
  
  // Register with email and password (adapter para RegisterService)
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    // Este método es un alias para createUserWithEmailAndPassword para mantener
    // compatibilidad con la nueva implementación de RegisterService
    AppLogger.info('AuthService: Registering new user with email $email');
    return await createUserWithEmailAndPassword(email, password);
  }

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // onAuthStateChange will handle updating the user state upon successful sign-in.
      AppLogger.info('AuthService: Sign-in attempt for $email.');
    } catch (e) {
      AppLogger.error('AuthService: Error signing in with email and password', e);
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    Map<String, dynamic>? data, // User can still pass other custom data
  }) async {
    try {
      final Map<String, dynamic> attributesData = data ?? {}; // Initialize with existing data or empty map
      if (displayName != null) {
        attributesData['displayName'] = displayName; // Add to data map
      }
      if (photoURL != null) {
        attributesData['photo_url'] = photoURL; // Add to data map, often 'photo_url' is conventional
      }

      final attributes = supabase.UserAttributes(
        data: attributesData.isNotEmpty ? attributesData : null, // Pass data map
      );

      if (phoneNumber != null) {
        attributes.phone = phoneNumber; // Phone is a standard attribute
      }

      await _supabaseClient.auth.updateUser(attributes);
      AppLogger.info('AuthService: User profile update request sent.');
    } catch (e) {
      AppLogger.error('AuthService: Error updating user profile', e);
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
      AppLogger.info('AuthService: Password reset email sent to $email.');
    } catch (e) {
      AppLogger.error('AuthService: Error sending password reset email', e);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      AppLogger.info('AuthService: User signed out');
    } catch (e) {
      AppLogger.error('AuthService: Error signing out', e);
      rethrow;
    }
  }
}
