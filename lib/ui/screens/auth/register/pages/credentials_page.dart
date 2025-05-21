import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../config/constants.dart';
import '../../../../../../ui/components/resbite_button.dart';
import '../providers/register_providers.dart';
import '../utils/validation_utils.dart';

/// Página para capturar credenciales (email y password) durante el registro
class CredentialsPage extends ConsumerStatefulWidget {
  /// Callback para avanzar al siguiente paso
  final VoidCallback onNext;
  
  /// Callback para regresar al paso anterior
  final VoidCallback onBack;

  const CredentialsPage({
    required this.onNext,
    required this.onBack,
    super.key,
  });

  @override
  ConsumerState<CredentialsPage> createState() => _CredentialsPageState();
}

class _CredentialsPageState extends ConsumerState<CredentialsPage> {
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

  /// Valida la confirmación de contraseña
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Avanza al siguiente paso si las credenciales son válidas
  void _continueToNext() {
    if (_formKey.currentState!.validate()) {
      // Update provider
      final registrationNotifier = ref.read(registrationDataProvider.notifier);
      registrationNotifier.setCredentials(
        _emailController.text.trim(),
        _passwordController.text,
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
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildEmailField(),
            const SizedBox(height: 16),
            _buildPasswordField(),
            const SizedBox(height: 16),
            _buildConfirmPasswordField(),
            const SizedBox(height: 8),
            _buildPasswordHint(context),
            const Spacer(),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  /// Construye el encabezado de la página  
  Widget _buildHeader(BuildContext context) {
    return Column(
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
      ],
    );
  }
  
  /// Construye el campo de email
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email address',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: (value) => RegistrationValidator.validateEmail(value),
    );
  }
  
  /// Construye el campo de contraseña
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Create a password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
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
      validator: (value) => RegistrationValidator.validatePassword(value),
    );
  }
  
  /// Construye el campo de confirmación de contraseña
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        hintText: 'Re-enter your password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
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
    );
  }
  
  /// Construye la pista sobre requisitos de contraseña
  Widget _buildPasswordHint(BuildContext context) {
    return Text(
      'Password must be at least ${AppConstants.minPasswordLength} characters',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).round()),
      ),
    );
  }
  
  /// Construye el botón para continuar
  Widget _buildContinueButton() {
    return ResbiteButton(
      text: 'Continue',
      icon: Icons.arrow_forward,
      type: ResbiteBtnType.gradient,
      size: ResbiteBtnSize.large,
      fullWidth: true,
      onPressed: _continueToNext,
    );
  }
}
