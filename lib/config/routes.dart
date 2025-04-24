import 'package:flutter/material.dart';

// Screen imports will go here
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/register_screen.dart';
import '../ui/screens/auth/forgot_password_screen.dart';
import '../ui/screens/splash_screen.dart';
import '../ui/screens/onboarding_screen.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/profile_screen.dart';
import '../ui/screens/activities/activities_screen.dart';
import '../ui/screens/activities/activity_details_screen.dart';
import '../ui/screens/activities/start_resbite_screen.dart';
import '../ui/screens/resbites/resbites_screen.dart';
import '../ui/screens/resbites/resbite_details_screen.dart';
import '../ui/screens/shadcn_demo_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String activities = '/activities';
  static const String activityDetails = '/activities/details';
  static const String startResbite = '/start-resbite';
  static const String resbites = '/resbites';
  static const String resbiteDetails = '/resbites/details';
  static const String shadcnDemo = '/shadcn-demo';
  
  // Route generation
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract arguments if any
    final args = settings.arguments;
    
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case activities:
        return MaterialPageRoute(builder: (_) => const ActivitiesScreen());
      case activityDetails:
        // Check if args is a Map with id
        final String activityId = args is Map ? args['id'] : '';
        return MaterialPageRoute(
          builder: (_) => ActivityDetailsScreen(activityId: activityId),
        );
      case startResbite:
        // Handle both direct String argument and Map argument formats
        final String? activityId = args is Map 
            ? args['activityId'] as String? 
            : (args is String ? args : null);
        return MaterialPageRoute(
          builder: (_) => StartResbiteScreen(activityId: activityId),
        );
      case resbites:
        return MaterialPageRoute(builder: (_) => const ResbitesScreen());
      case resbiteDetails:
        // Check if args is a Map with id
        final String resbiteId = args is Map ? args['id'] : '';
        return MaterialPageRoute(
          builder: (_) => ResbiteDetailsScreen(resbiteId: resbiteId),
        );
      case shadcnDemo:
        return MaterialPageRoute(builder: (_) => const ShadcnDemoScreen());
      default:
        // If route not found, return 404 error page
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }
}