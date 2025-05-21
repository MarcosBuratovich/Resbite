import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:resbite_app/ui/components/resbite_button.dart';

import '../providers/register_providers.dart';

/// Página final para revisar y confirmar la información del registro
class ReviewPage extends ConsumerWidget {
  /// Callback para enviar el formulario de registro
  final void Function(BuildContext) onSubmit;
  
  /// Callback para regresar al paso anterior
  final VoidCallback onBack;

  const ReviewPage({
    required this.onSubmit,
    required this.onBack,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrationData = ref.watch(registrationDataProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildProfileImageSection(context, registrationData),
            _buildInfoSection(
              context,
              title: 'Personal Information',
              items: [
                {'label': 'Name', 'value': '${registrationData.firstName} ${registrationData.lastName}'},
                {
                  'label': 'Display Name',
                  'value': registrationData.displayName ?? '',
                },
                {
                  'label': 'Date of Birth',
                  'value': registrationData.dateOfBirth != null 
                      ? DateFormat('MM/dd/yyyy').format(registrationData.dateOfBirth!)
                      : '',
                },
                {'label': 'Email', 'value': registrationData.email ?? ''},
                if (registrationData.phoneNumber != null &&
                    registrationData.phoneNumber!.isNotEmpty)
                  {'label': 'Phone', 'value': registrationData.phoneNumber!},
              ],
            ),
            _buildAdditionalInfoSection(context, registrationData),
            const SizedBox(height: 32),
            _buildTermsAndConditions(context),
            const SizedBox(height: 32),
            _buildCreateAccountButton(context, ref),
            _buildEditInformationButton(context),
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
      ],
    );
  }
  
  /// Construye la sección de imagen de perfil
  Widget _buildProfileImageSection(BuildContext context, RegistrationData registrationData) {
    return Center(
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
                    color: Theme.of(context).colorScheme.primary.withAlpha((0.2 * 255).round()),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
                image: DecorationImage(
                  image: FileImage(File(registrationData.profileImage!.path)),
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
                color: Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).round()),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).round()),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary.withAlpha((0.5 * 255).round()),
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
                color: Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Construye la sección de información adicional si está disponible
  Widget _buildAdditionalInfoSection(BuildContext context, RegistrationData registrationData) {
    if ((registrationData.bio != null && registrationData.bio!.isNotEmpty) ||
        (registrationData.location != null && registrationData.location!.isNotEmpty) ||
        (registrationData.interests != null && registrationData.interests!.isNotEmpty)) {
      return _buildInfoSection(
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
      );
    }
    return const SizedBox.shrink();
  }
  
  /// Construye la sección de términos y condiciones
  Widget _buildTermsAndConditions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha((0.05 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withAlpha((0.2 * 255).round()),
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
    );
  }
  
  /// Construye el botón para crear la cuenta
  Widget _buildCreateAccountButton(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, _) {
        final isLoading = ref.watch(isSubmittingProvider);
        return ResbiteButton(
          text: isLoading ? 'Creating Account...' : 'Create Account',
          icon: isLoading ? Icons.hourglass_top : Icons.check_circle,
          type: ResbiteBtnType.gradient,
          size: ResbiteBtnSize.large,
          fullWidth: true,
          onPressed: isLoading ? null : () => onSubmit(context),
        );
      },
    );
  }
  
  /// Construye el botón para editar la información
  Widget _buildEditInformationButton(BuildContext context) {
    return Center(
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
    );
  }

  /// Construye una sección de información
  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required List<Map<String, String>> items,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
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
          ...items.map(
            (item) => _buildInfoItem(context, item['label']!, item['value']!),
          ),
        ],
      ),
    );
  }

  /// Construye un elemento de información
  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment:
            value.length > 30
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
        children: [
          // Label
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).round()),
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
