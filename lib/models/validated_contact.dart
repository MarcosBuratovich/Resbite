class ValidatedContact {
  final String id;
  final String name;
  final ContactInfo contactInfo;

  ValidatedContact({
    required this.id,
    required this.name,
    required this.contactInfo,
  });
}

class ContactInfo {
  final String? email;
  final String? phone;
  final String? displayName;

  /// Get name if available, otherwise use email or phone as fallback
  String get name => displayName ?? email ?? phone ?? 'Unknown';
  
  /// Alias for phone to maintain API compatibility
  String? get phoneNumber => phone;

  ContactInfo({this.email, this.phone, this.displayName});

  Map<String, dynamic> toJson() => {
    'email': email,
    'phone': phone,
    'displayName': displayName,
  };
}
