import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// Data model for registration
class RegistrationData {
  DateTime? dateOfBirth;
  String? firstName;
  String? lastName;
  String? displayName;
  String? email;
  String? password;
  XFile? profileImage;
  String? phoneNumber;
  String? bio;
  String? location;
  String? interests;

  RegistrationData({
    this.dateOfBirth,
    this.firstName,
    this.lastName,
    this.displayName,
    this.email,
    this.password,
    this.profileImage,
    this.phoneNumber,
    this.bio,
    this.location,
    this.interests,
  });

  RegistrationData copyWith({
    DateTime? dateOfBirth,
    String? firstName,
    String? lastName,
    String? displayName,
    String? email,
    String? password,
    XFile? profileImage,
    String? phoneNumber,
    String? bio,
    String? location,
    String? interests,
  }) {
    return RegistrationData(
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      password: password ?? this.password,
      profileImage: profileImage ?? this.profileImage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      interests: interests ?? this.interests,
    );
  }

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
  bool isStep2Valid() =>
      firstName != null &&
      firstName!.isNotEmpty &&
      lastName != null &&
      lastName!.isNotEmpty &&
      displayName != null &&
      displayName!.isNotEmpty;
  bool isStep3Valid() =>
      email != null &&
      email!.isNotEmpty &&
      password != null &&
      password!.length >= 6; // Temporarily hardcoded min password length
  bool isStep5Valid() => true; // Optional fields

  // Full name
  String get fullName => '$firstName $lastName';
}

// State Notifier for RegistrationData
class RegistrationDataNotifier extends StateNotifier<RegistrationData> {
  RegistrationDataNotifier() : super(RegistrationData());

  // Generic update method
  void update(RegistrationData Function(RegistrationData current) updater) {
    state = updater(state);
  }

  void updateData(RegistrationData data) {
    state = data;
  }

  void setDateOfBirth(DateTime? dob) {
    state = state.copyWith(dateOfBirth: dob);
  }

  void setName(String? firstName, String? lastName) {
    state = state.copyWith(firstName: firstName, lastName: lastName);
  }

  void setCredentials(String? email, String? password) {
    state = state.copyWith(email: email, password: password);
  }

  void setProfileImage(XFile? image) {
    state = state.copyWith(profileImage: image);
  }

  void setAdditionalInfo(String? bio, String? displayName) {
    state = state.copyWith(bio: bio, displayName: displayName);
  }

  void reset() {
    state = RegistrationData();
  }
}

// Provider for RegistrationDataNotifier
final registrationDataProvider =
    StateNotifierProvider<RegistrationDataNotifier, RegistrationData>(
  (ref) => RegistrationDataNotifier(),
);
