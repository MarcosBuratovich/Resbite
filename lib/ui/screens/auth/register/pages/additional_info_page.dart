import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../ui/components/resbite_button.dart';
import '../providers/register_providers.dart';
import '../utils/validation_utils.dart';

/// Página para capturar información adicional durante el registro
class AdditionalInfoPage extends ConsumerStatefulWidget {
  /// Callback para avanzar al siguiente paso
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AdditionalInfoPage({
    required this.onNext,
    required this.onBack,
    super.key,
  });

  @override
  ConsumerState<AdditionalInfoPage> createState() => _AdditionalInfoPageState();
}

class _AdditionalInfoPageState extends ConsumerState<AdditionalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;
  late final TextEditingController _interestsController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
    _locationController = TextEditingController();
    _interestsController = TextEditingController();
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

  /// Avanza al siguiente paso guardando la información adicional
  void _continueToNext() {
    // These fields are optional, so no strict validation required
    // Update provider
    final registrationNotifier = ref.read(registrationDataProvider.notifier);
    registrationNotifier.update(
      (state) =>
          state
            ..phoneNumber = _phoneController.text.trim()
            ..bio = _bioController.text.trim()
            ..location = _locationController.text.trim()
            ..interests = _interestsController.text.trim(),
    );

    // Opcional: validar formato de teléfono si se proporciona
    final phoneError = RegistrationValidator.validatePhoneNumber(_phoneController.text);
    final bioError = RegistrationValidator.validateBio(_bioController.text);
    
    if (phoneError == null && bioError == null) {
      widget.onNext();
    } else {
      // Mostrar errores si los hay (opcional ya que estos campos son opcionales)
      if (_formKey.currentState != null) {
        _formKey.currentState!.validate();
      }
    }
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
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildPhoneField(),
              const SizedBox(height: 16),
              _buildBioField(),
              const SizedBox(height: 16),
              _buildLocationField(),
              const SizedBox(height: 16),
              _buildInterestsField(),
              const SizedBox(height: 32),
              _buildContinueButton(),
              _buildSkipOption(context),
            ],
          ),
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
      ],
    );
  }
  
  /// Construye el campo de teléfono
  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      decoration: const InputDecoration(
        labelText: 'Phone Number',
        hintText: 'Enter your phone number',
        prefixIcon: Icon(Icons.phone_outlined),
      ),
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      validator: (value) => RegistrationValidator.validatePhoneNumber(value),
    );
  }
  
  /// Construye el campo de biografía
  Widget _buildBioField() {
    return TextFormField(
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
      validator: (value) => RegistrationValidator.validateBio(value),
    );
  }
  
  /// Construye el campo de ubicación
  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      decoration: const InputDecoration(
        labelText: 'Location',
        hintText: 'City, Country',
        prefixIcon: Icon(Icons.location_on_outlined),
      ),
      textInputAction: TextInputAction.next,
    );
  }
  
  /// Construye el campo de intereses
  Widget _buildInterestsField() {
    return TextFormField(
      controller: _interestsController,
      decoration: const InputDecoration(
        labelText: 'Interests',
        hintText: 'What activities do you enjoy?',
        prefixIcon: Icon(Icons.interests_outlined),
      ),
      maxLength: 100,
      textInputAction: TextInputAction.done,
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
  
  /// Construye la opción para saltar este paso
  Widget _buildSkipOption(BuildContext context) {
    return Center(
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
    );
  }
}
