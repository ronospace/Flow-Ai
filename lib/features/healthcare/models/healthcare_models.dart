
/// Healthcare provider profile and credentials
class HealthcareProvider {
  final String providerId;
  final String name;
  final String email;
  final String profession;
  final List<String> specialties;
  final String institution;
  final String licenseNumber;
  final List<String> certifications;
  final bool isVerified;
  final DateTime verificationDate;
  final String subscriptionTier; // basic, professional, premium
  final Map<String, dynamic> settings;

  const HealthcareProvider({
    required this.providerId,
    required this.name,
    required this.email,
    required this.profession,
    required this.specialties,
    required this.institution,
    required this.licenseNumber,
    required this.certifications,
    required this.isVerified,
    required this.verificationDate,
    required this.subscriptionTier,
    required this.settings,
  });

  factory HealthcareProvider.fromJson(Map<String, dynamic> json) {
    return HealthcareProvider(
      providerId: json['provider_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profession: json['profession'] as String,
      specialties: List<String>.from(json['specialties'] as List),
      institution: json['institution'] as String,
      licenseNumber: json['license_number'] as String,
      certifications: List<String>.from(json['certifications'] as List),
      isVerified: json['is_verified'] as bool,
      verificationDate: DateTime.parse(json['verification_date'] as String),
      subscriptionTier: json['subscription_tier'] as String,
      settings: Map<String, dynamic>.from(json['settings'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider_id': providerId,
      'name': name,
      'email': email,
      'profession': profession,
      'specialties': specialties,
      'institution': institution,
      'license_number': licenseNumber,
      'certifications': certifications,
      'is_verified': isVerified,
      'verification_date': verificationDate.toIso8601String(),
      'subscription_tier': subscriptionTier,
      'settings': settings,
    };
  }
}

/// Patient profile for healthcare provider access
class PatientProfile {
  final String patientId;
  final String anonymousId; // Links to user's anonymous profile
  final String? firstName; // Optional, patient can choose to share
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? email;
  final String? phone;
  final List<String> authorizedProviders;
  final Map<String, bool> dataPermissions;
  final DateTime consentDate;
  final bool isActive;

  const PatientProfile({
    required this.patientId,
    required this.anonymousId,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.email,
    this.phone,
    required this.authorizedProviders,
    required this.dataPermissions,
    required this.consentDate,
    required this.isActive,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      patientId: json['patient_id'] as String,
      anonymousId: json['anonymous_id'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth'] as String) 
          : null,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      authorizedProviders: List<String>.from(json['authorized_providers'] as List),
      dataPermissions: Map<String, bool>.from(json['data_permissions'] as Map),
      consentDate: DateTime.parse(json['consent_date'] as String),
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'anonymous_id': anonymousId,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'email': email,
      'phone': phone,
      'authorized_providers': authorizedProviders,
      'data_permissions': dataPermissions,
      'consent_date': consentDate.toIso8601String(),
      'is_active': isActive,
    };
  }

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) {
      return firstName!;
    }
    return 'Patient ${patientId.substring(0, 8)}';
  }
}

/// Medical report generated for healthcare providers
class MedicalReport {
  final String reportId;
  final String patientId;
  final String providerId;
  final String reportType; // cycle_summary, symptom_analysis, etc.
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final Map<String, dynamic> data;
  final List<String> insights;
  final List<String> recommendations;
  final ReportStatus status;

  const MedicalReport({
    required this.reportId,
    required this.patientId,
    required this.providerId,
    required this.reportType,
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.data,
    required this.insights,
    required this.recommendations,
    required this.status,
  });

  factory MedicalReport.fromJson(Map<String, dynamic> json) {
    return MedicalReport(
      reportId: json['report_id'] as String,
      patientId: json['patient_id'] as String,
      providerId: json['provider_id'] as String,
      reportType: json['report_type'] as String,
      generatedAt: DateTime.parse(json['generated_at'] as String),
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      data: Map<String, dynamic>.from(json['data'] as Map),
      insights: List<String>.from(json['insights'] as List),
      recommendations: List<String>.from(json['recommendations'] as List),
      status: ReportStatus.values[json['status'] as int],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_id': reportId,
      'patient_id': patientId,
      'provider_id': providerId,
      'report_type': reportType,
      'generated_at': generatedAt.toIso8601String(),
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'data': data,
      'insights': insights,
      'recommendations': recommendations,
      'status': status.index,
    };
  }
}

/// Healthcare appointment integration
class Appointment {
  final String appointmentId;
  final String patientId;
  final String providerId;
  final String title;
  final String? description;
  final DateTime scheduledAt;
  final Duration duration;
  final AppointmentType type;
  final AppointmentStatus status;
  final String? notes;
  final List<String> attachedReports;

  const Appointment({
    required this.appointmentId,
    required this.patientId,
    required this.providerId,
    required this.title,
    this.description,
    required this.scheduledAt,
    required this.duration,
    required this.type,
    required this.status,
    this.notes,
    required this.attachedReports,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointment_id'] as String,
      patientId: json['patient_id'] as String,
      providerId: json['provider_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      duration: Duration(minutes: json['duration_minutes'] as int),
      type: AppointmentType.values[json['type'] as int],
      status: AppointmentStatus.values[json['status'] as int],
      notes: json['notes'] as String?,
      attachedReports: List<String>.from(json['attached_reports'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointment_id': appointmentId,
      'patient_id': patientId,
      'provider_id': providerId,
      'title': title,
      'description': description,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': duration.inMinutes,
      'type': type.index,
      'status': status.index,
      'notes': notes,
      'attached_reports': attachedReports,
    };
  }
}

/// Clinical note from healthcare provider
class ClinicalNote {
  final String noteId;
  final String patientId;
  final String providerId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final NoteType type;
  final List<String> tags;
  final bool isPrivate;

  const ClinicalNote({
    required this.noteId,
    required this.patientId,
    required this.providerId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    required this.type,
    required this.tags,
    required this.isPrivate,
  });

  factory ClinicalNote.fromJson(Map<String, dynamic> json) {
    return ClinicalNote(
      noteId: json['note_id'] as String,
      patientId: json['patient_id'] as String,
      providerId: json['provider_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      type: NoteType.values[json['type'] as int],
      tags: List<String>.from(json['tags'] as List),
      isPrivate: json['is_private'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'note_id': noteId,
      'patient_id': patientId,
      'provider_id': providerId,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'type': type.index,
      'tags': tags,
      'is_private': isPrivate,
    };
  }
}

/// EHR integration data
class EHRIntegration {
  final String integrationId;
  final String providerId;
  final String ehrSystem; // epic, cerner, allscripts, etc.
  final String ehrVersion;
  final Map<String, String> credentials;
  final bool isActive;
  final DateTime lastSyncAt;
  final List<String> supportedDataTypes;
  final Map<String, dynamic> syncSettings;

  const EHRIntegration({
    required this.integrationId,
    required this.providerId,
    required this.ehrSystem,
    required this.ehrVersion,
    required this.credentials,
    required this.isActive,
    required this.lastSyncAt,
    required this.supportedDataTypes,
    required this.syncSettings,
  });

  factory EHRIntegration.fromJson(Map<String, dynamic> json) {
    return EHRIntegration(
      integrationId: json['integration_id'] as String,
      providerId: json['provider_id'] as String,
      ehrSystem: json['ehr_system'] as String,
      ehrVersion: json['ehr_version'] as String,
      credentials: Map<String, String>.from(json['credentials'] as Map),
      isActive: json['is_active'] as bool,
      lastSyncAt: DateTime.parse(json['last_sync_at'] as String),
      supportedDataTypes: List<String>.from(json['supported_data_types'] as List),
      syncSettings: Map<String, dynamic>.from(json['sync_settings'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'integration_id': integrationId,
      'provider_id': providerId,
      'ehr_system': ehrSystem,
      'ehr_version': ehrVersion,
      'credentials': credentials,
      'is_active': isActive,
      'last_sync_at': lastSyncAt.toIso8601String(),
      'supported_data_types': supportedDataTypes,
      'sync_settings': syncSettings,
    };
  }
}

/// Prescription tracking
class Prescription {
  final String prescriptionId;
  final String patientId;
  final String providerId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final DateTime prescribedAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final String purpose; // pms_relief, contraception, etc.
  final List<String> sideEffects;
  final String status;
  final String? notes;

  const Prescription({
    required this.prescriptionId,
    required this.patientId,
    required this.providerId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.prescribedAt,
    this.startDate,
    this.endDate,
    required this.purpose,
    required this.sideEffects,
    required this.status,
    this.notes,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      prescriptionId: json['prescription_id'] as String,
      patientId: json['patient_id'] as String,
      providerId: json['provider_id'] as String,
      medicationName: json['medication_name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      prescribedAt: DateTime.parse(json['prescribed_at'] as String),
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date'] as String) 
          : null,
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date'] as String) 
          : null,
      purpose: json['purpose'] as String,
      sideEffects: List<String>.from(json['side_effects'] as List),
      status: json['status'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prescription_id': prescriptionId,
      'patient_id': patientId,
      'provider_id': providerId,
      'medication_name': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'prescribed_at': prescribedAt.toIso8601String(),
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'purpose': purpose,
      'side_effects': sideEffects,
      'status': status,
      'notes': notes,
    };
  }
}

/// Lab result integration
class LabResult {
  final String resultId;
  final String patientId;
  final String providerId;
  final String testName;
  final String testType;
  final DateTime collectedAt;
  final DateTime? resultedAt;
  final Map<String, dynamic> values;
  final Map<String, String> referenceRanges;
  final String status;
  final String? interpretation;

  const LabResult({
    required this.resultId,
    required this.patientId,
    required this.providerId,
    required this.testName,
    required this.testType,
    required this.collectedAt,
    this.resultedAt,
    required this.values,
    required this.referenceRanges,
    required this.status,
    this.interpretation,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) {
    return LabResult(
      resultId: json['result_id'] as String,
      patientId: json['patient_id'] as String,
      providerId: json['provider_id'] as String,
      testName: json['test_name'] as String,
      testType: json['test_type'] as String,
      collectedAt: DateTime.parse(json['collected_at'] as String),
      resultedAt: json['resulted_at'] != null 
          ? DateTime.parse(json['resulted_at'] as String) 
          : null,
      values: Map<String, dynamic>.from(json['values'] as Map),
      referenceRanges: Map<String, String>.from(json['reference_ranges'] as Map),
      status: json['status'] as String,
      interpretation: json['interpretation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result_id': resultId,
      'patient_id': patientId,
      'provider_id': providerId,
      'test_name': testName,
      'test_type': testType,
      'collected_at': collectedAt.toIso8601String(),
      'resulted_at': resultedAt?.toIso8601String(),
      'values': values,
      'reference_ranges': referenceRanges,
      'status': status,
      'interpretation': interpretation,
    };
  }
}

/// Billing and insurance integration
class BillingInfo {
  final String billingId;
  final String patientId;
  final String providerId;
  final String serviceCode;
  final String serviceDescription;
  final DateTime serviceDate;
  final double amount;
  final String currency;
  final String? insuranceProvider;
  final String? insurancePolicyNumber;
  final double? copay;
  final String status;

  const BillingInfo({
    required this.billingId,
    required this.patientId,
    required this.providerId,
    required this.serviceCode,
    required this.serviceDescription,
    required this.serviceDate,
    required this.amount,
    required this.currency,
    this.insuranceProvider,
    this.insurancePolicyNumber,
    this.copay,
    required this.status,
  });

  factory BillingInfo.fromJson(Map<String, dynamic> json) {
    return BillingInfo(
      billingId: json['billing_id'] as String,
      patientId: json['patient_id'] as String,
      providerId: json['provider_id'] as String,
      serviceCode: json['service_code'] as String,
      serviceDescription: json['service_description'] as String,
      serviceDate: DateTime.parse(json['service_date'] as String),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      insuranceProvider: json['insurance_provider'] as String?,
      insurancePolicyNumber: json['insurance_policy_number'] as String?,
      copay: (json['copay'] as num?)?.toDouble(),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billing_id': billingId,
      'patient_id': patientId,
      'provider_id': providerId,
      'service_code': serviceCode,
      'service_description': serviceDescription,
      'service_date': serviceDate.toIso8601String(),
      'amount': amount,
      'currency': currency,
      'insurance_provider': insuranceProvider,
      'insurance_policy_number': insurancePolicyNumber,
      'copay': copay,
      'status': status,
    };
  }
}

/// Healthcare analytics for providers
class ProviderAnalytics {
  final String providerId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalPatients;
  final int activePatients;
  final int newPatients;
  final int totalAppointments;
  final int totalReports;
  final Map<String, int> conditionDistribution;
  final Map<String, double> outcomeMetrics;
  final double patientSatisfaction;
  final Map<String, int> prescriptionStats;

  const ProviderAnalytics({
    required this.providerId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalPatients,
    required this.activePatients,
    required this.newPatients,
    required this.totalAppointments,
    required this.totalReports,
    required this.conditionDistribution,
    required this.outcomeMetrics,
    required this.patientSatisfaction,
    required this.prescriptionStats,
  });

  factory ProviderAnalytics.fromJson(Map<String, dynamic> json) {
    return ProviderAnalytics(
      providerId: json['provider_id'] as String,
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      totalPatients: json['total_patients'] as int,
      activePatients: json['active_patients'] as int,
      newPatients: json['new_patients'] as int,
      totalAppointments: json['total_appointments'] as int,
      totalReports: json['total_reports'] as int,
      conditionDistribution: Map<String, int>.from(json['condition_distribution'] as Map),
      outcomeMetrics: Map<String, double>.from(json['outcome_metrics'] as Map),
      patientSatisfaction: (json['patient_satisfaction'] as num).toDouble(),
      prescriptionStats: Map<String, int>.from(json['prescription_stats'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider_id': providerId,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'total_patients': totalPatients,
      'active_patients': activePatients,
      'new_patients': newPatients,
      'total_appointments': totalAppointments,
      'total_reports': totalReports,
      'condition_distribution': conditionDistribution,
      'outcome_metrics': outcomeMetrics,
      'patient_satisfaction': patientSatisfaction,
      'prescription_stats': prescriptionStats,
    };
  }
}

/// Enums for healthcare system
enum ReportStatus {
  pending,
  generated,
  reviewed,
  shared,
  archived,
}

enum AppointmentType {
  consultation,
  followUp,
  emergency,
  telemedicine,
  groupSession,
}

enum AppointmentStatus {
  scheduled,
  confirmed,
  inProgress,
  completed,
  cancelled,
  noShow,
}

enum NoteType {
  assessment,
  treatment,
  followUp,
  observation,
  education,
}

/// Data consent and permissions
class DataConsent {
  final String consentId;
  final String patientId;
  final String providerId;
  final Map<String, bool> permissions;
  final DateTime grantedAt;
  final DateTime? revokedAt;
  final String consentVersion;
  final bool isActive;

  const DataConsent({
    required this.consentId,
    required this.patientId,
    required this.providerId,
    required this.permissions,
    required this.grantedAt,
    this.revokedAt,
    required this.consentVersion,
    required this.isActive,
  });

  factory DataConsent.fromJson(Map<String, dynamic> json) {
    return DataConsent(
      consentId: json['consent_id'] as String,
      patientId: json['patient_id'] as String,
      providerId: json['provider_id'] as String,
      permissions: Map<String, bool>.from(json['permissions'] as Map),
      grantedAt: DateTime.parse(json['granted_at'] as String),
      revokedAt: json['revoked_at'] != null 
          ? DateTime.parse(json['revoked_at'] as String) 
          : null,
      consentVersion: json['consent_version'] as String,
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'consent_id': consentId,
      'patient_id': patientId,
      'provider_id': providerId,
      'permissions': permissions,
      'granted_at': grantedAt.toIso8601String(),
      'revoked_at': revokedAt?.toIso8601String(),
      'consent_version': consentVersion,
      'is_active': isActive,
    };
  }
}
