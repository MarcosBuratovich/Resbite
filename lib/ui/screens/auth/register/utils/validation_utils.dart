import 'package:image_picker/image_picker.dart';

/// Clase de utilidad para centralizar la validación en el proceso de registro
class RegistrationValidator {
  /// Valida la fecha de nacimiento (debe tener al menos 16 años)
  static String? validateDateOfBirth(DateTime? dob) {
    if (dob == null) {
      return 'Please enter your date of birth';
    }

    // Verificar que el usuario tiene al menos 16 años
    final today = DateTime.now();
    final sixteenYearsAgo = DateTime(
      today.year - 16,
      today.month,
      today.day,
    );

    if (dob.isAfter(sixteenYearsAgo)) {
      return 'You must be at least 16 years old to use Resbite';
    }

    return null;
  }

  /// Valida el nombre
  static String? validateFirstName(String? firstName) {
    if (firstName == null || firstName.trim().isEmpty) {
      return 'Please enter your first name';
    }
    if (firstName.trim().length < 2) {
      return 'First name must be at least 2 characters long';
    }
    return null;
  }

  /// Valida el apellido
  static String? validateLastName(String? lastName) {
    if (lastName == null || lastName.trim().isEmpty) {
      return 'Please enter your last name';
    }
    if (lastName.trim().length < 2) {
      return 'Last name must be at least 2 characters long';
    }
    return null;
  }

  /// Valida el email
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Please enter your email';
    }

    final trimmed = email.trim();
    final emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegExp.hasMatch(trimmed)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  /// Valida la contraseña
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter a password';
    }
    
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }

  /// Valida la imagen de perfil
  static String? validateProfileImage(XFile? image) {
    // La imagen de perfil es opcional
    return null;
  }

  /// Valida el número de teléfono (opcional)
  static String? validatePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return null; // Es opcional
    }
    
    // Validación básica de formato
    final phoneRegExp = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegExp.hasMatch(phoneNumber.replaceAll(RegExp(r'\D'), ''))) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  /// Valida la biografía (opcional)
  static String? validateBio(String? bio) {
    if (bio == null || bio.isEmpty) {
      return null; // Es opcional
    }
    
    if (bio.length > 500) {
      return 'Bio must be less than 500 characters';
    }
    
    return null;
  }

  /// Valida el nombre para mostrar
  static String? validateDisplayName(String? displayName) {
    if (displayName == null || displayName.trim().isEmpty) {
      return 'Please enter a display name';
    }
    
    if (displayName.trim().length < 3) {
      return 'Display name must be at least 3 characters long';
    }
    
    if (displayName.trim().length > 30) {
      return 'Display name must be less than 30 characters';
    }
    
    return null;
  }
}
