import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/healthcare_models.dart';
import '../../../core/models/cycle_data.dart';

/// Healthcare service managing provider integration and patient data sharing
class HealthcareService {
  static final HealthcareService _instance = HealthcareService._internal();
  factory HealthcareService() => _instance;
  HealthcareService._internal();

  static HealthcareService get instance => _instance;

  // Service state
  bool _isInitialized = false;
  HealthcareProvider? _currentProvider;
  final List<PatientProfile> _patients = [];
  final List<MedicalReport> _reports = [];
  final List<Appointment> _appointments = [];
  final List<ClinicalNote> _notes = [];
  final List<Prescription> _prescriptions = [];
  final List<LabResult> _labResults = [];
  final List<DataConsent> _consents = [];

  // Stream controllers for real-time updates
  final StreamController<List<PatientProfile>> _patientsController = 
      StreamController<List<PatientProfile>>.broadcast();
  final StreamController<List<MedicalReport>> _reportsController = 
      StreamController<List<MedicalReport>>.broadcast();
  final StreamController<List<Appointment>> _appointmentsController = 
      StreamController<List<Appointment>>.broadcast();
  final StreamController<ProviderAnalytics> _analyticsController = 
      StreamController<ProviderAnalytics>.broadcast();

  // Getters for streams
  Stream<List<PatientProfile>> get patientsStream => _patientsController.stream;
  Stream<List<MedicalReport>> get reportsStream => _reportsController.stream;
  Stream<List<Appointment>> get appointmentsStream => _appointmentsController.stream;
  Stream<ProviderAnalytics> get analyticsStream => _analyticsController.stream;

  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('🏥 Initializing Healthcare Service...');
    
    await _loadSampleProviders();
    await _loadSamplePatients();
    await _generateSampleData();
    
