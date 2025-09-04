import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import '../models/cycle_data.dart';
import '../models/daily_tracking_data.dart';
import '../models/biometric_data.dart';
import 'database_service.dart';
import 'user_preferences_service.dart';

/// Cloud sync service stub - Firebase disabled for iOS build
/// This provides a local-only implementation until Firebase is re-enabled
class CloudSyncService {
  final DatabaseService _databaseService = DatabaseService();
  final UserPreferencesService _preferencesService = UserPreferencesService();
  final bool _firebaseAvailable = false;
  
  // Encryption
  late final Encrypter _encrypter;
  late final IV _iv;
  
  // Sync state
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  
  CloudSyncService() {
    _initializeEncryption();
    debugPrint('⚠️ CloudSyncService: Firebase disabled, using local-only mode');
  }
  
  void _initializeEncryption() {
    // Generate encryption key from user's device ID and app secret
    final key = Key.fromSecureRandom(32);
    _encrypter = Encrypter(AES(key));
    _iv = IV.fromSecureRandom(16);
  }
  
  // Getters (Firebase-free)
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  dynamic get currentUser => null; // No Firebase user
  bool get isSignedIn => false; // Always false when Firebase is disabled
  bool get isFirebaseAvailable => _firebaseAvailable;
  
  // Stub authentication methods
  Future<dynamic> signInWithEmailAndPassword(String email, String password) async {
    debugPrint('⚠️ CloudSyncService: Firebase auth disabled, returning null');
    throw Exception('Firebase authentication is disabled in this build');
  }
  
  Future<dynamic> createUserWithEmailAndPassword(String email, String password) async {
    debugPrint('⚠️ CloudSyncService: Firebase auth disabled, returning null');
    throw Exception('Firebase authentication is disabled in this build');
  }
  
  Future<void> signOut() async {
    debugPrint('⚠️ CloudSyncService: Firebase auth disabled, local sign out only');
    _lastSyncTime = null;
  }
  
  // Stub cloud sync operations (local-only)
  Future<void> syncToCloud({bool force = false}) async {
    debugPrint('⚠️ CloudSyncService: Cloud sync disabled, data stored locally only');
    
    if (_isSyncing && !force) {
      debugPrint('Local sync already in progress');
      return;
    }
    
    _isSyncing = true;
    
    try {
      // Simulate local backup instead of cloud sync
      await _createLocalBackup();
      
      _lastSyncTime = DateTime.now();
      await _preferencesService.setLastSyncTime(_lastSyncTime!);
      
      debugPrint('✅ Local backup completed successfully (Firebase disabled)');
    } catch (e) {
      debugPrint('❌ Error creating local backup: $e');
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }
  
  Future<void> syncFromCloud({bool force = false}) async {
    debugPrint('⚠️ CloudSyncService: Cloud sync disabled, no data to download');
    
    // No-op when Firebase is disabled
    _lastSyncTime = DateTime.now();
    await _preferencesService.setLastSyncTime(_lastSyncTime!);
  }
  
  Future<void> bidirectionalSync() async {
    debugPrint('⚠️ CloudSyncService: Cloud sync disabled, performing local backup only');
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
    final encrypted = Encrypted.fromBase64(encryptedData['encryptedData']);
    final iv = IV.fromBase64(encryptedData['iv']);
    final decrypted = _encrypter.decrypt(encrypted, iv: iv);
    return jsonDecode(decrypted);
  }
  
  // Local backup operations
  Future<void> _createLocalBackup() async {
    try {
      final backupData = {
        'cycles': await _databaseService.getAllCycles(),
        'tracking': await _databaseService.getAllTrackingData(),
        'preferences': await _preferencesService.getAllPreferences(),
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      final encryptedBackup = _encryptData(backupData);
      
      // Store encrypted backup in local preferences
      await _preferencesService.setString('local_backup', jsonEncode(encryptedBackup));
      
      debugPrint('✅ Local backup created successfully');
    } catch (e) {
      debugPrint('❌ Error creating local backup: $e');
      rethrow;
    }
  }
  
  Future<void> restoreFromLocalBackup() async {
    try {
      final backupString = await _preferencesService.getString('local_backup');
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
            .map((data) => DailyTrackingData.fromJson(data))
            .toList();
        
        for (final data in trackingData) {
          await _databaseService.saveDailyTracking(data);
        }
      }
      
      // Restore preferences
      if (backupData['preferences'] != null) {
        await _preferencesService.setAllPreferences(backupData['preferences']);
      }
      
      debugPrint('✅ Local backup restored successfully');
    } catch (e) {
      debugPrint('❌ Error restoring local backup: $e');
      rethrow;
    }
  }
  
  // Stub methods for Firebase features
  Future<void> createBackup() async {
    debugPrint('⚠️ CloudSyncService: Creating local backup instead of cloud backup');
    await _createLocalBackup();
  }
  
  Future<void> restoreFromBackup(String backupId) async {
    debugPrint('⚠️ CloudSyncService: Restoring from local backup instead of cloud backup');
    await restoreFromLocalBackup();
  }
  
  void enableAutoSync({Duration interval = const Duration(hours: 6)}) {
    debugPrint('⚠️ CloudSyncService: Auto sync disabled (Firebase unavailable)');
  }
  
  void disableAutoSync() {
    debugPrint('⚠️ CloudSyncService: Auto sync already disabled (Firebase unavailable)');
  }
  
  // Sync status (local-only)
  Future<SyncStatus> getSyncStatus() async {
    final lastSyncTime = await _preferencesService.getLastSyncTime();
    
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
    debugPrint('⚠️ CloudSyncService: Deleting local backup data only (Firebase unavailable)');
    
    try {
      await _preferencesService.remove('local_backup');
      debugPrint('✅ Local backup data deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting local backup data: $e');
      rethrow;
    }
  }
  
  // Utility methods
  Future<bool> hasLocalBackup() async {
    final backup = await _preferencesService.getString('local_backup');
    return backup != null;
  }
  
  Future<DateTime?> getLocalBackupTime() async {
    try {
      final backupString = await _preferencesService.getString('local_backup');
      if (backupString == null) return null;
      
      final encryptedBackup = jsonDecode(backupString);
      final backupData = _decryptData(encryptedBackup);
      
      final createdAt = backupData['createdAt'] as String?;
      return createdAt != null ? DateTime.parse(createdAt) : null;
    } catch (e) {
      debugPrint('Error getting local backup time: $e');
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
