import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../services/providers.dart';
import '../../../services/storage_service.dart';
import '../../../utils/logger.dart';
import '../../../ui/components/resbite_button.dart';

// Provider to hold registration data across screens
final registrationDataProvider = StateProvider<RegistrationData>((ref) {
  return RegistrationData();
});

// Provider to track submission state
final isSubmittingProvider = StateProvider<bool>((ref) => false);

// Data model for registration
class RegistrationData {
  DateTime? dateOfBirth;
  String? firstName;
  String? lastName;
  String? displayName;
  String? email;
  String? password;
  File? profileImage;
  String? phoneNumber;
  String? bio;
  String? location;
  String? interests;
  
  // Age calculation
  int get age {
    if (dateOfBirth == null) return 0;
    final today = DateTime.now();
    int age = today.year - dateOfBirth!.year;
    if (today.month < dateOfBirth!.month || 
        (today.month == dateOfBirth!.month && today.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }
  
  // Check if age is valid (16+)
  bool get isAgeValid => age >= 16;
  
  // Check if data for each step is complete
  bool isStep1Valid() => dateOfBirth != null && isAgeValid;
  bool isStep2Valid() => firstName != null && firstName!.isNotEmpty && 
                         lastName != null && lastName!.isNotEmpty && 
                         displayName != null && displayName!.isNotEmpty;
  bool isStep3Valid() => email != null && email!.isNotEmpty && 
                         password != null && password!.length >= AppConstants.minPasswordLength;
  bool isStep5Valid() => true; // Optional fields
  
  // Full name
  String get fullName => '$firstName $lastName';
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;
  final PageController _pageController = PageController();
  
  // Registration steps pages
  final List<Widget> _pages = [];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize pages
    _pages.addAll([
      _DateOfBirthPage(onNext: _goToNextStep),
      _NamePage(onNext: _goToNextStep, onBack: _goToPreviousStep),
      _CredentialsPage(onNext: _goToNextStep, onBack: _goToPreviousStep),
      _ProfileImagePage(onNext: _goToNextStep, onBack: _goToPreviousStep),
      _AdditionalInfoPage(onNext: _goToNextStep, onBack: _goToPreviousStep),
      _ReviewPage(onSubmit: _submitRegistration, onBack: _goToPreviousStep),
    ]);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _goToNextStep() {
    if (_currentStep < _pages.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  Future<void> _submitRegistration() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    // Update the submitting state for UI updates
    ref.read(isSubmittingProvider.notifier).state = true;
    
    try {
      final registrationData = ref.read(registrationDataProvider);
      
      // Validate all required data
      if (!registrationData.isStep1Valid() || 
          !registrationData.isStep2Valid() || 
          !registrationData.isStep3Valid()) {
        setState(() {
          _errorMessage = 'Please complete all required fields';
          _isLoading = false;
        });
        ref.read(isSubmittingProvider.notifier).state = false;
        return;
      }
      
      // Get auth service
      final authService = ref.read(authServiceProvider);
      
      // Create user with email and password
      final user = await authService.createUserWithEmailAndPassword(
        registrationData.email!,
        registrationData.password!,
        registrationData.displayName!,
      );
      
      if (user != null) {
        String? profileImageUrl;
        
        // Upload profile image if selected
        if (registrationData.profileImage != null) {
          try {
            // Get storage service
            final storageService = ref.read(storageServiceProvider);
            
            // Check if file exists and is accessible
            if (!registrationData.profileImage!.existsSync()) {
              AppLogger.error('Profile image file does not exist', null);
              // Show error message but continue with registration
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not access profile image file, but your account will still be created'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            } else {
              // Upload profile image
              AppLogger.info('Starting profile image upload for user: ${user.id}', null);
              
              profileImageUrl = await storageService.uploadProfileImage(
                imageFile: registrationData.profileImage!,
                userId: user.id,
              );
              
              if (profileImageUrl != null) {
                AppLogger.info('Profile image uploaded successfully: $profileImageUrl', null);
              } else {
                AppLogger.error('Profile image upload returned null URL', null);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile image could not be uploaded, but your account has been created'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }
            }
          } catch (e) {
            // If image upload fails, continue with the registration but log the error
            AppLogger.error('Failed to upload profile image', e);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Profile image upload failed: ${e.toString()}, but your account has been created'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }
        }
        
        // Add additional profile data
        await authService.updateProfile(
          displayName: registrationData.displayName,
          phoneNumber: registrationData.phoneNumber,
          shortDescription: registrationData.bio,
          photoURL: profileImageUrl, // Include the profile image URL if available
        );
        
        // Add additional location and interests data if provided
        if (registrationData.location != null || registrationData.interests != null) {
          try {
            final databaseService = ref.read(databaseServiceProvider);
            final Map<String, dynamic> additionalData = {};
            
            if (registrationData.location != null && registrationData.location!.isNotEmpty) {
              additionalData['location'] = registrationData.location;
            }
            
            if (registrationData.interests != null && registrationData.interests!.isNotEmpty) {
              additionalData['interests'] = registrationData.interests;
            }
            
            if (additionalData.isNotEmpty) {
              await databaseService.updateUserData(user.id, additionalData);
            }
          } catch (e) {
            // If additional data update fails, continue but log the error
            AppLogger.error('Failed to update additional user data', e);
          }
        }
        
        if (!mounted) return;
        
        // Navigate to home screen on success
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        setState(() {
          _errorMessage = 'Failed to create account';
        });
        ref.read(isSubmittingProvider.notifier).state = false;
      }
    } catch (e) {
      AppLogger.error('Registration error', e);
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
      ref.read(isSubmittingProvider.notifier).state = false;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Ensure submitting state is reset
        ref.read(isSubmittingProvider.notifier).state = false;
      }
    }
  }
  
  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Create Account'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goToPreviousStep,
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: _navigateToLogin,
              ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / _pages.length,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            
            // Step counter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Step ${_currentStep + 1} of ${_pages.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Error message
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                  ),
                ),
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Loading overlay
            if (_isLoading)
              Expanded(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Creating your account...',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            // Registration pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: _pages,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// STEP 1: Date of Birth page
class _DateOfBirthPage extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  
  const _DateOfBirthPage({required this.onNext});
  
  @override
  ConsumerState<_DateOfBirthPage> createState() => _DateOfBirthPageState();
}

class _DateOfBirthPageState extends ConsumerState<_DateOfBirthPage> {
  final TextEditingController _dobController = TextEditingController();
  DateTime? _selectedDate;
  bool _showAgeError = false;
  
  @override
  void initState() {
    super.initState();
    // Pre-fill from provider if available
    final registrationData = ref.read(registrationDataProvider);
    if (registrationData.dateOfBirth != null) {
      _selectedDate = registrationData.dateOfBirth;
      _dobController.text = DateFormat('MM/dd/yyyy').format(_selectedDate!);
    }
  }
  
  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime minDate = DateTime(now.year - 100, now.month, now.day); // 100 years ago
    final DateTime maxDate = DateTime(now.year - 16, now.month, now.day); // 16 years ago
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? maxDate,
      firstDate: minDate,
      lastDate: now,
      helpText: 'SELECT DATE OF BIRTH',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('MM/dd/yyyy').format(_selectedDate!);
        
        // Update provider
        final registrationData = ref.read(registrationDataProvider.notifier);
        registrationData.update((state) => state..dateOfBirth = _selectedDate);
        
        // Check age
        _validateAge();
      });
    }
  }
  
  void _validateAge() {
    if (_selectedDate != null) {
      final registrationData = ref.read(registrationDataProvider);
      setState(() {
        _showAgeError = !registrationData.isAgeValid;
      });
    }
  }
  
  void _continueToNext() {
    if (_selectedDate != null) {
      final registrationData = ref.read(registrationDataProvider);
      if (registrationData.isAgeValid) {
        widget.onNext();
      } else {
        setState(() {
          _showAgeError = true;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'When were you born?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            'You must be at least 16 years old to use Resbite.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          
          // Date of birth field
          TextFormField(
            controller: _dobController,
            decoration: InputDecoration(
              labelText: 'Date of Birth',
              hintText: 'MM/DD/YYYY',
              prefixIcon: const Icon(Icons.calendar_today),
              suffixIcon: IconButton(
                icon: const Icon(Icons.event),
                onPressed: () => _selectDate(context),
              ),
              errorText: _showAgeError ? 'You must be at least 16 years old' : null,
            ),
            readOnly: true,
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 8),
          
          // Age display
          if (_selectedDate != null && !_showAgeError)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'You are ${ref.read(registrationDataProvider).age} years old',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          
          const Spacer(),
          
          // Continue button
          ResbiteButton(
            text: 'Continue',
            icon: Icons.arrow_forward,
            type: ResbiteBtnType.gradient,
            size: ResbiteBtnSize.large,
            fullWidth: true,
            onPressed: _selectedDate != null ? _continueToNext : null,
          ),
        ],
      ),
    );
  }
}

