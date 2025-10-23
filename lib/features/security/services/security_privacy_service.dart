import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

/// Security and privacy service for healthcare data protection
class SecurityPrivacyService {
  static SecurityPrivacyService? _instance;
  static SecurityPrivacyService get instance {
    _instance ??= SecurityPrivacyService._internal();
    return _instance!;
  }

  SecurityPrivacyService._internal();

  bool _isInitialized = false;
  SharedPreferences? _prefs;
  final LocalAuthentication _localAuth = LocalAuthentication();
  late Encrypter _dataEncrypter;
  late Key _masterKey;
  SecurityConfig? _securityConfig;

  // Security constants
  static const String _masterKeyAlias = 'flowai_master_key';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _encryptionEnabledKey = 'encryption_enabled';
  static const String _privacySettingsKey = 'privacy_settings';
  static const String _securityConfigKey = 'security_config';
  static const String _sessionTokenKey = 'session_token';
  static const String _lastAuthKey = 'last_auth_timestamp';
  static const int _sessionTimeoutMinutes = 15;
  static const int _maxFailedAttempts = 5;
  static const int _lockoutDurationMinutes = 30;

  /// Initialize the security and privacy service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      
      // Initialize encryption
      await _initializeEncryption();
      
      // Load security configuration
      await _loadSecurityConfig();
      
      // Initialize biometric authentication
      await _initializeBiometrics();
      
