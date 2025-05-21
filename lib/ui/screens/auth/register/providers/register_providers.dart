import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Re-export registration data provider from the models
export '../../../../../models/registration_data.dart';

/// Provider for the current registration step
final registrationStepProvider = StateProvider<int>((ref) => 0);

/// Provider for the page controller used in registration flow
final pageControllerProvider = Provider<PageController>((ref) {
  final controller = PageController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

/// Provider to manage loading state during registration submission
final isSubmittingProvider = StateProvider<bool>((ref) => false);

/// Provider for tracking registration validation errors
final registrationErrorProvider = StateProvider<String?>((ref) => null);

/// Provider for profile image validation in registration
final profileImageErrorProvider = StateProvider<String?>((ref) => null);