// STEP 2: Name page
class _NamePage extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  
  const _NamePage({required this.onNext, required this.onBack});
  
  @override
  ConsumerState<_NamePage> createState() => _NamePageState();
}

class _NamePageState extends ConsumerState<_NamePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Pre-fill from provider if available
    final registrationData = ref.read(registrationDataProvider);
    if (registrationData.firstName != null) {
      _firstNameController.text = registrationData.firstName!;
    }
    if (registrationData.lastName != null) {
      _lastNameController.text = registrationData.lastName!;
    }
    if (registrationData.displayName != null) {
      _displayNameController.text = registrationData.displayName!;
    }
  }
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }
  
  void _updateDisplayNameSuggestion() {
    // Generate display name suggestion
    if (_firstNameController.text.isNotEmpty && _displayNameController.text.isEmpty) {
      _displayNameController.text = _firstNameController.text;
    }
  }
  
  void _continueToNext() {
    if (_formKey.currentState!.validate()) {
      // Update provider
      final registrationData = ref.read(registrationDataProvider.notifier);
      registrationData.update((state) => state
        ..firstName = _firstNameController.text.trim()
        ..lastName = _lastNameController.text.trim()
        ..displayName = _displayNameController.text.trim()
      );
      
      widget.onNext();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'What\'s your name?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Subtitle
            Text(
              'Let us know how to address you.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            
            // First name field
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                hintText: 'Enter your first name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
              onChanged: (_) => _updateDisplayNameSuggestion(),
            ),
            const SizedBox(height: 16),
            
            // Last name field
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                hintText: 'Enter your last name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Display name field
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'How you want to be known on Resbite',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a display name';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            
            // Helper text
            Text(
              'This is the name other users will see on Resbite',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
            
            const Spacer(),
            
            // Continue button
            ResbiteButton(
              text: 'Continue',
              icon: Icons.arrow_forward,
              type: ResbiteBtnType.gradient,
              size: ResbiteBtnSize.large,
              fullWidth: true,
              onPressed: _continueToNext,
            ),
          ],
        ),
      ),
    );
  }
}

