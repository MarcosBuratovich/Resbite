import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/constants.dart';
import '../../services/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthStatusAndNavigate();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _animationController.forward();
  }

  Future<void> _checkAuthStatusAndNavigate() async {
    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Check if onboarding has been completed
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool(AppConstants.prefKeyOnboardingComplete) ?? false;
    
    // Check authentication status
    final authService = ref.read(authServiceProvider);
    
    // Force refresh auth status in case it's still uninitialized
    await authService.init();
    
    if (authService.status == AuthStatus.authenticated) {
      _navigateToHome();
    } else if (!onboardingComplete) {
      _navigateToOnboarding();
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }
  
  void _navigateToOnboarding() {
    Navigator.of(context).pushReplacementNamed('/onboarding');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFF89CAC7); // Teal background from designs
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor,
              backgroundColor.withOpacity(0.8),
              const Color(0xFF462748).withOpacity(0.3), // Add a touch of purple
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Animate(
                  effects: [
                    FadeEffect(duration: 800.ms, delay: 300.ms),
                    ScaleEffect(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 800.ms, delay: 300.ms),
                  ],
                  child: SvgPicture.asset(
                    'assets/Resbites Illustrations/SVGs/Artboard 12.svg',
                    width: 200,
                    height: 200,
                    placeholderBuilder: (context) => Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.image,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // App name
                Animate(
                  effects: [
                    FadeEffect(duration: 800.ms, delay: 600.ms),
                    SlideEffect(begin: const Offset(0, 30), end: const Offset(0, 0), duration: 800.ms, delay: 600.ms),
                  ],
                  child: Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Tagline
                Animate(
                  effects: [
                    FadeEffect(duration: 800.ms, delay: 900.ms),
                    SlideEffect(begin: const Offset(0, 20), end: const Offset(0, 0), duration: 800.ms, delay: 900.ms),
                  ],
                  child: Text(
                    AppConstants.appTagline,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Quicksand',
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 64),
                
                // Loading indicator
                Animate(
                  effects: [
                    FadeEffect(duration: 600.ms, delay: 1200.ms),
                  ],
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}