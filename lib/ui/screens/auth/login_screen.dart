import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resbite_app/components/ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../config/constants.dart';
import '../../../services/providers.dart';
import '../../../utils/logger.dart';
import '../../../styles/tailwind_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validate email format
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Validate password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }

  Future<void> _signIn() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get auth service
      final authService = ref.read(authServiceProvider);

      AppLogger.error(
        'Attempting to sign in with email: ${_emailController.text.trim()}',
        null,
        null,
      );

      // Sign in with email and password
      await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      // Auth status has changed, wait a moment for it to propagate through providers
      // The onAuthStateChange listener in AuthService will update the status.
      await Future.delayed(const Duration(milliseconds: 300));

      // Check current auth status before navigating
      final currentStatus = authService.status;
      AppLogger.error(
        'Current auth status after sign-in attempt: $currentStatus',
        null,
        null,
      );

      if (currentStatus == AuthStatus.authenticated) {
        AppLogger.info('Sign in successful. Navigating to home.');
        // Navigate to home screen on success
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        // If not authenticated, it means sign-in failed (e.g. wrong credentials)
        // The error should have been caught by the try-catch block in _signIn or displayed by Supabase.
        // We can set a generic error message here if not already handled by a catch.
        if (mounted && _errorMessage == null) { // Only set if no specific error was caught
          setState(() {
            _errorMessage = 'Sign-in failed. Please check your credentials.';
          });
        }
        AppLogger.error(
          'Sign in failed or auth status not updated. Status: $currentStatus',
          null,
          null,
        );
      }
    } on supabase.AuthException catch (e) {
      AppLogger.error('Sign in failed with AuthException: ${e.message}', e,
          StackTrace.current);
      setState(() {
        _errorMessage = 'Error: ${e.message}';
      });
    } catch (e) {
      AppLogger.error('Login error', e);
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).pushReplacementNamed('/register');
  }

  void _navigateToForgotPassword() {
    Navigator.of(context).pushNamed('/forgot-password');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header illustration
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SvgPicture.asset(
                          'assets/Resbites Illustrations/SVGs/Artboard 5.svg',
                          height: 180,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 300.ms)
                        .slideY(
                          begin: -0.2,
                          end: 0,
                          duration: 800.ms,
                          curve: Curves.easeOutQuad,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF462748), // Purple from design
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 600.ms, delay: 500.ms),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    'Sign in to your Resbite account',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
                  const SizedBox(height: 40),

                  // Error message
                  if (_errorMessage != null)
                    ShadCard(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.error.withOpacity(0.1),
                      hasBorder: true,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TwTypography.bodySm(context).copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_errorMessage != null) const SizedBox(height: 16),

                  // Login form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email field
                        Animate(
                          effects: [
                            FadeEffect(duration: 600.ms, delay: 700.ms),
                            SlideEffect(
                              begin: const Offset(0.2, 0),
                              end: const Offset(0, 0),
                              duration: 600.ms,
                              delay: 700.ms,
                            ),
                          ],
                          child: ShadInput.email(
                            controller: _emailController,
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            enabled: !_isLoading,
                            validator: _validateEmail,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password field
                        Animate(
                          effects: [
                            FadeEffect(duration: 600.ms, delay: 800.ms),
                            SlideEffect(
                              begin: const Offset(0.2, 0),
                              end: const Offset(0, 0),
                              duration: 600.ms,
                              delay: 800.ms,
                            ),
                          ],
                          child: ShadInput.password(
                            controller: _passwordController,
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            enabled: !_isLoading,
                            validator: _validatePassword,
                            onSubmitted: (_) => _signIn(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Forgot password link
                        Align(
                          alignment: Alignment.centerRight,
                          child: Animate(
                            effects: [
                              FadeEffect(duration: 400.ms, delay: 900.ms),
                            ],
                            child: ShadButton.link(
                              text: 'Forgot Password?',
                              onPressed:
                                  _isLoading ? null : _navigateToForgotPassword,
                              size: ButtonSize.sm,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Sign in button
                        Animate(
                          effects: [
                            FadeEffect(duration: 600.ms, delay: 1000.ms),
                            ScaleEffect(
                              begin: const Offset(0.95, 0.95),
                              end: const Offset(1, 1),
                              duration: 600.ms,
                              delay: 1000.ms,
                            ),
                          ],
                          child: ShadButton.primary(
                            text: 'Sign In',
                            onPressed: _isLoading ? null : _signIn,
                            isLoading: _isLoading,
                            size: ButtonSize.lg,
                            isFullWidth: true,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Register link
                        Animate(
                          effects: [
                            FadeEffect(duration: 600.ms, delay: 1100.ms),
                          ],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              ShadButton.link(
                                text: 'Sign Up',
                                onPressed:
                                    _isLoading ? null : _navigateToRegister,
                                size: ButtonSize.sm,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