// STEP 3: Credentials page (email & password)
class _CredentialsPage extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  
  const _CredentialsPage({required this.onNext, required this.onBack});
  
  @override
  ConsumerState<_CredentialsPage> createState() => _CredentialsPageState();
}

class _CredentialsPageState extends ConsumerState<_CredentialsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  @override
  void initState() {
    super.initState();
    // Pre-fill from provider if available
    final registrationData = ref.read(registrationDataProvider);
    if (registrationData.email != null) {
      _emailController.text = registrationData.email!;
    }
    if (registrationData.password != null) {
      _passwordController.text = registrationData.password!;
      _confirmPasswordController.text = registrationData.password!;
    }
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
  
  // Validate confirm password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
  
  void _continueToNext() {
    if (_formKey.currentState!.validate()) {
      // Update provider
      final registrationData = ref.read(registrationDataProvider.notifier);
      registrationData.update((state) => state
        ..email = _emailController.text.trim()
        ..password = _passwordController.text
      );
      
      widget.onNext();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Set up your account',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Subtitle
            Text(
              'Create your login credentials.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            
            // Email field
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            
            // Password field
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Create a password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              validator: _validatePassword,
            ),
            const SizedBox(height: 16),
            
            // Confirm password field
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              validator: _validateConfirmPassword,
            ),
            const SizedBox(height: 8),
            
            // Password hint
            Text(
              'Password must be at least ${AppConstants.minPasswordLength} characters',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
            
            const Spacer(),
            
            // Continue button
            ResbiteButton(
              text: 'Continue',
              icon: Icons.arrow_forward,
              type: ResbiteBtnType.gradient,
              size: ResbiteBtnSize.large,
              fullWidth: true,
              onPressed: _continueToNext,
            ),
          ],
        ),
      ),
    );
  }
}