    _isInitialized = true;
    debugPrint('✅ Healthcare Service initialized');
  }

  /// Register a new healthcare provider
  Future<HealthcareProvider> registerProvider({
    required String name,
    required String email,
    required String profession,
    required List<String> specialties,
    required String institution,
    required String licenseNumber,
    required List<String> certifications,
    String subscriptionTier = 'basic',
  }) async {
    final providerId = _generateProviderId();
    
    final provider = HealthcareProvider(
      providerId: providerId,
      name: name,
      email: email,
      profession: profession,
      specialties: specialties,
      institution: institution,
      licenseNumber: licenseNumber,
      certifications: certifications,
      isVerified: false, // Requires manual verification
      verificationDate: DateTime.now(),
      subscriptionTier: subscriptionTier,
      settings: {
        'notifications_enabled': true,
        'auto_report_generation': false,
        'patient_data_retention_days': 2555, // 7 years
        'ehr_integration_enabled': false,
      },
    );

    debugPrint('🏥 Registered healthcare provider: $name');
    return provider;
  }

  /// Login healthcare provider
  Future<HealthcareProvider?> loginProvider({
    required String email,
    required String password,
  }) async {
    // In production, this would validate credentials
    final provider = HealthcareProvider(
      providerId: 'provider_demo',
      name: 'Dr. Sarah Johnson',
      email: email,
      profession: 'Gynecologist',
      specialties: ['Reproductive Health', 'Menstrual Disorders', 'PCOS'],
      institution: 'Women\'s Health Center',
      licenseNumber: 'MD-12345',
      certifications: ['MD', 'Board Certified Gynecology', 'ACOG Member'],
      isVerified: true,
      verificationDate: DateTime.now().subtract(const Duration(days: 30)),
      subscriptionTier: 'premium',
      settings: {
        'notifications_enabled': true,
        'auto_report_generation': true,
        'patient_data_retention_days': 2555,
        'ehr_integration_enabled': true,
      },
    );

    _currentProvider = provider;
    debugPrint('👩‍⚕️ Provider logged in: ${provider.name}');
    return provider;
  }

  /// Get provider dashboard analytics
  ProviderAnalytics getProviderAnalytics() {
    if (_currentProvider == null) {
      throw Exception('Provider must be logged in');
    }

    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final now = DateTime.now();

    final analytics = ProviderAnalytics(
      providerId: _currentProvider!.providerId,
      periodStart: thirtyDaysAgo,
      periodEnd: now,
      totalPatients: _patients.length,
      activePatients: _patients.where((p) => p.isActive).length,
      newPatients: 8, // In last 30 days
      totalAppointments: _appointments.length,
      totalReports: _reports.length,
      conditionDistribution: {
        'Irregular Cycles': 35,
        'PMS/PMDD': 25,
        'Heavy Menstrual Bleeding': 20,
        'PCOS': 15,
        'Endometriosis': 5,
      },
      outcomeMetrics: {
        'symptom_improvement': 0.78,
        'cycle_regularity': 0.82,
        'patient_satisfaction': 0.91,
        'treatment_adherence': 0.85,
      },
      patientSatisfaction: 4.6,
      prescriptionStats: {
        'Birth Control': 45,
        'Pain Management': 32,
        'Hormone Therapy': 18,
        'Supplements': 25,
      },
    );

    _analyticsController.add(analytics);
    return analytics;
  }

  /// Get provider's patients
  List<PatientProfile> getProviderPatients() {
    if (_currentProvider == null) return [];
    
    return _patients.where((patient) => 
      patient.authorizedProviders.contains(_currentProvider!.providerId)
    ).toList();
  }

  /// Generate medical report for patient
  Future<MedicalReport> generatePatientReport({
    required String patientId,
    required String reportType,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    if (_currentProvider == null) {
      throw Exception('Provider must be logged in');
    }

    // In production, this would fetch actual patient data
    final reportData = await _generateReportData(patientId, reportType, periodStart, periodEnd);
    
    final reportId = _generateReportId();
    final report = MedicalReport(
      reportId: reportId,
      patientId: patientId,
      providerId: _currentProvider!.providerId,
      reportType: reportType,
      generatedAt: DateTime.now(),
      periodStart: periodStart,
      periodEnd: periodEnd,
      data: reportData,
      insights: _generateInsights(reportData),
      recommendations: _generateRecommendations(reportData),
      status: ReportStatus.generated,
    );

    _reports.add(report);
    _reportsController.add(List.unmodifiable(_reports));
    
    debugPrint('📊 Generated $reportType report for patient: $patientId');
    return report;
  }

  /// Schedule appointment with patient
  Future<Appointment> scheduleAppointment({
    required String patientId,
    required String title,
    String? description,
    required DateTime scheduledAt,
    required Duration duration,
    required AppointmentType type,
  }) async {
    if (_currentProvider == null) {
      throw Exception('Provider must be logged in');
    }

    final appointmentId = _generateAppointmentId();
    final appointment = Appointment(
      appointmentId: appointmentId,
      patientId: patientId,
      providerId: _currentProvider!.providerId,
      title: title,
      description: description,
      scheduledAt: scheduledAt,
      duration: duration,
      type: type,
      status: AppointmentStatus.scheduled,
      attachedReports: [],
    );

    _appointments.add(appointment);
    _appointmentsController.add(List.unmodifiable(_appointments));
    
    debugPrint('📅 Scheduled appointment: $title');
    return appointment;
  }

  /// Add clinical note for patient
  Future<ClinicalNote> addClinicalNote({
    required String patientId,
    required String title,
    required String content,
    required NoteType type,
    List<String> tags = const [],
    bool isPrivate = false,
  }) async {
    if (_currentProvider == null) {
      throw Exception('Provider must be logged in');
    }

    final noteId = _generateNoteId();
    final note = ClinicalNote(
      noteId: noteId,
      patientId: patientId,
      providerId: _currentProvider!.providerId,
      title: title,
      content: content,
      createdAt: DateTime.now(),
      type: type,
      tags: tags,
      isPrivate: isPrivate,
    );

    _notes.add(note);
    
    debugPrint('📝 Added clinical note: $title');
    return note;
  }

  /// Prescribe medication for patient
  Future<Prescription> prescribeMedication({
    required String patientId,
    required String medicationName,
    required String dosage,
    required String frequency,
    required String purpose,
    DateTime? startDate,
    DateTime? endDate,
    List<String> sideEffects = const [],
    String? notes,
  }) async {
    if (_currentProvider == null) {
      throw Exception('Provider must be logged in');
    }

    final prescriptionId = _generatePrescriptionId();
    final prescription = Prescription(
      prescriptionId: prescriptionId,
      patientId: patientId,
      providerId: _currentProvider!.providerId,
      medicationName: medicationName,
      dosage: dosage,
      frequency: frequency,
      prescribedAt: DateTime.now(),
      startDate: startDate,
      endDate: endDate,
      purpose: purpose,
      sideEffects: sideEffects,
      status: 'active',
      notes: notes,
    );

    _prescriptions.add(prescription);
    
    debugPrint('💊 Prescribed $medicationName for patient: $patientId');
    return prescription;
  }

  /// Get patient's cycle data for analysis
  Future<List<CycleData>> getPatientCycleData(String patientId) async {
    // In production, this would fetch actual cycle data with patient consent
    return _generateSampleCycleData();
  }

  /// Get patient's biometric data
  Future<Map<String, dynamic>> getPatientBiometricData(String patientId) async {
    // In production, this would fetch actual biometric data with patient consent
    return _generateSampleBiometricData();
  }

  /// Request patient data consent
  Future<DataConsent> requestPatientConsent({
    required String patientId,
    required Map<String, bool> permissions,
  }) async {
    if (_currentProvider == null) {
      throw Exception('Provider must be logged in');
    }

    final consentId = _generateConsentId();
    final consent = DataConsent(
      consentId: consentId,
      patientId: patientId,
      providerId: _currentProvider!.providerId,
      permissions: permissions,
      grantedAt: DateTime.now(),
      consentVersion: '1.0',
      isActive: true,
    );

    _consents.add(consent);
    
    debugPrint('📋 Requested consent from patient: $patientId');
    return consent;
  }

  /// Export patient data to EHR system
  Future<bool> exportToEHR({
    required String patientId,
    required String ehrSystem,
    required List<String> dataTypes,
  }) async {
    if (_currentProvider == null) {
      throw Exception('Provider must be logged in');
    }

    // In production, this would integrate with actual EHR systems
    debugPrint('📤 Exporting data to $ehrSystem for patient: $patientId');
    
    // Simulate EHR integration
    await Future.delayed(const Duration(seconds: 2));
    
    return true;
  }

  /// Generate PDF report for sharing
  Future<String> generatePDFReport(String reportId) async {
    final report = _reports.firstWhere(
      (r) => r.reportId == reportId,
      orElse: () => throw Exception('Report not found'),
    );

    // In production, this would generate actual PDF
    final pdfPath = '/tmp/report_$reportId.pdf';
    debugPrint('📄 Generated PDF report: $pdfPath');
    
    return pdfPath;
  }

  /// Get appointments for a specific date range
  List<Appointment> getAppointments({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (_currentProvider == null) return [];

    var appointments = _appointments.where((apt) => 
      apt.providerId == _currentProvider!.providerId
    );

    if (startDate != null) {
      appointments = appointments.where((apt) => 
        apt.scheduledAt.isAfter(startDate)
      );
    }

    if (endDate != null) {
      appointments = appointments.where((apt) => 
        apt.scheduledAt.isBefore(endDate)
      );
    }

    return appointments.toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  /// Get clinical notes for patient
  List<ClinicalNote> getPatientNotes(String patientId) {
    if (_currentProvider == null) return [];

    return _notes.where((note) => 
      note.patientId == patientId && 
      note.providerId == _currentProvider!.providerId
    ).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get prescriptions for patient
  List<Prescription> getPatientPrescriptions(String patientId) {
    return _prescriptions.where((prescription) => 
      prescription.patientId == patientId &&
      prescription.providerId == _currentProvider!.providerId
    ).toList()
      ..sort((a, b) => b.prescribedAt.compareTo(a.prescribedAt));
  }

  /// Search patients by name or ID
  List<PatientProfile> searchPatients(String query) {
    if (_currentProvider == null || query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    return getProviderPatients().where((patient) {
      final fullName = '${patient.firstName ?? ''} ${patient.lastName ?? ''}'.toLowerCase();
      return fullName.contains(lowerQuery) || 
             patient.patientId.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Private helper methods

  Future<void> _loadSampleProviders() async {
    // Load sample providers for demonstration
  }

  Future<void> _loadSamplePatients() async {
    _patients.addAll([
      PatientProfile(
        patientId: 'patient_001',
        anonymousId: 'anon_user_123',
        firstName: 'Emma',
        lastName: 'Johnson',
        dateOfBirth: DateTime(1995, 6, 15),
        email: 'emma.j@email.com',
        authorizedProviders: ['provider_demo'],
        dataPermissions: {
          'cycle_data': true,
          'symptom_data': true,
          'biometric_data': true,
          'mood_data': true,
          'notes': false,
        },
        consentDate: DateTime.now().subtract(const Duration(days: 30)),
        isActive: true,
      ),
      PatientProfile(
        patientId: 'patient_002',
        anonymousId: 'anon_user_456',
        firstName: 'Sarah',
        lastName: 'Williams',
        dateOfBirth: DateTime(1988, 11, 22),
        email: 'sarah.w@email.com',
        authorizedProviders: ['provider_demo'],
        dataPermissions: {
          'cycle_data': true,
          'symptom_data': true,
          'biometric_data': false,
          'mood_data': true,
          'notes': true,
        },
        consentDate: DateTime.now().subtract(const Duration(days: 60)),
        isActive: true,
      ),
    ]);
  }

  Future<void> _generateSampleData() async {
    // Generate sample medical reports
    final sampleReports = [
      MedicalReport(
        reportId: 'report_001',
        patientId: 'patient_001',
        providerId: 'provider_demo',
        reportType: 'cycle_summary',
        generatedAt: DateTime.now().subtract(const Duration(days: 5)),
        periodStart: DateTime.now().subtract(const Duration(days: 90)),
        periodEnd: DateTime.now(),
        data: {
          'average_cycle_length': 28.5,
          'cycle_regularity': 0.85,
          'flow_duration': 5.2,
          'common_symptoms': ['mild_cramping', 'breast_tenderness', 'mood_changes'],
        },
        insights: [
          'Cycle length is within normal range',
          'Good cycle regularity indicates healthy hormonal balance',
          'Symptoms are mild and manageable',
        ],
        recommendations: [
          'Continue current lifestyle habits',
          'Monitor for any significant changes',
          'Consider magnesium supplement for mild cramping',
        ],
        status: ReportStatus.reviewed,
      ),
    ];

    _reports.addAll(sampleReports);

    // Generate sample appointments
    final sampleAppointments = [
      Appointment(
        appointmentId: 'apt_001',
        patientId: 'patient_001',
        providerId: 'provider_demo',
        title: 'Annual Gynecological Exam',
        description: 'Routine check-up and cycle review',
        scheduledAt: DateTime.now().add(const Duration(days: 7)),
        duration: const Duration(minutes: 45),
        type: AppointmentType.consultation,
        status: AppointmentStatus.scheduled,
        attachedReports: ['report_001'],
      ),
    ];

    _appointments.addAll(sampleAppointments);
  }

  Future<Map<String, dynamic>> _generateReportData(
    String patientId,
    String reportType,
    DateTime periodStart,
    DateTime periodEnd,
  ) async {
    // In production, this would analyze actual patient data
    switch (reportType) {
      case 'cycle_summary':
        return {
          'total_cycles': 3,
          'average_cycle_length': 28.5,
          'cycle_regularity': 0.85,
          'average_flow_duration': 5.2,
          'flow_intensity_distribution': {'light': 20, 'moderate': 60, 'heavy': 20},
          'common_symptoms': ['cramping', 'mood_changes', 'breast_tenderness'],
          'pms_severity': 'mild',
          'ovulation_patterns': 'regular',
        };
      case 'symptom_analysis':
        return {
          'tracked_symptoms': 12,
          'symptom_severity_avg': 3.2,
          'most_common_symptoms': ['cramping', 'fatigue', 'headache'],
          'symptom_patterns': {
            'pre_menstrual': ['mood_changes', 'breast_tenderness'],
            'menstrual': ['cramping', 'fatigue'],
            'post_menstrual': ['energy_increase'],
          },
          'pain_locations': ['lower_abdomen', 'lower_back'],
        };
      default:
        return {
          'report_type': reportType,
          'data_points': 156,
          'analysis_period_days': periodEnd.difference(periodStart).inDays,
        };
    }
  }

  List<String> _generateInsights(Map<String, dynamic> data) {
    final insights = <String>[];
    
    if (data.containsKey('cycle_regularity')) {
      final regularity = data['cycle_regularity'] as double;
      if (regularity > 0.8) {
        insights.add('Excellent cycle regularity indicates healthy hormonal balance');
      } else if (regularity > 0.6) {
        insights.add('Good cycle regularity with minor variations');
      } else {
        insights.add('Irregular cycles may indicate hormonal imbalance');
      }
    }

    if (data.containsKey('average_cycle_length')) {
      final length = data['average_cycle_length'] as double;
      if (length >= 21 && length <= 35) {
        insights.add('Cycle length is within the normal range (21-35 days)');
      } else {
        insights.add('Cycle length outside normal range may require evaluation');
      }
    }

    if (data.containsKey('pms_severity')) {
      final severity = data['pms_severity'] as String;
      switch (severity) {
        case 'mild':
          insights.add('PMS symptoms are mild and manageable');
          break;
        case 'moderate':
          insights.add('Moderate PMS symptoms may benefit from lifestyle modifications');
          break;
        case 'severe':
          insights.add('Severe PMS symptoms require medical attention and treatment');
          break;
      }
    }

    return insights;
  }

  List<String> _generateRecommendations(Map<String, dynamic> data) {
    final recommendations = <String>[];

    if (data.containsKey('common_symptoms')) {
      final symptoms = data['common_symptoms'] as List;
      
      if (symptoms.contains('cramping')) {
        recommendations.add('Consider heat therapy and gentle exercise for cramp relief');
        recommendations.add('Magnesium supplements may help reduce cramping');
      }
      
      if (symptoms.contains('mood_changes')) {
        recommendations.add('Regular exercise and stress management can help mood stability');
        recommendations.add('Consider tracking mood patterns for better understanding');
      }
      
      if (symptoms.contains('fatigue')) {
        recommendations.add('Ensure adequate iron intake during menstruation');
        recommendations.add('Maintain consistent sleep schedule');
      }
    }

    if (data.containsKey('cycle_regularity')) {
      final regularity = data['cycle_regularity'] as double;
      if (regularity < 0.6) {
        recommendations.add('Consider lifestyle factors affecting cycle regularity');
        recommendations.add('Evaluate stress levels and sleep quality');
        recommendations.add('Consider hormonal evaluation if irregularity persists');
      }
    }

    recommendations.add('Continue regular cycle tracking for ongoing health monitoring');
    recommendations.add('Schedule follow-up appointment in 3 months');

    return recommendations;
  }

  List<CycleData> _generateSampleCycleData() {
    // Generate sample cycle data for demonstration
    final cycles = <CycleData>[];
    final now = DateTime.now();
    
    for (int i = 0; i < 6; i++) {
      final startDate = now.subtract(Duration(days: (i * 28) + (i * 2)));
      cycles.add(CycleData(
        id: 'cycle_$i',
        startDate: startDate,
        endDate: startDate.add(Duration(days: 28 + Random().nextInt(6) - 3)),
        length: 28 + Random().nextInt(6) - 3,
        symptoms: ['cramping', 'mood_changes', 'fatigue'],
        notes: 'Sample cycle data',
        createdAt: startDate,
        updatedAt: DateTime.now(),
      ));
    }
    
    return cycles;
  }

  Map<String, dynamic> _generateSampleBiometricData() {
    // Generate sample biometric data for demonstration
    final data = <String, dynamic>{};
    final now = DateTime.now();
    
    data['heart_rate_data'] = List.generate(30, (i) => {
      'date': now.subtract(Duration(days: i)).toIso8601String(),
      'value': 65 + Random().nextInt(20),
    });
    
    data['temperature_data'] = List.generate(30, (i) => {
      'date': now.subtract(Duration(days: i)).toIso8601String(),
      'value': 97.8 + Random().nextDouble() * 1.4,
    });
    
    data['sleep_data'] = List.generate(30, (i) => {
      'date': now.subtract(Duration(days: i)).toIso8601String(),
      'value': Random().nextInt(5) + 1,
    });
    
    return data;
  }

  String _generateProviderId() {
    return 'provider_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  String _generateReportId() {
    return 'report_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  String _generateAppointmentId() {
    return 'apt_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  String _generateNoteId() {
    return 'note_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  String _generatePrescriptionId() {
    return 'rx_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  String _generateConsentId() {
    return 'consent_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  void dispose() {
    _patientsController.close();
    _reportsController.close();
    _appointmentsController.close();
    _analyticsController.close();
  }
}
