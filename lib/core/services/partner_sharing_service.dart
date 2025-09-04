import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import '../models/cycle_data.dart';
import '../models/daily_tracking_data.dart';
import 'database_service.dart';
import 'user_preferences_service.dart';
import 'cloud_sync_service.dart';

/// Partner sharing service stub - Firebase disabled for iOS build
/// This provides a local-only implementation until Firebase is re-enabled
class PartnerSharingService {
  final DatabaseService _databaseService = DatabaseService();
  final UserPreferencesService _preferencesService = UserPreferencesService();
  final CloudSyncService _cloudSyncService = CloudSyncService();
  final bool _firebaseAvailable = false;

  // Encryption for shared data
  late final Encrypter _encrypter;
  late final IV _iv;

  PartnerSharingService() {
    _initializeEncryption();
    debugPrint('⚠️ PartnerSharingService: Firebase disabled, sharing features unavailable');
  }

  void _initializeEncryption() {
    final key = Key.fromSecureRandom(32);
    _encrypter = Encrypter(AES(key));
    _iv = IV.fromSecureRandom(16);
  }

  // Stub methods that throw exceptions since Firebase is disabled
  Future<SharingInvitation> createSharingInvitation({
    required String partnerEmail,
    required SharingPermissions permissions,
    required String invitationMessage,
    DateTime? expiresAt,
  }) async {
    debugPrint('⚠️ PartnerSharingService: Partner sharing disabled (Firebase unavailable)');
    throw Exception('Partner sharing is disabled in this build. Firebase authentication required.');
  }

  Future<SharedConnection> acceptSharingInvitation(String invitationCode) async {
    debugPrint('⚠️ PartnerSharingService: Partner sharing disabled (Firebase unavailable)');
    throw Exception('Partner sharing is disabled in this build. Firebase authentication required.');
  }

  Future<void> declineSharingInvitation(String invitationCode, String reason) async {
    debugPrint('⚠️ PartnerSharingService: Partner sharing disabled (Firebase unavailable)');
    throw Exception('Partner sharing is disabled in this build. Firebase authentication required.');
  }

  Future<List<SharedConnection>> getSharedConnections() async {
    debugPrint('⚠️ PartnerSharingService: Partner sharing disabled (Firebase unavailable)');
    return []; // Return empty list instead of throwing
  }

  Future<void> shareDataWithPartner(
    String connectionId,
    List<String> cycleIds,
    List<String> trackingDataIds, {
    String? note,
  }) async {
    debugPrint('⚠️ PartnerSharingService: Partner sharing disabled (Firebase unavailable)');
    throw Exception('Partner sharing is disabled in this build. Firebase authentication required.');
  }

  Future<SharedData> getSharedData(String connectionId) async {
    debugPrint('⚠️ PartnerSharingService: Partner sharing disabled (Firebase unavailable)');
    throw Exception('Partner sharing is disabled in this build. Firebase authentication required.');
  }

  Future<void> updateSharingPermissions(String connectionId, SharingPermissions newPermissions) async {
    debugPrint('⚠️ PartnerSharingService: Partner sharing disabled (Firebase unavailable)');
    throw Exception('Partner sharing is disabled in this build. Firebase authentication required.');
  }

  Future<void> revokeSharing(String connectionId, String reason) async {
    debugPrint('⚠️ PartnerSharingService: Partner sharing disabled (Firebase unavailable)');
    throw Exception('Partner sharing is disabled in this build. Firebase authentication required.');
  }

  Future<EmergencyShare> createEmergencyShare({
    required String healthcareProviderEmail,
    required String urgencyLevel,
    required String medicalContext,
    DateTime? expiresAt,
  }) async {
    debugPrint('⚠️ PartnerSharingService: Emergency sharing disabled (Firebase unavailable)');
    throw Exception('Emergency sharing is disabled in this build. Firebase authentication required.');
  }

  Future<Map<String, dynamic>> accessEmergencyShare(String shareId, String accessCode) async {
    debugPrint('⚠️ PartnerSharingService: Emergency sharing disabled (Firebase unavailable)');
    throw Exception('Emergency sharing is disabled in this build. Firebase authentication required.');
  }

