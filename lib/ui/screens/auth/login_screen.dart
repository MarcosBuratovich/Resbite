import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resbite_app/components/ui.dart';
import 'package:resbite_app/components/ui/button.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
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
      
      AppLogger.error('Attempting to sign in with email: ${_emailController.text.trim()}', null, null);
      
      // Sign in with email and password
      final user = await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (!mounted) return;
      
      if (user != null) {
        AppLogger.error('Sign in successful. User: ${user.id}', null, null);
        
        // Auth status has changed, wait a moment for it to propagate through providers
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Check current auth status before navigating
        final currentStatus = authService.status;
        AppLogger.error('Current auth status before navigation: $currentStatus', null, null);
        
        if (currentStatus == AuthStatus.authenticated) {
          // Navigate to home screen on success
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        } else {
          setState(() {
            _errorMessage = 'Authentication state inconsistent. Please try again.';
          });
        }
      } else {
        AppLogger.error('Sign in returned null user', null, null);
        setState(() {
          _errorMessage = 'Failed to sign in. Please check your credentials.';
        });
      }
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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).colorScheme.background, Theme.of(context).colorScheme.background.withOpacity(0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      AppConstants.logoPath,
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    'Welcome Back',
                    style: TwTypography.heading3(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    'Sign in to continue',
                    style: TwTypography.body(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Error message
                  if (_errorMessage != null)
                    ShadCard(
                      backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.1),
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
                        ShadInput.email(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          enabled: !_isLoading,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),
                        
                        // Password field
                        ShadInput.password(
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          enabled: !_isLoading,
                          validator: _validatePassword,
                          onSubmitted: (_) => _signIn(),
                        ),
                        const SizedBox(height: 8),
                        
                        // Forgot password link
                        Align(
                          alignment: Alignment.centerRight,
                          child: ShadButton.link(
                            text: 'Forgot Password?',
                            onPressed: _isLoading ? null : _navigateToForgotPassword,
                            size: ButtonSize.sm,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Sign in button
                        ShadButton.primary(
                          text: 'Sign In',
                          onPressed: _isLoading ? null : _signIn,
                          isLoading: _isLoading,
                          size: ButtonSize.lg,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: 16),
                        
                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TwTypography.bodySm(context),
                            ),
                            ShadButton.link(
                              text: 'Sign Up',
                              onPressed: _isLoading ? null : _navigateToRegister,
                              size: ButtonSize.sm,
                            ),
                          ],
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