// STEP 4: Profile Image page
class _ProfileImagePage extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  
  const _ProfileImagePage({required this.onNext, required this.onBack});
  
  @override
  ConsumerState<_ProfileImagePage> createState() => _ProfileImagePageState();
}

class _ProfileImagePageState extends ConsumerState<_ProfileImagePage> {
  File? _imageFile;
  
  @override
  void initState() {
    super.initState();
    // Get image from provider if available
    final registrationData = ref.read(registrationDataProvider);
    if (registrationData.profileImage != null) {
      _imageFile = registrationData.profileImage;
    }
  }
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Show loading indicator during image processing
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Processing image...'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        // Set lower image quality for profile pictures to optimize storage
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 70,
      );
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        
        // Update provider
        final registrationData = ref.read(registrationDataProvider.notifier);
        registrationData.update((state) => state..profileImage = _imageFile);
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image selected successfully'),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Error picking image', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _continueToNext() {
    // Update provider
    final registrationData = ref.read(registrationDataProvider.notifier);
    registrationData.update((state) => state..profileImage = _imageFile);
    
    widget.onNext();
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Add a profile picture',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            'Help other Resbite users recognize you.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 40),
          
          // Profile image preview and selection
          Center(
            child: GestureDetector(
              onTap: _showImageSourceDialog,
              child: Stack(
                children: [
                  // Image container
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                      image: _imageFile != null
                          ? DecorationImage(
                              image: FileImage(_imageFile!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _imageFile == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                size: 64,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add Photo',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                  
                  // Camera icon overlay
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppTheme.primaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Guide text
          Center(
            child: Text(
              _imageFile == null
                  ? 'Tap to choose a profile picture'
                  : 'Tap to change your profile picture',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          
          const Spacer(),
          
          // Continue button
          ResbiteButton(
            text: 'Continue',
            icon: Icons.arrow_forward,
            type: ResbiteBtnType.gradient,
            size: ResbiteBtnSize.large,
            fullWidth: true,
            // Allow skipping this step
            onPressed: _continueToNext,
          ),
          
          // Skip option
          if (_imageFile == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextButton(
                  onPressed: _continueToNext,
                  child: Text(
                    'Skip for now',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// STEP 5: Additional Information page
class _AdditionalInfoPage extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  
  const _AdditionalInfoPage({required this.onNext, required this.onBack});
  
  @override
  ConsumerState<_AdditionalInfoPage> createState() => _AdditionalInfoPageState();
}

class _AdditionalInfoPageState extends ConsumerState<_AdditionalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _interestsController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Pre-fill from provider if available
    final registrationData = ref.read(registrationDataProvider);
    if (registrationData.phoneNumber != null) {
      _phoneController.text = registrationData.phoneNumber!;
    }
    if (registrationData.bio != null) {
      _bioController.text = registrationData.bio!;
    }
    if (registrationData.location != null) {
      _locationController.text = registrationData.location!;
    }
    if (registrationData.interests != null) {
      _interestsController.text = registrationData.interests!;
    }
  }
  
  @override
  void dispose() {
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _interestsController.dispose();
    super.dispose();
  }
  
  void _continueToNext() {
    // These fields are optional, so no validation required
    // Update provider
    final registrationData = ref.read(registrationDataProvider.notifier);
    registrationData.update((state) => state
      ..phoneNumber = _phoneController.text.trim()
      ..bio = _bioController.text.trim()
      ..location = _locationController.text.trim()
      ..interests = _interestsController.text.trim()
    );
    
    widget.onNext();
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Tell us more about you',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'These details help personalize your experience (optional).',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              
              // Phone field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              
              // Bio field
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Tell us a bit about yourself',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                maxLength: 200,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              
              // Location field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'City, Country',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              
              // Interests field
              TextFormField(
                controller: _interestsController,
                decoration: const InputDecoration(
                  labelText: 'Interests',
                  hintText: 'What activities do you enjoy?',
                  prefixIcon: Icon(Icons.interests_outlined),
                ),
                maxLength: 100,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),
              
              // Continue button
              ResbiteButton(
                text: 'Continue',
                icon: Icons.arrow_forward,
                type: ResbiteBtnType.gradient,
                size: ResbiteBtnSize.large,
                fullWidth: true,
                onPressed: _continueToNext,
              ),
              
              // Skip option
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextButton(
                    onPressed: _continueToNext,
                    child: Text(
                      'Skip for now',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// STEP 6: Review and confirmation page
class _ReviewPage extends ConsumerWidget {
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  
  const _ReviewPage({required this.onSubmit, required this.onBack});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrationData = ref.watch(registrationDataProvider);
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Review your information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Subtitle
            Text(
              'Please confirm that everything is correct.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            
            // Profile image section
            Center(
              child: Column(
                children: [
                  if (registrationData.profileImage != null)
                    Container(
                      width: 120,
                      height: 120,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                        image: DecorationImage(
                          image: FileImage(registrationData.profileImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 120,
                      height: 120,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                      ),
                    ),
                    
                  // Profile image message
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      registrationData.profileImage != null
                          ? 'Your profile image will be uploaded'
                          : 'No profile image selected (optional)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Information sections
            _buildInfoSection(
              context,
              title: 'Personal Information',
              items: [
                {'label': 'Name', 'value': registrationData.fullName},
                {'label': 'Display Name', 'value': registrationData.displayName ?? ''},
                {'label': 'Date of Birth', 'value': DateFormat('MM/dd/yyyy').format(registrationData.dateOfBirth!)},
                {'label': 'Email', 'value': registrationData.email ?? ''},
                if (registrationData.phoneNumber != null && registrationData.phoneNumber!.isNotEmpty)
                  {'label': 'Phone', 'value': registrationData.phoneNumber!},
              ],
            ),
            
            if (registrationData.bio != null && registrationData.bio!.isNotEmpty ||
                registrationData.location != null && registrationData.location!.isNotEmpty ||
                registrationData.interests != null && registrationData.interests!.isNotEmpty)
              _buildInfoSection(
                context,
                title: 'Additional Information',
                items: [
                  if (registrationData.bio != null && registrationData.bio!.isNotEmpty)
                    {'label': 'Bio', 'value': registrationData.bio!},
                  if (registrationData.location != null && registrationData.location!.isNotEmpty)
                    {'label': 'Location', 'value': registrationData.location!},
                  if (registrationData.interests != null && registrationData.interests!.isNotEmpty)
                    {'label': 'Interests', 'value': registrationData.interests!},
                ],
              ),
            
            const SizedBox(height: 32),
            
            // Terms and conditions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'By creating an account, you agree to our:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Terms of Service & Privacy Policy',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Create Account button
            Consumer(
              builder: (context, ref, _) {
                final isLoading = ref.watch(isSubmittingProvider);
                return ResbiteButton(
                  text: isLoading ? 'Creating Account...' : 'Create Account',
                  icon: isLoading ? Icons.hourglass_top : Icons.check_circle,
                  type: ResbiteBtnType.gradient,
                  size: ResbiteBtnSize.large,
                  fullWidth: true,
                  onPressed: isLoading ? null : onSubmit,
                );
              },
            ),
            
            // Edit information option
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextButton(
                  onPressed: onBack,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Edit information',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoSection(BuildContext context, {required String title, required List<Map<String, String>> items}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          
          // Items
          ...items.map((item) => _buildInfoItem(context, item['label']!, item['value']!)),
        ],
      ),
    );
  }
  
  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: value.length > 30 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          // Label
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          
          // Value
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}