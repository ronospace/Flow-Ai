/// Healthcare Provider Model
class HealthcareProvider {
  final String id;
  final String name;
  final ProviderType type;
  final String licenseNumber;
  final String organization;
  final String email;
  final String? phone;
  final Address address;
  final List<String> specialties;
  final bool isVerified;
  final bool supportsDataSharing;
  final String apiEndpoint;
  final Map<String, dynamic> credentials;
  final DateTime connectedAt;
  final DateTime? lastSyncAt;

  const HealthcareProvider({
    required this.id,
    required this.name,
    required this.type,
    required this.licenseNumber,
    required this.organization,
    required this.email,
    this.phone,
    required this.address,
    required this.specialties,
    this.isVerified = false,
    this.supportsDataSharing = true,
    required this.apiEndpoint,
    required this.credentials,
    required this.connectedAt,
    this.lastSyncAt,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'licenseNumber': licenseNumber,
      'organization': organization,
      'email': email,
      'phone': phone,
      'address': address.toJson(),
      'specialties': specialties,
      'isVerified': isVerified,
      'supportsDataSharing': supportsDataSharing,
      'apiEndpoint': apiEndpoint,
      'credentials': credentials,
      'connectedAt': connectedAt.toIso8601String(),
      'lastSyncAt': lastSyncAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory HealthcareProvider.fromJson(Map<String, dynamic> json) {
    return HealthcareProvider(
      id: json['id'],
      name: json['name'],
      type: ProviderType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ProviderType.generalPractitioner,
      ),
      licenseNumber: json['licenseNumber'],
      organization: json['organization'],
      email: json['email'],
      phone: json['phone'],
      address: Address.fromJson(json['address']),
      specialties: List<String>.from(json['specialties'] ?? []),
      isVerified: json['isVerified'] ?? false,
      supportsDataSharing: json['supportsDataSharing'] ?? true,
      apiEndpoint: json['apiEndpoint'],
      credentials: Map<String, dynamic>.from(json['credentials'] ?? {}),
      connectedAt: DateTime.parse(json['connectedAt']),
      lastSyncAt: json['lastSyncAt'] != null 
          ? DateTime.parse(json['lastSyncAt'])
          : null,
    );
  }

  /// Copy with new values
  HealthcareProvider copyWith({
    String? id,
    String? name,
    ProviderType? type,
    String? licenseNumber,
    String? organization,
    String? email,
    String? phone,
    Address? address,
    List<String>? specialties,
    bool? isVerified,
    bool? supportsDataSharing,
    String? apiEndpoint,
    Map<String, dynamic>? credentials,
    DateTime? connectedAt,
    DateTime? lastSyncAt,
  }) {
    return HealthcareProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      organization: organization ?? this.organization,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      specialties: specialties ?? this.specialties,
      isVerified: isVerified ?? this.isVerified,
      supportsDataSharing: supportsDataSharing ?? this.supportsDataSharing,
      apiEndpoint: apiEndpoint ?? this.apiEndpoint,
      credentials: credentials ?? this.credentials,
      connectedAt: connectedAt ?? this.connectedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  @override
  String toString() {
    return 'HealthcareProvider(id: $id, name: $name, type: ${type.displayName}, organization: $organization)';
  }
}

/// Healthcare Provider Types
enum ProviderType {
  gynecologist,
  generalPractitioner,
  endocrinologist,
  mentalHealthProvider,
  nutritionist,
  fertilityClinician,
  obstetrician,
  naturopathicDoctor,
  other,
}

/// Extension for Provider Type
extension ProviderTypeExtension on ProviderType {
  String get displayName {
    switch (this) {
      case ProviderType.gynecologist:
        return 'Gynecologist';
      case ProviderType.generalPractitioner:
        return 'General Practitioner';
      case ProviderType.endocrinologist:
        return 'Endocrinologist';
      case ProviderType.mentalHealthProvider:
        return 'Mental Health Provider';
      case ProviderType.nutritionist:
        return 'Nutritionist';
      case ProviderType.fertilityClinician:
        return 'Fertility Clinician';
      case ProviderType.obstetrician:
        return 'Obstetrician';
      case ProviderType.naturopathicDoctor:
        return 'Naturopathic Doctor';
      case ProviderType.other:
        return 'Other';
    }
  }

  String get description {
    switch (this) {
      case ProviderType.gynecologist:
        return 'Specializes in female reproductive health';
      case ProviderType.generalPractitioner:
        return 'Primary care physician';
      case ProviderType.endocrinologist:
        return 'Specializes in hormones and endocrine system';
      case ProviderType.mentalHealthProvider:
        return 'Mental health and wellness support';
      case ProviderType.nutritionist:
        return 'Diet and nutrition guidance';
      case ProviderType.fertilityClinician:
        return 'Fertility and reproductive assistance';
      case ProviderType.obstetrician:
        return 'Pregnancy and childbirth care';
      case ProviderType.naturopathicDoctor:
        return 'Natural and holistic healthcare';
      case ProviderType.other:
        return 'Other healthcare provider';
    }
  }

  String get emoji {
    switch (this) {
      case ProviderType.gynecologist:
        return '👩‍⚕️';
      case ProviderType.generalPractitioner:
        return '🩺';
      case ProviderType.endocrinologist:
        return '🧬';
      case ProviderType.mentalHealthProvider:
        return '🧠';
      case ProviderType.nutritionist:
        return '🥗';
      case ProviderType.fertilityClinician:
        return '🤱';
      case ProviderType.obstetrician:
        return '👶';
      case ProviderType.naturopathicDoctor:
        return '🌿';
      case ProviderType.other:
        return '🏥';
    }
  }
}

/// Address Model
class Address {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  const Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    this.country = 'United States',
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
    };
  }

  /// Create from JSON
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      country: json['country'] ?? 'United States',
    );
  }

  /// Get formatted address string
  String get formatted {
    return '$street, $city, $state $zipCode, $country';
  }

  @override
  String toString() => formatted;
}
