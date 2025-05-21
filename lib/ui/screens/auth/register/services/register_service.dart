import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../services/auth_service.dart';
import '../../../../../services/user_db_service.dart';
import '../../../../../utils/logger.dart';
import '../../../../../services/providers.dart';
import '../providers/register_providers.dart';

/// Servicio para manejar el proceso de registro de usuarios
class RegisterService {
  final AuthService _authService;
  final UserDBService _userDBService;
  final Ref _ref;

  /// Constructor que recibe las dependencias necesarias
  RegisterService(this._authService, this._userDBService, this._ref);

  /// Registra un nuevo usuario con los datos proporcionados
  Future<bool> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String displayName,
    required DateTime dateOfBirth,
    String? phoneNumber,
    String? bio,
    String? location,
    String? interests,
    XFile? profileImage,
  }) async {
    try {
      // Indicar que estamos procesando
      _ref.read(isSubmittingProvider.notifier).state = true;
      _ref.read(registrationErrorProvider.notifier).state = null;

      // Registrar usuario con Firebase Auth
      final registeredAppUser = await _authService.registerWithEmailAndPassword(
        email,
        password,
      );

      if (registeredAppUser == null) {
        throw Exception('Failed to create user account');
      }

      // Crear perfil de usuario en la base de datos
      await _userDBService.createUserProfile(
        uid: registeredAppUser.id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        displayName: displayName,
        dateOfBirth: dateOfBirth,
        phoneNumber: phoneNumber,
        bio: bio,
        location: location,
        interests: interests?.split(','),
      );

      // Subir imagen de perfil si existe
      if (profileImage != null) {
        // Use UserProfileService for uploading image
        final profileUrl = await _ref.read(userProfileServiceProvider).uploadProfileImage(
          userId: registeredAppUser.id, 
          imageFile: profileImage,
        );

        if (profileUrl != null) {
          // Use UserProfileService for updating profile
          await _ref.read(userProfileServiceProvider).updateUserProfile(
            userId: registeredAppUser.id, 
            data: {'profile_image_url': profileUrl},
          );
        }
      }

      // Limpiar estado
      _ref.read(registrationDataProvider.notifier).reset();
      _ref.read(isSubmittingProvider.notifier).state = false;

      return true;
    } catch (e) {
      AppLogger.error('Registration error', e);
      
      // Actualizar estado de error
      _ref.read(isSubmittingProvider.notifier).state = false;
      _ref.read(registrationErrorProvider.notifier).state = e.toString();
      
      return false;
    }
  }

  /// Registra un nuevo usuario usando los datos almacenados en el provider
  Future<bool> registerWithStoredData() async {
    try {
      final registrationData = _ref.read(registrationDataProvider);
      
      // Verificar datos requeridos
      if (registrationData.email == null || 
          registrationData.password == null ||
          registrationData.firstName == null || 
          registrationData.lastName == null ||
          registrationData.dateOfBirth == null) {
        throw Exception('Missing required registration data');
      }
      
      return await registerUser(
        email: registrationData.email!,
        password: registrationData.password!,
        firstName: registrationData.firstName!,
        lastName: registrationData.lastName!,
        displayName: registrationData.displayName ?? registrationData.firstName!,
        dateOfBirth: registrationData.dateOfBirth!,
        phoneNumber: registrationData.phoneNumber,
        bio: registrationData.bio,
        location: registrationData.location,
        interests: registrationData.interests,
        profileImage: registrationData.profileImage,
      );
    } catch (e) {
      AppLogger.error('Registration with stored data error', e);
      _ref.read(registrationErrorProvider.notifier).state = e.toString();
      return false;
    }
  }
}

/// Provider para el servicio de registro
final registerServiceProvider = Provider<RegisterService>((ref) {
  final authService = ref.watch(authServiceProvider);
  final userDBService = ref.watch(userDbServiceProvider);
  
  return RegisterService(authService, userDBService, ref);
});
