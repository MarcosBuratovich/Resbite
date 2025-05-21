import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../ui/components/resbite_button.dart';
import '../providers/register_providers.dart';
import '../utils/validation_utils.dart';

/// Página para capturar información de nombre durante el registro
class NamePage extends ConsumerStatefulWidget {
  /// Callback para avanzar al siguiente paso
  final VoidCallback onNext;
  
  /// Callback para regresar al paso anterior
  final VoidCallback onBack;

  const NamePage({
    required this.onNext, 
    required this.onBack,
    super.key,
  });

  @override
  ConsumerState<NamePage> createState() => _NamePageState();
}

class _NamePageState extends ConsumerState<NamePage> {
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

  /// Actualiza la sugerencia de nombre para mostrar basado en el nombre
  void _updateDisplayNameSuggestion() {
    // Generate display name suggestion
    if (_firstNameController.text.isNotEmpty &&
        _displayNameController.text.isEmpty) {
      _displayNameController.text = _firstNameController.text;
    }
  }

  /// Avanza al siguiente paso si la información es válida
  void _continueToNext() {
    if (_formKey.currentState!.validate()) {
      // Update provider
      final registrationNotifier = ref.read(registrationDataProvider.notifier);
      registrationNotifier.setName(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
      );
      
      // Update display name separately
      registrationNotifier.update(
        (state) => state..displayName = _displayNameController.text.trim(),
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
            _buildFirstNameField(),
            const SizedBox(height: 16),
            _buildLastNameField(),
            const SizedBox(height: 16),
            _buildDisplayNameField(),
            const SizedBox(height: 8),
            _buildHelperText(context),
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
      ],
    );
  }
  
  /// Construye el campo de nombre
  Widget _buildFirstNameField() {
    return TextFormField(
      controller: _firstNameController,
      decoration: const InputDecoration(
        labelText: 'First Name',
        hintText: 'Enter your first name',
        prefixIcon: Icon(Icons.person_outline),
      ),
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      validator: (value) => RegistrationValidator.validateFirstName(value),
      onChanged: (_) => _updateDisplayNameSuggestion(),
    );
  }
  
  /// Construye el campo de apellido
  Widget _buildLastNameField() {
    return TextFormField(
      controller: _lastNameController,
      decoration: const InputDecoration(
        labelText: 'Last Name',
        hintText: 'Enter your last name',
        prefixIcon: Icon(Icons.person_outline),
      ),
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      validator: (value) => RegistrationValidator.validateLastName(value),
    );
  }
  
  /// Construye el campo de nombre para mostrar
  Widget _buildDisplayNameField() {
    return TextFormField(
      controller: _displayNameController,
      decoration: const InputDecoration(
        labelText: 'Display Name',
        hintText: 'How you want to be known on Resbite',
        prefixIcon: Icon(Icons.badge_outlined),
      ),
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
      validator: (value) => RegistrationValidator.validateDisplayName(value),
    );
  }
  
  /// Construye el texto de ayuda
  Widget _buildHelperText(BuildContext context) {
    return Text(
      'This is the name other users will see on Resbite',
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
