import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../utils/logger.dart';
import '../../../../../../ui/components/resbite_button.dart';
import '../providers/register_providers.dart';

/// Página para seleccionar la imagen de perfil durante el registro
class ProfileImagePage extends ConsumerStatefulWidget {
  /// Callback para avanzar al siguiente paso
  final VoidCallback onNext;
  
  /// Callback para regresar al paso anterior
  final VoidCallback onBack;

  const ProfileImagePage({
    required this.onNext,
    required this.onBack,
    super.key,
  });

  @override
  ConsumerState<ProfileImagePage> createState() => _ProfileImagePageState();
}

class _ProfileImagePageState extends ConsumerState<ProfileImagePage> {
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    // Get image from provider if available
    final registrationData = ref.read(registrationDataProvider);
    if (registrationData.profileImage != null) {
      _imageFile = registrationData.profileImage;
    }
  }

  /// Selecciona una imagen de perfil de la fuente especificada
  Future<void> _pickImage(BuildContext buildContext, ImageSource source) async {
    try {
      // Show loading indicator during image processing
      if (mounted) {
        final messenger = ScaffoldMessenger.of(buildContext);
        messenger.showSnackBar(
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
          _imageFile = pickedFile;
        });

        // Update provider
        final registrationNotifier = ref.read(registrationDataProvider.notifier);
        registrationNotifier.setProfileImage(_imageFile);

        // Show success message
        if (mounted) {
          final messenger = ScaffoldMessenger.of(buildContext);
          messenger.showSnackBar(
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
        final messenger = ScaffoldMessenger.of(buildContext);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Muestra el diálogo para seleccionar la fuente de la imagen
  void _showImageSourceDialog(BuildContext buildContext) {
    showDialog(
      context: buildContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    _pickImage(buildContext, ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    _pickImage(buildContext, ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Avanza al siguiente paso, guardando la imagen seleccionada
  void _continueToNext() {
    // Update provider (ensure latest state is saved)
    final registrationNotifier = ref.read(registrationDataProvider.notifier);
    registrationNotifier.setProfileImage(_imageFile);

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 40),
          _buildProfileImagePicker(context),
          const SizedBox(height: 32),
          _buildGuideText(context),
          const Spacer(),
          _buildContinueButton(),
          _buildSkipOption(context),
        ],
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
      ],
    );
  }
  
  /// Construye el selector de imagen de perfil
  Widget _buildProfileImagePicker(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => _showImageSourceDialog(context),
        child: Stack(
          children: [
            // Image container
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withAlpha((0.5 * 255).round()),
                  width: 2,
                ),
              ),
              child: _imageFile != null
                  ? CircleAvatar(
                      radius: 78,
                      backgroundImage: FileImage(File(_imageFile!.path)),
                      backgroundColor: Colors.transparent,
                    )
                  : CircleAvatar(
                      radius: 78,
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.person_outline,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
            ),
            // Edit icon
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit_outlined,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Construye el texto guía
  Widget _buildGuideText(BuildContext context) {
    return Center(
      child: Text(
        'Tap the circle to select an image from your gallery or camera.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).round()),
            ),
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
