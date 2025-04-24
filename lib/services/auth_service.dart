import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../utils/logger.dart';
import 'database_service.dart';

enum AuthStatus {
  authenticated,
  unauthenticated,
  uninitialized,
}

class AuthService extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final DatabaseService _databaseService;
  
  // Current user
  User? _currentUser;
  User? get currentUser => _currentUser;
  
  // Auth status
  AuthStatus _status = AuthStatus.uninitialized;
  AuthStatus get status => _status;
  
  // Expose Firebase auth for direct access when needed
  firebase_auth.FirebaseAuth get firebaseAuth => _firebaseAuth;
  firebase_auth.User? get firebaseUser => _firebaseAuth.currentUser;
  
  // Auth stream
  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();
  
  // Constructor
  AuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    DatabaseService? databaseService,
  }) : 
    _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
    _databaseService = databaseService ?? DatabaseService();
  
  // Initialize auth service
  Future<void> init() async {
    try {
      // Check if user is already logged in via Firebase
      final currentUser = _firebaseAuth.currentUser;
      
      AppLogger.error('Auth service init: Firebase user: ${currentUser?.uid}', null, null);
      
      if (currentUser == null) {
        // No user logged in, mark as unauthenticated immediately
        _status = AuthStatus.unauthenticated;
        _currentUser = null;
        notifyListeners();
        AppLogger.error('Auth service init: No user, setting status to unauthenticated', null, null);
      } else {
        // User is logged in, load their data
        await _updateUserData(currentUser);
        AppLogger.error('Auth service init: User found, updated user data', null, null);
      }
      
      // Listen to auth state changes for future login/logout
      _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
      AppLogger.error('Auth service init complete. Status: $_status', null, null);
    } catch (e, stack) {
      AppLogger.error('Failed to initialize auth service', e, stack);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }
  
  // Handle auth state changes
  Future<void> _onAuthStateChanged(firebase_auth.User? firebaseUser) async {
    AppLogger.error('Auth state changed. User: ${firebaseUser?.uid}', null, null);
    
    if (firebaseUser == null) {
      // User is not authenticated
      _status = AuthStatus.unauthenticated;
      _currentUser = null;
      _clearUserPreferences();
      notifyListeners();
      AppLogger.error('Auth state changed to: unauthenticated (null user)', null, null);
      return;
    }
    
    try {
      // Update user data
      await _updateUserData(firebaseUser);
      
      // User is authenticated
      _status = AuthStatus.authenticated;
      notifyListeners();
      AppLogger.error('Auth state changed to: authenticated. User ID: ${firebaseUser.uid}', null, null);
    } catch (e, stack) {
      AppLogger.error('Error processing auth state change', e, stack);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      AppLogger.error('Auth state error - setting to unauthenticated', null, null);
    }
  }
  
  // Update user data
  Future<void> _updateUserData(firebase_auth.User firebaseUser) async {
    try {
      // Create or update user in database
      User? userData;
      
      try {
        userData = await _databaseService.getUser(firebaseUser.uid);
      } catch (e) {
        AppLogger.error('Failed to get user data, will create new user', e);
        // Continue with creation flow if we can't fetch the user
      }
      
      if (userData != null) {
        // User exists in database
        _currentUser = userData;
        _status = AuthStatus.authenticated;
      } else {
        // User doesn't exist, create a new one
        final newUser = User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          phoneNumber: firebaseUser.phoneNumber,
          profileImageUrl: firebaseUser.photoURL,
          emailVerified: firebaseUser.emailVerified,
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );
        
        // Create user in database
        try {
          await _databaseService.createUser(newUser);
          _currentUser = newUser;
          _status = AuthStatus.authenticated;
        } catch (e) {
          // If database creation fails, still set the user data from Firebase
          AppLogger.error('Failed to create user in database, using Firebase data', e);
          _currentUser = newUser;
          _status = AuthStatus.authenticated;
        }
      }
      
      // Save to preferences
      await _saveUserToPreferences();
      notifyListeners();
    } catch (e, stack) {
      AppLogger.error('Failed to update user data', e, stack);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }
  
  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Update user last active
        await _databaseService.updateUserLastActive(result.user!.uid);
        
        // Get user data
        final userData = await _databaseService.getUser(result.user!.uid);
        _currentUser = userData;
        
        // Update authentication status
        _status = AuthStatus.authenticated;
        notifyListeners();
        
        // Save to preferences
        await _saveUserToPreferences();
        
        return _currentUser;
      }
      return null;
    } catch (e, stack) {
      AppLogger.error('Failed to sign in with email and password', e, stack);
      rethrow;
    }
  }
  
  // Create user with email and password
  Future<User?> createUserWithEmailAndPassword(
    String email, 
    String password, 
    String displayName,
  ) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Update user profile
        await result.user!.updateDisplayName(displayName);
        
        // Create user in database
        final newUser = User(
          id: result.user!.uid,
          email: email,
          displayName: displayName,
          emailVerified: false,
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );
        
        await _databaseService.createUser(newUser);
        _currentUser = newUser;
        
        // Update authentication status
        _status = AuthStatus.authenticated;
        notifyListeners();
        
        // Save to preferences
        await _saveUserToPreferences();
        
        return _currentUser;
      }
      return null;
    } catch (e, stack) {
      AppLogger.error('Failed to create user with email and password', e, stack);
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      _currentUser = null;
      _clearUserPreferences();
    } catch (e, stack) {
      AppLogger.error('Failed to sign out', e, stack);
      rethrow;
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e, stack) {
      AppLogger.error('Failed to reset password', e, stack);
      rethrow;
    }
  }
  
  // Update profile
  Future<User?> updateProfile({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    String? shortDescription,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Update Firebase Auth profile
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }
      
      // Update database profile
      if (_currentUser != null) {
        final updatedUser = _currentUser!.copyWith(
          displayName: displayName ?? _currentUser!.displayName,
          profileImageUrl: photoURL ?? _currentUser!.profileImageUrl,
          phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
          shortDescription: shortDescription ?? _currentUser!.shortDescription,
          lastActive: DateTime.now(),
        );
        
        await _databaseService.updateUser(updatedUser);
        _currentUser = updatedUser;
        
        // Save to preferences
        await _saveUserToPreferences();
      }
      
      return _currentUser;
    } catch (e, stack) {
      AppLogger.error('Failed to update profile', e, stack);
      rethrow;
    }
  }
  
  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e, stack) {
      AppLogger.error('Failed to send email verification', e, stack);
      rethrow;
    }
  }
  
  // Update email
  Future<void> updateEmail(String newEmail, String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Re-authenticate user
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      
      // Update email
      await user.updateEmail(newEmail);
      
      // Update database email
      if (_currentUser != null) {
        final updatedUser = _currentUser!.copyWith(
          email: newEmail,
          emailVerified: false,
          lastActive: DateTime.now(),
        );
        
        await _databaseService.updateUser(updatedUser);
        _currentUser = updatedUser;
        
        // Save to preferences
        await _saveUserToPreferences();
        
        // Send verification email
        await sendEmailVerification();
      }
    } catch (e, stack) {
      AppLogger.error('Failed to update email', e, stack);
      rethrow;
    }
  }
  
  // Update password
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Re-authenticate user
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      
      // Update password
      await user.updatePassword(newPassword);
    } catch (e, stack) {
      AppLogger.error('Failed to update password', e, stack);
      rethrow;
    }
  }
  
  // Save user to preferences
  Future<void> _saveUserToPreferences() async {
    try {
      if (_currentUser == null) return;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _currentUser!.id);
      await prefs.setString('user_email', _currentUser!.email);
      await prefs.setString('user_display_name', _currentUser!.displayName ?? '');
      await prefs.setString('user_photo_url', _currentUser!.profileImageUrl ?? '');
      await prefs.setBool('user_email_verified', _currentUser!.emailVerified);
    } catch (e, stack) {
      AppLogger.error('Failed to save user to preferences', e, stack);
    }
  }
  
  // Load user from preferences
  // ignore: unused_element
  Future<void> _loadUserFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final userId = prefs.getString('user_id');
      if (userId == null || userId.isEmpty) return;
      
      _currentUser = User(
        id: userId,
        email: prefs.getString('user_email') ?? '',
        displayName: prefs.getString('user_display_name'),
        profileImageUrl: prefs.getString('user_photo_url'),
        emailVerified: prefs.getBool('user_email_verified') ?? false,
      );
      
      _status = AuthStatus.authenticated;
    } catch (e, stack) {
      AppLogger.error('Failed to load user from preferences', e, stack);
    }
  }
  
  // Clear user preferences
  Future<void> _clearUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_display_name');
      await prefs.remove('user_photo_url');
      await prefs.remove('user_email_verified');
    } catch (e, stack) {
      AppLogger.error('Failed to clear user preferences', e, stack);
    }
  }
}