import 'dart:convert';
import 'package:encrypt/encrypt.dart' as enc;
import '../models/cycle_data.dart';
import '../models/daily_tracking_data.dart';
import '../database/database_service.dart';
import 'user_preferences_service.dart';

/// Cloud sync service stub - Firebase disabled for iOS build
/// This provides a local-only implementation until Firebase is re-enabled
class CloudSyncService {
  final DatabaseService _databaseService = DatabaseService();
  final UserPreferencesService _preferencesService = UserPreferencesService();
  final bool _firebaseAvailable = false;

  // Encryption
  late final enc.Encrypter _encrypter;
  late final enc.IV _iv;

  // Sync state
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  CloudSyncService() {
    _initializeEncryption();
  }

  void _initializeEncryption() {
    // Generate encryption key from user's device ID and app secret
    final key = enc.Key.fromSecureRandom(32);
    _encrypter = enc.Encrypter(enc.AES(key));
    _iv = enc.IV.fromSecureRandom(16);
  }

  // Getters (Firebase-free)
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  dynamic get currentUser => null; // No Firebase user
  bool get isSignedIn => false; // Always false when Firebase is disabled
  bool get isFirebaseAvailable => _firebaseAvailable;

  // Stub authentication methods
  Future<dynamic> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    throw Exception('Firebase authentication is disabled in this build');
  }

  Future<dynamic> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    throw Exception('Firebase authentication is disabled in this build');
  }

  Future<void> signOut() async {
    _lastSyncTime = null;
  }

  // Stub cloud sync operations (local-only)
  Future<void> syncToCloud({bool force = false}) async {
    if (_isSyncing && !force) {
      return;
    }

    _isSyncing = true;

    try {
      // Simulate local backup instead of cloud sync
      await _createLocalBackup();

      _lastSyncTime = DateTime.now();
      _preferencesService.setLastSyncTime(_lastSyncTime!);
    } catch (e) {
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> syncFromCloud({bool force = false}) async {
    // No-op when Firebase is disabled
    _lastSyncTime = DateTime.now();
    _preferencesService.setLastSyncTime(_lastSyncTime!);
  }

  Future<void> bidirectionalSync() async {
    await syncToCloud(force: true);
  }

  // Data encryption/decryption (still functional for local use)
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
    final encrypted = enc.Encrypted.fromBase64(encryptedData['encryptedData']);
    final iv = enc.IV.fromBase64(encryptedData['iv']);
    final decrypted = _encrypter.decrypt(encrypted, iv: iv);
    return jsonDecode(decrypted);
  }

  // Local backup operations
  Map<String, double> _decodeTrackingMap(dynamic raw) {
    if (raw == null) {
      return const <String, double>{};
    }

    final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );
  }

  Future<void> _createLocalBackup() async {
    try {
      final cycles = await _databaseService.getAllCycles();
      final trackingRows = await _databaseService.getAllTrackingData();

      final tracking = trackingRows.map((row) {
        final date = DateTime.parse(row['date'] as String);
        final flowName = row['flow_intensity'] as String?;

        return DailyTrackingData(
          date: date,
          flowIntensity: flowName == null
              ? null
              : FlowIntensity.values.byName(flowName).index,
          mood: (row['mood'] as num?)?.round(),
          energy: (row['energy'] as num?)?.round(),
          pain: (row['pain'] as num?)?.round(),
          moodObserved: row['mood_observed'] == 1,
          energyObserved: row['energy_observed'] == 1,
          painObserved: row['pain_observed'] == 1,
          symptoms:
              (row['symptoms'] as String?)
                  ?.split(',')
                  .where((value) => value.isNotEmpty)
                  .toList() ??
              const <String>[],
          symptomSeverity: _decodeTrackingMap(row['symptom_severity']),
          painAreas: _decodeTrackingMap(row['pain_areas']),
          notes: row['notes'] as String?,
          createdAt: DateTime.parse(row['created_at'] as String),
          updatedAt: DateTime.parse(row['updated_at'] as String),
        ).toMap();
      }).toList();

      final backupData = {
        'cycles': cycles.map((cycle) => cycle.toJson()).toList(),
        'tracking': tracking,
        'preferences': _preferencesService.getAllPreferences(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      final encryptedBackup = _encryptData(backupData);

      // Store encrypted backup in local preferences
      _preferencesService.setString(
        'local_backup',
        jsonEncode(encryptedBackup),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> restoreFromLocalBackup() async {
    try {
      final backupString = _preferencesService.getString('local_backup');
      if (backupString == null) {
        throw Exception('No local backup found');
      }

      final encryptedBackup = jsonDecode(backupString);
      final backupData = _decryptData(encryptedBackup);

      // Restore cycles
      if (backupData['cycles'] != null) {
        final cycles = (backupData['cycles'] as List)
            .map((data) => CycleData.fromJson(data))
            .toList();

        for (final cycle in cycles) {
          await _databaseService.updateCycle(cycle);
        }
      }

      // Restore tracking data
      if (backupData['tracking'] != null) {
        final trackingData = (backupData['tracking'] as List)
            .map((data) => DailyTrackingData.fromMap(data))
            .toList();

        for (final data in trackingData) {
          final flowIndex = data.flowIntensity;
          final restoredFlow =
              flowIndex != null &&
                  flowIndex >= 0 &&
                  flowIndex < FlowIntensity.values.length
              ? FlowIntensity.values[flowIndex]
              : null;

          await _databaseService.saveDailyTracking(
            date: data.date,
            flowIntensity: restoredFlow,
            symptoms: data.symptoms,
            symptomSeverity: data.symptomSeverity.isEmpty
                ? null
                : data.symptomSeverity,
            mood: data.mood?.toDouble(),
            energy: data.energy?.toDouble(),
            pain: data.pain?.toDouble(),
            moodObserved: data.moodObserved,
            energyObserved: data.energyObserved,
            painObserved: data.painObserved,
            painAreas: data.painAreas.isEmpty ? null : data.painAreas,
            notes: data.notes,
          );
        }
      }

      // Restore preferences
      if (backupData['preferences'] != null) {
        _preferencesService.setAllPreferences(backupData['preferences']);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Stub methods for Firebase features
  Future<void> createBackup() async {
    await _createLocalBackup();
  }

  Future<void> restoreFromBackup(String backupId) async {
    await restoreFromLocalBackup();
  }

  void enableAutoSync({Duration interval = const Duration(hours: 6)}) {}

  void disableAutoSync() {}

  // Sync status (local-only)
  Future<SyncStatus> getSyncStatus() async {
    final lastSyncTime = _preferencesService.getLastSyncTime();

    return SyncStatus(
      isSignedIn: false, // Always false when Firebase is disabled
      isSyncing: _isSyncing,
      lastLocalModified: null,
      lastCloudModified: null,
      lastSyncTime: lastSyncTime,
      needsSync: false, // No cloud sync needed
      isLocalOnly: true,
      firebaseAvailable: _firebaseAvailable,
    );
  }

  // Data deletion (local only)
  Future<void> deleteCloudData() async {
    try {
      _preferencesService.remove('local_backup');
    } catch (e) {
      rethrow;
    }
  }

  // Utility methods
  Future<bool> hasLocalBackup() async {
    final backup = _preferencesService.getString('local_backup');
    return backup != null;
  }

  Future<DateTime?> getLocalBackupTime() async {
    try {
      final backupString = _preferencesService.getString('local_backup');
      if (backupString == null) return null;

      final encryptedBackup = jsonDecode(backupString);
      final backupData = _decryptData(encryptedBackup);

      final createdAt = backupData['createdAt'] as String?;
      return createdAt != null ? DateTime.parse(createdAt) : null;
    } catch (e) {
      return null;
    }
  }
}

// Enhanced sync status model with local-only support
class SyncStatus {
  final bool isSignedIn;
  final bool isSyncing;
  final DateTime? lastLocalModified;
  final DateTime? lastCloudModified;
  final DateTime? lastSyncTime;
  final bool needsSync;
  final bool isLocalOnly;
  final bool firebaseAvailable;

  SyncStatus({
    required this.isSignedIn,
    required this.isSyncing,
    this.lastLocalModified,
    this.lastCloudModified,
    this.lastSyncTime,
    required this.needsSync,
    this.isLocalOnly = false,
    this.firebaseAvailable = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'isSignedIn': isSignedIn,
      'isSyncing': isSyncing,
      'lastLocalModified': lastLocalModified?.toIso8601String(),
      'lastCloudModified': lastCloudModified?.toIso8601String(),
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'needsSync': needsSync,
      'isLocalOnly': isLocalOnly,
      'firebaseAvailable': firebaseAvailable,
    };
  }
}