  // Local backup functionality that doesn't require Firebase
  Future<void> createLocalDataExport() async {
    try {
      debugPrint('📤 Creating local data export...');
      
      final exportData = {
        'cycles': await _databaseService.getAllCycles(),
        'tracking': await _databaseService.getAllTrackingData(),
        'preferences': await _preferencesService.getAllPreferences(),
        'exportedAt': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0',
      };
      
      final encryptedExport = _encryptData(exportData);
      await _preferencesService.setString('local_data_export', jsonEncode(encryptedExport));
      
      debugPrint('✅ Local data export created successfully');
    } catch (e) {
      debugPrint('❌ Error creating local data export: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getLocalDataExport() async {
    try {
      final exportString = await _preferencesService.getString('local_data_export');
      if (exportString == null) return null;
      
      final encryptedExport = jsonDecode(exportString);
      return _decryptData(encryptedExport);
    } catch (e) {
      debugPrint('❌ Error retrieving local data export: $e');
      return null;
    }
  }

  // Utility methods
  Map<String, dynamic> _encryptData(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    final encrypted = _encrypter.encrypt(jsonString, iv: _iv);
    return {
      'encryptedData': encrypted.base64,
      'iv': _iv.base64,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  Map<String, dynamic> _decryptData(Map<String, dynamic> encryptedData) {
    final encrypted = Encrypted.fromBase64(encryptedData['encryptedData']);
    final iv = IV.fromBase64(encryptedData['iv']);
    final decrypted = _encrypter.decrypt(encrypted, iv: iv);
    return jsonDecode(decrypted);
  }

  // Status methods
  bool get isFirebaseAvailable => _firebaseAvailable;
  bool get isSharingAvailable => false; // Always false when Firebase is disabled
  
  Future<Map<String, dynamic>> getSharingStatus() async {
    return {
      'firebaseAvailable': _firebaseAvailable,
      'sharingEnabled': false,
      'localExportAvailable': await _hasLocalExport(),
      'message': 'Partner sharing requires Firebase authentication which is disabled in this build',
    };
  }

  Future<bool> _hasLocalExport() async {
    final export = await _preferencesService.getString('local_data_export');
    return export != null;
  }

  String _generateInvitationCode() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return String.fromCharCodes(Iterable.generate(
      8, (_) => characters.codeUnitAt(random.nextInt(characters.length))
    ));
  }
}

// Stub models for partner sharing (simplified versions)
class SharingInvitation {
  final String id;
  final String ownerEmail;
  final String partnerEmail;
  final SharingPermissions permissions;
  final SharingStatus status;
  final String invitationMessage;
  final DateTime createdAt;
  final DateTime expiresAt;

  SharingInvitation({
    required this.id,
    required this.ownerEmail,
    required this.partnerEmail,
    required this.permissions,
    required this.status,
    required this.invitationMessage,
    required this.createdAt,
    required this.expiresAt,
  });
}

class SharedConnection {
  final String id;
  final String ownerEmail;
  final String partnerEmail;
  final SharingPermissions permissions;
  final ConnectionStatus status;
  final DateTime createdAt;

  SharedConnection({
    required this.id,
    required this.ownerEmail,
    required this.partnerEmail,
    required this.permissions,
    required this.status,
    required this.createdAt,
  });
}

class SharingPermissions {
  final bool canViewCycles;
  final bool canViewTracking;
  final bool canViewSymptoms;
  final bool canViewAnalytics;
  final bool canReceiveNotifications;
  final bool isHealthcareProvider;

  SharingPermissions({
    required this.canViewCycles,
    required this.canViewTracking,
    required this.canViewSymptoms,
    required this.canViewAnalytics,
    required this.canReceiveNotifications,
    this.isHealthcareProvider = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'canViewCycles': canViewCycles,
      'canViewTracking': canViewTracking,
      'canViewSymptoms': canViewSymptoms,
      'canViewAnalytics': canViewAnalytics,
      'canReceiveNotifications': canReceiveNotifications,
      'isHealthcareProvider': isHealthcareProvider,
    };
  }

  factory SharingPermissions.fromMap(Map<String, dynamic> map) {
    return SharingPermissions(
      canViewCycles: map['canViewCycles'] ?? false,
      canViewTracking: map['canViewTracking'] ?? false,
      canViewSymptoms: map['canViewSymptoms'] ?? false,
      canViewAnalytics: map['canViewAnalytics'] ?? false,
      canReceiveNotifications: map['canReceiveNotifications'] ?? false,
      isHealthcareProvider: map['isHealthcareProvider'] ?? false,
    );
  }
}

class SharedData {
  final String connectionId;
  final List<CycleData> cycles;
  final List<DailyTrackingData> trackingData;
  final DateTime lastUpdated;

  SharedData({
    required this.connectionId,
    required this.cycles,
    required this.trackingData,
    required this.lastUpdated,
  });
}

class EmergencyShare {
  final String id;
  final String ownerEmail;
  final String healthcareProviderEmail;
  final String urgencyLevel;
  final String medicalContext;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String accessCode;

  EmergencyShare({
    required this.id,
    required this.ownerEmail,
    required this.healthcareProviderEmail,
    required this.urgencyLevel,
    required this.medicalContext,
    required this.createdAt,
    required this.expiresAt,
    required this.accessCode,
  });
}

enum SharingStatus { pending, accepted, declined, expired }
enum ConnectionStatus { active, paused, revoked }