      _isInitialized = true;
      debugPrint('🔒 Security and privacy service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize security service: $e');
      throw SecurityException('Failed to initialize security service: $e');
    }
  }

  /// Initialize encryption system
  Future<void> _initializeEncryption() async {
    try {
      // Generate or retrieve master key
      String? storedKey = _prefs?.getString(_masterKeyAlias);
      if (storedKey != null) {
        _masterKey = Key.fromBase64(storedKey);
      } else {
        _masterKey = Key.fromSecureRandom(32);
        await _prefs?.setString(_masterKeyAlias, _masterKey.base64);
      }
      
      // Initialize AES encrypter
      final iv = IV.fromSecureRandom(16);
      _dataEncrypter = Encrypter(AES(_masterKey));
      
      debugPrint('🔐 Encryption system initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize encryption: $e');
      throw SecurityException('Failed to initialize encryption: $e');
    }
  }

  /// Initialize biometric authentication
  Future<void> _initializeBiometrics() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (isAvailable && isDeviceSupported) {
        final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
        debugPrint('🔓 Available biometrics: $availableBiometrics');
      }
    } catch (e) {
      debugPrint('⚠️ Biometric initialization warning: $e');
      // Non-critical error, continue without biometrics
    }
  }

  /// Load security configuration
  Future<void> _loadSecurityConfig() async {
    try {
      final String? configStr = _prefs?.getString(_securityConfigKey);
      if (configStr != null) {
        final Map<String, dynamic> configJson = json.decode(configStr);
        _securityConfig = SecurityConfig.fromJson(configJson);
      } else {
        _securityConfig = SecurityConfig.defaultConfig();
        await _saveSecurityConfig();
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load security config, using defaults: $e');
      _securityConfig = SecurityConfig.defaultConfig();
      await _saveSecurityConfig();
    }
  }

  /// Save security configuration
  Future<void> _saveSecurityConfig() async {
    if (_securityConfig != null) {
      await _prefs?.setString(_securityConfigKey, json.encode(_securityConfig!.toJson()));
    }
  }

  /// Authenticate user with biometrics
  Future<BiometricAuthResult> authenticateWithBiometrics({
    String reason = 'Please authenticate to access Flow Ai',
    bool requireBiometrics = true,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // Check if biometrics are enabled
      final bool biometricEnabled = _prefs?.getBool(_biometricEnabledKey) ?? false;
      if (!biometricEnabled && requireBiometrics) {
        return BiometricAuthResult(
          success: false,
          error: 'Biometric authentication not enabled',
          errorType: BiometricErrorType.notEnabled,
        );
      }

      // Check device capabilities
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        return BiometricAuthResult(
          success: false,
          error: 'Biometric authentication not available',
          errorType: BiometricErrorType.notAvailable,
        );
      }

      // Check for failed attempts
      if (await _isAccountLocked()) {
        return BiometricAuthResult(
          success: false,
          error: 'Account locked due to too many failed attempts',
          errorType: BiometricErrorType.accountLocked,
        );
      }

      // Perform authentication
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (authenticated) {
        await _handleSuccessfulAuth();
        return BiometricAuthResult(
          success: true,
          sessionToken: await _generateSessionToken(),
        );
      } else {
        await _handleFailedAuth();
        return BiometricAuthResult(
          success: false,
          error: 'Authentication failed',
          errorType: BiometricErrorType.authFailed,
        );
      }
    } on PlatformException catch (e) {
      await _handleFailedAuth();
      
      BiometricErrorType errorType;
      switch (e.code) {
        case 'NotAvailable':
          errorType = BiometricErrorType.notAvailable;
          break;
        case 'NotEnrolled':
          errorType = BiometricErrorType.notEnrolled;
          break;
        case 'LockedOut':
          errorType = BiometricErrorType.lockedOut;
          break;
        case 'PermanentlyLockedOut':
          errorType = BiometricErrorType.permanentlyLocked;
          break;
        default:
          errorType = BiometricErrorType.unknown;
      }

      return BiometricAuthResult(
        success: false,
        error: e.message ?? 'Biometric authentication error',
        errorType: errorType,
      );
    } catch (e) {
      await _handleFailedAuth();
      return BiometricAuthResult(
        success: false,
        error: 'Unexpected authentication error: $e',
        errorType: BiometricErrorType.unknown,
      );
    }
  }

  /// Enable or disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    if (!_isInitialized) await initialize();

    if (enabled) {
      // Test biometric authentication before enabling
      final result = await authenticateWithBiometrics(
        reason: 'Verify biometric authentication to enable this feature',
        requireBiometrics: false,
      );
      
      if (!result.success) {
        throw SecurityException('Cannot enable biometrics: ${result.error}');
      }
    }

    await _prefs?.setBool(_biometricEnabledKey, enabled);
    debugPrint('🔓 Biometric authentication ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Check if biometric authentication is enabled
  bool isBiometricEnabled() {
    return _prefs?.getBool(_biometricEnabledKey) ?? false;
  }

  /// Encrypt sensitive data
  Future<EncryptedData> encryptData(String data, {
    String? additionalContext,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      final IV iv = IV.fromSecureRandom(16);
      final Encrypted encrypted = _dataEncrypter.encrypt(data, iv: iv);
      
      final EncryptedData result = EncryptedData(
        encryptedContent: encrypted.base64,
        iv: iv.base64,
        algorithm: 'AES-256-CBC',
        timestamp: DateTime.now(),
        additionalContext: additionalContext,
      );

      debugPrint('🔐 Data encrypted successfully');
      return result;
    } catch (e) {
      debugPrint('❌ Failed to encrypt data: $e');
      throw SecurityException('Failed to encrypt data: $e');
    }
  }

  /// Decrypt sensitive data
  Future<String> decryptData(EncryptedData encryptedData) async {
    if (!_isInitialized) await initialize();

    try {
      final IV iv = IV.fromBase64(encryptedData.iv);
      final Encrypted encrypted = Encrypted.fromBase64(encryptedData.encryptedContent);
      
      final String decrypted = _dataEncrypter.decrypt(encrypted, iv: iv);
      
      debugPrint('🔓 Data decrypted successfully');
      return decrypted;
    } catch (e) {
      debugPrint('❌ Failed to decrypt data: $e');
      throw SecurityException('Failed to decrypt data: $e');
    }
  }

  /// Securely store encrypted health data
  Future<void> storeHealthData(String key, String data, {
    DataSensitivityLevel sensitivity = DataSensitivityLevel.high,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // Add metadata to data
      final Map<String, dynamic> dataWithMetadata = {
        'data': data,
        'sensitivity': sensitivity.name,
        'timestamp': DateTime.now().toIso8601String(),
        'checksum': _calculateChecksum(data),
      };

      final String dataStr = json.encode(dataWithMetadata);
      final EncryptedData encrypted = await encryptData(dataStr, additionalContext: key);
      
      await _prefs?.setString('encrypted_$key', json.encode(encrypted.toJson()));
      
      // Log access for audit trail
      await _logDataAccess(DataAccessType.write, key, sensitivity);
      
      debugPrint('💾 Health data stored securely: $key');
    } catch (e) {
      debugPrint('❌ Failed to store health data: $e');
      throw SecurityException('Failed to store health data: $e');
    }
  }

  /// Retrieve encrypted health data
  Future<String?> retrieveHealthData(String key, {
    bool requireAuth = true,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // Check authentication if required
      if (requireAuth && !await _isSessionValid()) {
        throw SecurityException('Authentication required to access health data');
      }

      final String? encryptedStr = _prefs?.getString('encrypted_$key');
      if (encryptedStr == null) return null;

      final Map<String, dynamic> encryptedJson = json.decode(encryptedStr);
      final EncryptedData encrypted = EncryptedData.fromJson(encryptedJson);
      
      final String decryptedStr = await decryptData(encrypted);
      final Map<String, dynamic> dataWithMetadata = json.decode(decryptedStr);
      
      // Verify data integrity
      final String data = dataWithMetadata['data'];
      final String storedChecksum = dataWithMetadata['checksum'];
      final String calculatedChecksum = _calculateChecksum(data);
      
      if (storedChecksum != calculatedChecksum) {
        throw SecurityException('Data integrity check failed');
      }

      // Log access for audit trail
      final DataSensitivityLevel sensitivity = DataSensitivityLevel.values
          .firstWhere((e) => e.name == dataWithMetadata['sensitivity']);
      await _logDataAccess(DataAccessType.read, key, sensitivity);
      
      debugPrint('📖 Health data retrieved securely: $key');
      return data;
    } catch (e) {
      debugPrint('❌ Failed to retrieve health data: $e');
      throw SecurityException('Failed to retrieve health data: $e');
    }
  }

  /// Delete encrypted health data
  Future<void> deleteHealthData(String key) async {
    if (!_isInitialized) await initialize();

    try {
      await _prefs?.remove('encrypted_$key');
      await _logDataAccess(DataAccessType.delete, key, DataSensitivityLevel.high);
      debugPrint('🗑️ Health data deleted securely: $key');
    } catch (e) {
      debugPrint('❌ Failed to delete health data: $e');
      throw SecurityException('Failed to delete health data: $e');
    }
  }

  /// Get privacy settings
  Future<PrivacySettings> getPrivacySettings() async {
    if (!_isInitialized) await initialize();

    try {
      final String? settingsStr = _prefs?.getString(_privacySettingsKey);
      if (settingsStr != null) {
        final Map<String, dynamic> settingsJson = json.decode(settingsStr);
        return PrivacySettings.fromJson(settingsJson);
      } else {
        return PrivacySettings.defaultSettings();
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load privacy settings, using defaults: $e');
      return PrivacySettings.defaultSettings();
    }
  }

  /// Update privacy settings
  Future<void> updatePrivacySettings(PrivacySettings settings) async {
    if (!_isInitialized) await initialize();

    try {
      await _prefs?.setString(_privacySettingsKey, json.encode(settings.toJson()));
      debugPrint('⚙️ Privacy settings updated');
    } catch (e) {
      debugPrint('❌ Failed to update privacy settings: $e');
      throw SecurityException('Failed to update privacy settings: $e');
    }
  }

  /// Get security audit log
  Future<List<SecurityAuditEntry>> getSecurityAuditLog({
    DateTime? since,
    int limit = 100,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      final List<String> auditEntries = _prefs?.getStringList('security_audit') ?? [];
      
      final List<SecurityAuditEntry> entries = auditEntries
          .map((entryStr) {
            try {
              final Map<String, dynamic> entryJson = json.decode(entryStr);
              return SecurityAuditEntry.fromJson(entryJson);
            } catch (e) {
              return null;
            }
          })
          .where((entry) => entry != null)
          .cast<SecurityAuditEntry>()
          .toList();

      // Filter by date if specified
      List<SecurityAuditEntry> filteredEntries = entries;
      if (since != null) {
        filteredEntries = entries.where((entry) => entry.timestamp.isAfter(since)).toList();
      }

      // Sort by timestamp (newest first) and limit
      filteredEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return filteredEntries.take(limit).toList();
    } catch (e) {
      debugPrint('❌ Failed to get security audit log: $e');
      return [];
    }
  }

  /// Generate secure backup of user data
  Future<SecureBackup> generateSecureBackup({
    required List<String> dataKeys,
    String? passphrase,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      final Map<String, String> backupData = {};
      
      // Collect all requested data
      for (final key in dataKeys) {
        final String? data = await retrieveHealthData(key, requireAuth: false);
        if (data != null) {
          backupData[key] = data;
        }
      }

      // Create backup metadata
      final BackupMetadata metadata = BackupMetadata(
        version: '1.0',
        createdAt: DateTime.now(),
        dataKeys: dataKeys,
        checksum: _calculateChecksum(json.encode(backupData)),
        encryptionMethod: 'AES-256-CBC',
      );

      // Encrypt backup data
      final String backupJson = json.encode({
        'metadata': metadata.toJson(),
        'data': backupData,
      });

      Key backupKey = _masterKey;
      if (passphrase != null) {
        // Use passphrase-derived key if provided
        backupKey = _deriveKeyFromPassphrase(passphrase);
      }

      final IV iv = IV.fromSecureRandom(16);
      final Encrypter backupEncrypter = Encrypter(AES(backupKey));
      final Encrypted encrypted = backupEncrypter.encrypt(backupJson, iv: iv);

      return SecureBackup(
        encryptedData: encrypted.base64,
        iv: iv.base64,
        metadata: metadata,
        isPassphraseProtected: passphrase != null,
      );
    } catch (e) {
      debugPrint('❌ Failed to generate secure backup: $e');
      throw SecurityException('Failed to generate secure backup: $e');
    }
  }

  /// Restore data from secure backup
  Future<BackupRestoreResult> restoreFromSecureBackup(
    SecureBackup backup, {
    String? passphrase,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      Key restoreKey = _masterKey;
      if (backup.isPassphraseProtected) {
        if (passphrase == null) {
          throw SecurityException('Passphrase required for backup restore');
        }
        restoreKey = _deriveKeyFromPassphrase(passphrase);
      }

      // Decrypt backup
      final IV iv = IV.fromBase64(backup.iv);
      final Encrypter restoreEncrypter = Encrypter(AES(restoreKey));
      final Encrypted encrypted = Encrypted.fromBase64(backup.encryptedData);
      
      final String decryptedJson = restoreEncrypter.decrypt(encrypted, iv: iv);
      final Map<String, dynamic> backupContent = json.decode(decryptedJson);
      
      // Verify backup integrity
      final Map<String, String> restoredData = Map<String, String>.from(backupContent['data']);
      final String calculatedChecksum = _calculateChecksum(json.encode(restoredData));
      
      if (calculatedChecksum != backup.metadata.checksum) {
        throw SecurityException('Backup integrity verification failed');
      }

      // Restore data
      int restoredCount = 0;
      final List<String> failedKeys = [];

      for (final entry in restoredData.entries) {
        try {
          await storeHealthData(entry.key, entry.value);
          restoredCount++;
        } catch (e) {
          failedKeys.add(entry.key);
          debugPrint('⚠️ Failed to restore key ${entry.key}: $e');
        }
      }

      return BackupRestoreResult(
        success: failedKeys.isEmpty,
        restoredCount: restoredCount,
        failedKeys: failedKeys,
        totalKeys: restoredData.length,
      );
    } catch (e) {
      debugPrint('❌ Failed to restore from backup: $e');
      throw SecurityException('Failed to restore from backup: $e');
    }
  }

  /// Security helper methods
  Future<bool> _isSessionValid() async {
    final String? sessionToken = _prefs?.getString(_sessionTokenKey);
    final int? lastAuth = _prefs?.getInt(_lastAuthKey);
    
    if (sessionToken == null || lastAuth == null) return false;
    
    final DateTime lastAuthTime = DateTime.fromMillisecondsSinceEpoch(lastAuth);
    final Duration elapsed = DateTime.now().difference(lastAuthTime);
    
    return elapsed.inMinutes <= _sessionTimeoutMinutes;
  }

  Future<String> _generateSessionToken() async {
    final String token = _generateSecureToken();
    await _prefs?.setString(_sessionTokenKey, token);
    await _prefs?.setInt(_lastAuthKey, DateTime.now().millisecondsSinceEpoch);
    return token;
  }

  String _generateSecureToken() {
    final Random random = math.Random.secure();
    final List<int> bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Encode(bytes);
  }

  String _calculateChecksum(String data) {
    final List<int> bytes = utf8.encode(data);
    final Digest digest = sha256.convert(bytes);
    return digest.toString();
  }

  Key _deriveKeyFromPassphrase(String passphrase) {
    final List<int> passphraseBytes = utf8.encode(passphrase);
    final Digest digest = sha256.convert(passphraseBytes);
    return Key(Uint8List.fromList(digest.bytes));
  }

  Future<void> _handleSuccessfulAuth() async {
    await _prefs?.remove('failed_auth_count');
    await _prefs?.remove('lockout_timestamp');
  }

  Future<void> _handleFailedAuth() async {
    final int failedCount = (_prefs?.getInt('failed_auth_count') ?? 0) + 1;
    await _prefs?.setInt('failed_auth_count', failedCount);
    
    if (failedCount >= _maxFailedAttempts) {
      final int lockoutTime = DateTime.now().add(Duration(minutes: _lockoutDurationMinutes)).millisecondsSinceEpoch;
      await _prefs?.setInt('lockout_timestamp', lockoutTime);
    }

    await _logSecurityEvent(SecurityEventType.authFailed, 'Failed authentication attempt #$failedCount');
  }

  Future<bool> _isAccountLocked() async {
    final int? lockoutTime = _prefs?.getInt('lockout_timestamp');
    if (lockoutTime == null) return false;
    
    return DateTime.now().millisecondsSinceEpoch < lockoutTime;
  }

  Future<void> _logDataAccess(DataAccessType accessType, String key, DataSensitivityLevel sensitivity) async {
    final SecurityAuditEntry entry = SecurityAuditEntry(
      id: _generateSecureToken(),
      timestamp: DateTime.now(),
      eventType: SecurityEventType.dataAccess,
      description: '${accessType.name.toUpperCase()} access to $key (${sensitivity.name})',
      severity: SecuritySeverity.info,
      additionalData: {
        'access_type': accessType.name,
        'data_key': key,
        'sensitivity': sensitivity.name,
      },
    );

    await _addAuditEntry(entry);
  }

  Future<void> _logSecurityEvent(SecurityEventType eventType, String description, {
    SecuritySeverity severity = SecuritySeverity.warning,
    Map<String, dynamic>? additionalData,
  }) async {
    final SecurityAuditEntry entry = SecurityAuditEntry(
      id: _generateSecureToken(),
      timestamp: DateTime.now(),
      eventType: eventType,
      description: description,
      severity: severity,
      additionalData: additionalData,
    );

    await _addAuditEntry(entry);
  }

  Future<void> _addAuditEntry(SecurityAuditEntry entry) async {
    try {
      final List<String> auditEntries = _prefs?.getStringList('security_audit') ?? [];
      auditEntries.add(json.encode(entry.toJson()));
      
      // Keep only recent entries (last 1000)
      if (auditEntries.length > 1000) {
        auditEntries.removeRange(0, auditEntries.length - 1000);
      }
      
      await _prefs?.setStringList('security_audit', auditEntries);
    } catch (e) {
      debugPrint('⚠️ Failed to log audit entry: $e');
    }
  }

  /// Clear all security data (use with caution)
  Future<void> clearAllSecurityData() async {
    if (!_isInitialized) await initialize();

    try {
      // Clear encryption keys
      await _prefs?.remove(_masterKeyAlias);
      
      // Clear session data
      await _prefs?.remove(_sessionTokenKey);
      await _prefs?.remove(_lastAuthKey);
      
      // Clear settings
      await _prefs?.remove(_biometricEnabledKey);
      await _prefs?.remove(_privacySettingsKey);
      await _prefs?.remove(_securityConfigKey);
      
      // Clear audit log
      await _prefs?.remove('security_audit');
      
      // Clear all encrypted health data
      final Set<String> allKeys = _prefs?.getKeys() ?? {};
      for (final key in allKeys) {
        if (key.startsWith('encrypted_')) {
          await _prefs?.remove(key);
        }
      }
      
      debugPrint('🧹 All security data cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear security data: $e');
      throw SecurityException('Failed to clear security data: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _isInitialized = false;
  }
}

// === ENUMS ===

enum DataSensitivityLevel {
  low,
  medium,
  high,
  critical,
}

enum DataAccessType {
  read,
  write,
  delete,
  export,
}

enum SecurityEventType {
  authSuccess,
  authFailed,
  dataAccess,
  configChange,
  backupCreated,
  backupRestored,
  securityViolation,
}

enum SecuritySeverity {
  info,
  warning,
  error,
  critical,
}

enum BiometricErrorType {
  notAvailable,
  notEnabled,
  notEnrolled,
  authFailed,
  accountLocked,
  lockedOut,
  permanentlyLocked,
  unknown,
}

// === DATA MODELS ===

class SecurityConfig {
  final bool encryptionEnabled;
  final bool biometricRequired;
  final int sessionTimeoutMinutes;
  final int maxFailedAttempts;
  final int lockoutDurationMinutes;
  final bool auditLoggingEnabled;
  final DataSensitivityLevel defaultSensitivity;

  SecurityConfig({
    required this.encryptionEnabled,
    required this.biometricRequired,
    required this.sessionTimeoutMinutes,
    required this.maxFailedAttempts,
    required this.lockoutDurationMinutes,
    required this.auditLoggingEnabled,
    required this.defaultSensitivity,
  });

  factory SecurityConfig.defaultConfig() {
    return SecurityConfig(
      encryptionEnabled: true,
      biometricRequired: false,
      sessionTimeoutMinutes: 15,
      maxFailedAttempts: 5,
      lockoutDurationMinutes: 30,
      auditLoggingEnabled: true,
      defaultSensitivity: DataSensitivityLevel.high,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'encryption_enabled': encryptionEnabled,
      'biometric_required': biometricRequired,
      'session_timeout_minutes': sessionTimeoutMinutes,
      'max_failed_attempts': maxFailedAttempts,
      'lockout_duration_minutes': lockoutDurationMinutes,
      'audit_logging_enabled': auditLoggingEnabled,
      'default_sensitivity': defaultSensitivity.name,
    };
  }

  factory SecurityConfig.fromJson(Map<String, dynamic> json) {
    return SecurityConfig(
      encryptionEnabled: json['encryption_enabled'] ?? true,
      biometricRequired: json['biometric_required'] ?? false,
      sessionTimeoutMinutes: json['session_timeout_minutes'] ?? 15,
      maxFailedAttempts: json['max_failed_attempts'] ?? 5,
      lockoutDurationMinutes: json['lockout_duration_minutes'] ?? 30,
      auditLoggingEnabled: json['audit_logging_enabled'] ?? true,
      defaultSensitivity: DataSensitivityLevel.values
          .firstWhere((e) => e.name == json['default_sensitivity'], 
          orElse: () => DataSensitivityLevel.high),
    );
  }
}

class PrivacySettings {
  final bool allowAnalytics;
  final bool allowCrashReporting;
  final bool allowUsageTracking;
  final bool shareWithHealthProviders;
  final bool allowBackupToCloud;
  final bool allowDataExport;
  final Map<String, bool> dataTypesSharing;

  PrivacySettings({
    required this.allowAnalytics,
    required this.allowCrashReporting,
    required this.allowUsageTracking,
    required this.shareWithHealthProviders,
    required this.allowBackupToCloud,
    required this.allowDataExport,
    required this.dataTypesSharing,
  });

  factory PrivacySettings.defaultSettings() {
    return PrivacySettings(
      allowAnalytics: false,
      allowCrashReporting: true,
      allowUsageTracking: false,
      shareWithHealthProviders: false,
      allowBackupToCloud: false,
      allowDataExport: true,
      dataTypesSharing: {
        'cycle_data': false,
        'mood_data': false,
        'symptom_data': false,
        'biometric_data': false,
        'general_health': false,
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allow_analytics': allowAnalytics,
      'allow_crash_reporting': allowCrashReporting,
      'allow_usage_tracking': allowUsageTracking,
      'share_with_health_providers': shareWithHealthProviders,
      'allow_backup_to_cloud': allowBackupToCloud,
      'allow_data_export': allowDataExport,
      'data_types_sharing': dataTypesSharing,
    };
  }

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      allowAnalytics: json['allow_analytics'] ?? false,
      allowCrashReporting: json['allow_crash_reporting'] ?? true,
      allowUsageTracking: json['allow_usage_tracking'] ?? false,
      shareWithHealthProviders: json['share_with_health_providers'] ?? false,
      allowBackupToCloud: json['allow_backup_to_cloud'] ?? false,
      allowDataExport: json['allow_data_export'] ?? true,
      dataTypesSharing: Map<String, bool>.from(json['data_types_sharing'] ?? {}),
    );
  }
}

class EncryptedData {
  final String encryptedContent;
  final String iv;
  final String algorithm;
  final DateTime timestamp;
  final String? additionalContext;

  EncryptedData({
    required this.encryptedContent,
    required this.iv,
    required this.algorithm,
    required this.timestamp,
    this.additionalContext,
  });

  Map<String, dynamic> toJson() {
    return {
      'encrypted_content': encryptedContent,
      'iv': iv,
      'algorithm': algorithm,
      'timestamp': timestamp.toIso8601String(),
      'additional_context': additionalContext,
    };
  }

  factory EncryptedData.fromJson(Map<String, dynamic> json) {
    return EncryptedData(
      encryptedContent: json['encrypted_content'],
      iv: json['iv'],
      algorithm: json['algorithm'],
      timestamp: DateTime.parse(json['timestamp']),
      additionalContext: json['additional_context'],
    );
  }
}

class BiometricAuthResult {
  final bool success;
  final String? error;
  final BiometricErrorType? errorType;
  final String? sessionToken;

  BiometricAuthResult({
    required this.success,
    this.error,
    this.errorType,
    this.sessionToken,
  });
}

class SecurityAuditEntry {
  final String id;
  final DateTime timestamp;
  final SecurityEventType eventType;
  final String description;
  final SecuritySeverity severity;
  final Map<String, dynamic>? additionalData;

  SecurityAuditEntry({
    required this.id,
    required this.timestamp,
    required this.eventType,
    required this.description,
    required this.severity,
    this.additionalData,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'event_type': eventType.name,
      'description': description,
      'severity': severity.name,
      'additional_data': additionalData,
    };
  }

  factory SecurityAuditEntry.fromJson(Map<String, dynamic> json) {
    return SecurityAuditEntry(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      eventType: SecurityEventType.values
          .firstWhere((e) => e.name == json['event_type']),
      description: json['description'],
      severity: SecuritySeverity.values
          .firstWhere((e) => e.name == json['severity']),
      additionalData: json['additional_data'],
    );
  }
}

class SecureBackup {
  final String encryptedData;
  final String iv;
  final BackupMetadata metadata;
  final bool isPassphraseProtected;

  SecureBackup({
    required this.encryptedData,
    required this.iv,
    required this.metadata,
    required this.isPassphraseProtected,
  });
}

class BackupMetadata {
  final String version;
  final DateTime createdAt;
  final List<String> dataKeys;
  final String checksum;
  final String encryptionMethod;

  BackupMetadata({
    required this.version,
    required this.createdAt,
    required this.dataKeys,
    required this.checksum,
    required this.encryptionMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'created_at': createdAt.toIso8601String(),
      'data_keys': dataKeys,
      'checksum': checksum,
      'encryption_method': encryptionMethod,
    };
  }

  factory BackupMetadata.fromJson(Map<String, dynamic> json) {
    return BackupMetadata(
      version: json['version'],
      createdAt: DateTime.parse(json['created_at']),
      dataKeys: List<String>.from(json['data_keys']),
      checksum: json['checksum'],
      encryptionMethod: json['encryption_method'],
    );
  }
}

class BackupRestoreResult {
  final bool success;
  final int restoredCount;
  final List<String> failedKeys;
  final int totalKeys;

  BackupRestoreResult({
    required this.success,
    required this.restoredCount,
    required this.failedKeys,
    required this.totalKeys,
  });
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}
