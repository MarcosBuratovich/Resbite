import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../components/resbite_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  int _currentPage = 0;
  
  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Welcome to Resbite',
      'description': 'Find and join activities with other families in your area.',
      'animation': 'assets/animations/welcome.json',
      'color': const Color(0xFF89CAC7), // Teal
    },
    {
      'title': 'Discover Activities',
      'description': 'Browse through many family activities and pick your favorites.',
      'animation': 'assets/animations/discover.json',
      'color': const Color(0xFF462748), // Purple
    },
    {
      'title': 'Create Resbites',
      'description': 'Organize your own activities and invite others to join.',
      'animation': 'assets/animations/create.json',
      'color': const Color(0xFFEFB0B4), // Pink
    },
    {
      'title': 'Connect with Others',
      'description': 'Build your network and make lasting memories together.',
      'animation': 'assets/animations/connect.json',
      'color': const Color(0xFF89CAC7), // Teal
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 400),
    );
    // Set system UI overlay style for immersive experience
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    
    // Animate when page changes
    _animationController.reset();
    _animationController.forward();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }
  
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    // Save onboarding completed status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefKeyOnboardingComplete, true);
    
    // Navigate to login screen
    if (!mounted) return;
    
    // Add a brief animation before navigation
    await _animationController.forward();
    
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    // Get current page color or default to the primary color
    final Color pageColor = _currentPage < _onboardingData.length 
        ? _onboardingData[_currentPage]['color'] 
        : AppTheme.primaryColor;
    
    // Determine if we're on the last page
    final bool isLastPage = _currentPage == _onboardingData.length - 1;
    
    // Choose text color based on background
    final Color textColor = pageColor == AppTheme.secondaryColor 
        ? AppTheme.lightTextColor 
        : AppTheme.darkTextColor;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button and page indicator row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (hidden on first page)
                  _currentPage > 0
                      ? TextButton.icon(
                          onPressed: _previousPage,
                          icon: const Icon(Icons.arrow_back_ios, size: 16),
                          label: const Text('Back'),
                          style: TextButton.styleFrom(
                            foregroundColor: pageColor,
                          ),
                        )
                      : const SizedBox(width: 80), // Placeholder for alignment
                  
                  // Page indicator
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 16 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == index
                              ? pageColor
                              : pageColor.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  
                  // Skip button
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: pageColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      // Apply a fade transition
                      return FadeTransition(
                        opacity: Tween<double>(begin: 0.8, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOut,
                          ),
                        ),
                        // Apply a slight slide transition
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Curves.easeOut,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animation placeholder
                          Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              color: _onboardingData[index]['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Lottie.asset(
                                _onboardingData[index]['animation'],
                                // If animation files aren't available, show a backup icon
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.animation,
                                    size: 100,
                                    color: _onboardingData[index]['color'].withOpacity(0.5),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          
                          // Title
                          Text(
                            _onboardingData[index]['title'],
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _onboardingData[index]['color'],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          
                          // Description
                          Text(
                            _onboardingData[index]['description'],
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.darkTextColor.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ResbiteButton(
                text: isLastPage ? 'Get Started' : 'Next',
                icon: isLastPage ? Icons.rocket_launch : Icons.arrow_forward,
                type: ResbiteBtnType.primary,
                backgroundColor: pageColor,
                textColor: pageColor == AppTheme.secondaryColor ? AppTheme.lightTextColor : null,
                size: ResbiteBtnSize.large,
                fullWidth: true,
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}