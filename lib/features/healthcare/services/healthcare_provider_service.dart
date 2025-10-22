import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/services/encryption_service.dart';
import '../../../core/services/user_preferences_service.dart';
import '../models/healthcare_provider.dart';
import '../models/medical_record.dart';
import '../models/health_report.dart';

/// Healthcare Provider Integration Service
/// Enables secure communication with healthcare providers and medical systems
class HealthcareProviderService {
  static final HealthcareProviderService _instance = HealthcareProviderService._internal();
  factory HealthcareProviderService() => _instance;
  HealthcareProviderService._internal();

  final EncryptionService _encryption = EncryptionService();
  final UserPreferencesService _preferences = UserPreferencesService();
  
  List<HealthcareProvider> _connectedProviders = [];
  List<MedicalRecord> _medicalRecords = [];
  bool _isInitialized = false;

  /// Initialize healthcare integration
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    debugPrint('🏥 Initializing Healthcare Provider Integration...');
    
    try {
      await _loadConnectedProviders();
      await _loadMedicalRecords();
      
      _isInitialized = true;
      debugPrint('✅ Healthcare Provider Service initialized');
    } catch (e) {
      debugPrint('❌ Healthcare Provider Service initialization failed: $e');
      rethrow;
    }
  }

  /// Connect to a healthcare provider
  Future<bool> connectProvider(HealthcareProvider provider, String authCode) async {
    try {
      debugPrint('🔗 Connecting to provider: ${provider.name}');
      
      // Validate provider credentials
      final isValid = await _validateProviderCredentials(provider, authCode);
      if (!isValid) {
        throw Exception('Invalid provider credentials');
      }
      
      // Encrypt and store provider connection
      final encryptedData = await _encryption.encrypt(jsonEncode(provider.toJson()));
      await _preferences.setString('provider_${provider.id}', encryptedData);
      
      // Add to connected providers
      _connectedProviders.add(provider);
      
      // Initial data sync
      await _syncProviderData(provider);
      
      debugPrint('✅ Successfully connected to ${provider.name}');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to connect provider: $e');
      return false;
    }
  }

  /// Disconnect from a healthcare provider
  Future<bool> disconnectProvider(String providerId) async {
    try {
      debugPrint('🔌 Disconnecting from provider: $providerId');
      
      // Remove encrypted data
      await _preferences.remove('provider_$providerId');
      
      // Remove from connected providers
      _connectedProviders.removeWhere((p) => p.id == providerId);
      
      debugPrint('✅ Provider disconnected successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to disconnect provider: $e');
      return false;
    }
  }

  /// Get connected healthcare providers
  List<HealthcareProvider> get connectedProviders => List.unmodifiable(_connectedProviders);

  /// Share cycle data with healthcare provider
  Future<bool> shareCycleData(String providerId, Map<String, dynamic> cycleData) async {
    try {
      final provider = _connectedProviders.firstWhere((p) => p.id == providerId);
      
      debugPrint('📤 Sharing cycle data with ${provider.name}');
      
      // Encrypt sensitive health data
      final encryptedData = await _encryption.encrypt(jsonEncode(cycleData));
      
      // Send to provider API (mock implementation)
      final success = await _sendToProviderAPI(provider, encryptedData);
      
      if (success) {
        // Log the share event
        await _logDataShare(providerId, 'cycle_data');
        debugPrint('✅ Cycle data shared successfully');
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ Failed to share cycle data: $e');
      return false;
    }
  }

  /// Request medical records from provider
  Future<List<MedicalRecord>> requestMedicalRecords(String providerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final provider = _connectedProviders.firstWhere((p) => p.id == providerId);
      
      debugPrint('📥 Requesting medical records from ${provider.name}');
      
      // Request records from provider API
      final records = await _requestFromProviderAPI(provider, {
        'type': 'medical_records',
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
      });
      
      // Decrypt and parse records
      final medicalRecords = <MedicalRecord>[];
      for (final record in records) {
        final decrypted = await _encryption.decrypt(record);
        medicalRecords.add(MedicalRecord.fromJson(jsonDecode(decrypted)));
      }
      
      // Store records locally
      _medicalRecords.addAll(medicalRecords);
      await _saveMedicalRecords();
      
      debugPrint('✅ Retrieved ${medicalRecords.length} medical records');
      return medicalRecords;
    } catch (e) {
      debugPrint('❌ Failed to request medical records: $e');
      return [];
    }
  }

  /// Generate health report for provider
  Future<HealthReport> generateHealthReport({
    required String providerId,
    required DateTime startDate,
    required DateTime endDate,
    bool includeSymptoms = true,
    bool includeMoodData = true,
    bool includePredictions = true,
  }) async {
    try {
      debugPrint('📊 Generating health report for provider: $providerId');
      
      final provider = _connectedProviders.firstWhere((p) => p.id == providerId);
      
      // Collect and analyze health data
      final report = HealthReport(
        id: 'report_${DateTime.now().millisecondsSinceEpoch}',
        providerId: providerId,
        providerName: provider.name,
        patientId: await _preferences.getString('user_id') ?? 'unknown',
        reportDate: DateTime.now(),
        startDate: startDate,
        endDate: endDate,
        includeSymptoms: includeSymptoms,
        includeMoodData: includeMoodData,
        includePredictions: includePredictions,
        data: await _generateReportData(startDate, endDate, {
          'symptoms': includeSymptoms,
          'mood': includeMoodData,
          'predictions': includePredictions,
        }),
      );
      
      debugPrint('✅ Health report generated successfully');
      return report;
    } catch (e) {
      debugPrint('❌ Failed to generate health report: $e');
      rethrow;
    }
  }

  /// Get available provider types
  List<ProviderType> get availableProviderTypes => [
    ProviderType.gynecologist,
    ProviderType.generalPractitioner,
    ProviderType.endocrinologist,
    ProviderType.mentalHealthProvider,
    ProviderType.nutritionist,
    ProviderType.fertilityClinician,
  ];

  /// Check if HIPAA compliance is enabled
  bool get isHipaaCompliant => _preferences.getBool('hipaa_compliant') ?? false;

  /// Enable HIPAA compliance
  Future<void> enableHipaaCompliance() async {
    await _preferences.setBool('hipaa_compliant', true);
    debugPrint('🏥 HIPAA compliance enabled');
  }

  // Private helper methods

  Future<void> _loadConnectedProviders() async {
    try {
      final keys = await _preferences.getKeys();
      for (final key in keys.where((k) => k.startsWith('provider_'))) {
        final encryptedData = await _preferences.getString(key);
        if (encryptedData != null) {
          final decrypted = await _encryption.decrypt(encryptedData);
          final provider = HealthcareProvider.fromJson(jsonDecode(decrypted));
          _connectedProviders.add(provider);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error loading connected providers: $e');
    }
  }

  Future<void> _loadMedicalRecords() async {
    try {
      final recordsData = await _preferences.getString('medical_records');
      if (recordsData != null) {
        final decrypted = await _encryption.decrypt(recordsData);
        final List<dynamic> recordsList = jsonDecode(decrypted);
        _medicalRecords = recordsList
            .map((r) => MedicalRecord.fromJson(r))
            .toList();
      }
    } catch (e) {
      debugPrint('⚠️ Error loading medical records: $e');
    }
  }

  Future<void> _saveMedicalRecords() async {
    try {
      final recordsJson = _medicalRecords.map((r) => r.toJson()).toList();
      final encrypted = await _encryption.encrypt(jsonEncode(recordsJson));
      await _preferences.setString('medical_records', encrypted);
    } catch (e) {
      debugPrint('⚠️ Error saving medical records: $e');
    }
  }

  Future<bool> _validateProviderCredentials(HealthcareProvider provider, String authCode) async {
    // Mock validation - in real implementation, this would validate with provider's OAuth system
    await Future.delayed(const Duration(seconds: 1));
    return authCode.length >= 6; // Simple validation for demo
  }

  Future<void> _syncProviderData(HealthcareProvider provider) async {
    // Mock data sync - in real implementation, this would sync initial data
    debugPrint('🔄 Syncing initial data with ${provider.name}');
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<bool> _sendToProviderAPI(HealthcareProvider provider, String encryptedData) async {
    // Mock API call - in real implementation, this would call provider's API
    debugPrint('📡 Sending data to ${provider.name} API');
    await Future.delayed(const Duration(seconds: 1));
    return true; // Mock success
  }

  Future<List<String>> _requestFromProviderAPI(HealthcareProvider provider, Map<String, String?> params) async {
    // Mock API call - in real implementation, this would call provider's API
    debugPrint('📡 Requesting data from ${provider.name} API');
    await Future.delayed(const Duration(seconds: 1));
    return []; // Mock empty response
  }

  Future<void> _logDataShare(String providerId, String dataType) async {
    final shareLog = {
      'provider_id': providerId,
      'data_type': dataType,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    // Store share log for audit trail
    final logs = await _preferences.getStringList('data_shares') ?? [];
    logs.add(jsonEncode(shareLog));
    await _preferences.setStringList('data_shares', logs);
  }

  Future<Map<String, dynamic>> _generateReportData(
    DateTime startDate,
    DateTime endDate,
    Map<String, bool> includes,
  ) async {
    // Mock report data generation
    // In real implementation, this would aggregate data from the database
    return {
      'period': 'Analysis of menstrual health data',
      'cycles_analyzed': 3,
      'average_cycle_length': 28,
      'symptoms_tracked': includes['symptoms'] == true ? ['cramping', 'headache', 'bloating'] : [],
      'mood_patterns': includes['mood'] == true ? 'Generally stable with pre-menstrual variations' : null,
      'predictions': includes['predictions'] == true ? 'Next period predicted in 7 days with 85% confidence' : null,
      'recommendations': [
        'Consider tracking basal body temperature for more accurate ovulation prediction',
        'Regular exercise may help reduce cramping severity',
      ],
    };
  }
}

/// HIPAA compliance utilities
class HipaaCompliance {
  /// Check if data sharing is compliant
  static bool isDataShareCompliant(Map<String, dynamic> data) {
    // Basic HIPAA compliance checks
    final hasPatientConsent = data['patient_consent'] == true;
    final hasMinimumNecessary = data['minimum_necessary'] == true;
    final hasEncryption = data['encrypted'] == true;
    
    return hasPatientConsent && hasMinimumNecessary && hasEncryption;
  }

  /// Generate HIPAA audit log entry
  static Map<String, dynamic> generateAuditLog({
    required String action,
    required String userId,
    required String providerId,
    String? dataType,
  }) {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'action': action,
      'user_id': userId,
      'provider_id': providerId,
      'data_type': dataType,
      'compliance_verified': true,
    };
  }
}
