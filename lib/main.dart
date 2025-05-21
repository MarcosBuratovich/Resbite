import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/constants.dart';
import 'config/env.dart';
import 'config/feature_flags.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'services/providers.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/splash_screen.dart';
import 'utils/logger.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load environment variables
    await Env.initialize();
    
    // Initialize Supabase
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Initialize feature flags
    await FeatureFlags.initialize();
    
    // Run the app
    runApp(const ProviderScope(child: ResbiteMaterialApp()));
  } catch (e, stack) {
    AppLogger.error('Failed to initialize app', e, stack);
    // Show an error screen or fallback UI
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Failed to initialize app. Please try again.'),
        ),
      ),
    ));
  }
}

class ResbiteMaterialApp extends ConsumerStatefulWidget {
  const ResbiteMaterialApp({super.key});

  @override
  ConsumerState<ResbiteMaterialApp> createState() => _ResbiteMaterialAppState();
}

class _ResbiteMaterialAppState extends ConsumerState<ResbiteMaterialApp> {
  @override
  void initState() {
    super.initState();
    // Initialize auth service
    final authService = ref.read(authServiceProvider);
    authService.init();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the theme mode
    final themeMode = ref.watch(themeModeProvider);
    
    // Watch the auth status
    final authStatus = ref.watch(authStatusProvider);
    
    return MaterialApp(
      title: AppConstants.appName,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRoutes.generateRoute,
      home: _buildHomeScreen(authStatus),
      builder: (context, child) {
        return child!;
      },
    );
  }
  
  Widget _buildHomeScreen(AsyncValue<AuthStatus> authStatusAsync) {
    return authStatusAsync.when(
      data: (status) {
        switch (status) {
          case AuthStatus.authenticated:
            return const HomeScreen();
          case AuthStatus.unauthenticated:
            return const LoginScreen();
          case AuthStatus.uninitialized:
          // ignore: unreachable_switch_default
          default:
            return const SplashScreen();
        }
      },
      loading: () => const SplashScreen(),
      error: (_, __) => const LoginScreen(),
    );
  }
}
