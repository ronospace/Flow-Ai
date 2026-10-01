import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../utils/app_logger.dart';

/// Device-local backup service for AI Conversation Memory.
///
/// This service does not perform remote or cross-device synchronization.
/// It maintains account-scoped backup state in local SharedPreferences only.
class ConversationCloudSync {
  static final ConversationCloudSync _instance =
      ConversationCloudSync._internal();
  factory ConversationCloudSync() => _instance;
  ConversationCloudSync._internal();

  late SharedPreferences _prefs;
  bool _isInitialized = false;
  String? _currentUserId;
  Timer? _autoSyncTimer;

  // Legacy persisted key names retained for backward compatibility.
  static const String _lastSyncKey = 'conversation_last_sync';
  static const String _pendingSyncKey = 'conversation_pending_sync';
  static const String _cloudBackupKey = 'conversation_cloud_backup';

  Future<void> initialize({String? userId}) async {
    final normalizedUserId = userId?.trim();
    if (normalizedUserId == null || normalizedUserId.isEmpty) {
      throw StateError(
        'Conversation cloud sync requires an authenticated user ID.',
      );
    }

    try {
      _prefs = await SharedPreferences.getInstance();

      if (_isInitialized && _currentUserId == normalizedUserId) {
        return;
      }

      _autoSyncTimer?.cancel();
      _autoSyncTimer = null;
      _currentUserId = normalizedUserId;
      _isInitialized = true;

      await syncToCloud();

      AppLogger.sync('Conversation local backup initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize Conversation Cloud Sync', e);
      rethrow;
    }
  }

  /// Refresh the device-local account-scoped conversation backup.
  Future<bool> syncToCloud() async {
    if (!_isInitialized) {
      AppLogger.warning('Conversation Cloud Sync not initialized');
      return false;
    }

    try {
      // Get conversation data from local storage
      final conversationKey = _getUserSpecificKey('ai_conversation_history');
      final preferencesKey = _getUserSpecificKey('ai_user_preferences');
      final topicsKey = _getUserSpecificKey('ai_topics_interest');
      final questionsKey = _getUserSpecificKey('ai_frequent_questions');
      final insightsKey = _getUserSpecificKey('ai_personalized_insights');

      final conversationData = _prefs.getString(conversationKey);
      final preferencesData = _prefs.getString(preferencesKey);
      final topicsData = _prefs.getString(topicsKey);
      final questionsData = _prefs.getString(questionsKey);
      final insightsData = _prefs.getString(insightsKey);

      // Create backup bundle
      final backupData = {
        'conversation_history': conversationData,
        'user_preferences': preferencesData,
        'topics_interest': topicsData,
        'frequent_questions': questionsData,
        'personalized_insights': insightsData,
        'last_updated': DateTime.now().toIso8601String(),
        'user_id': _currentUserId,
      };

      // Store only in this device's local preferences.
      await _prefs.setString(
        _getUserSpecificKey(_cloudBackupKey),
        json.encode(backupData),
      );

      // Update last sync timestamp
      await _prefs.setString(
        _getUserSpecificKey(_lastSyncKey),
        DateTime.now().toIso8601String(),
      );

      // Clear pending sync flag
      await _prefs.remove(_getUserSpecificKey(_pendingSyncKey));

      AppLogger.sync('Conversation data backed up locally');
      return true;
    } catch (e) {
      AppLogger.error('Failed to back up conversation data locally', e);

      // Mark as pending sync for retry later
      await _prefs.setBool(_getUserSpecificKey(_pendingSyncKey), true);
      return false;
    }
  }

  /// Restore conversation data from the account-scoped local backup.
  Future<bool> restoreFromCloud() async {
    if (!_isInitialized) {
      AppLogger.warning('Conversation Cloud Sync not initialized');
      return false;
    }

    try {
      // Read the device-local account-scoped backup.
      final backupJson = _prefs.getString(_getUserSpecificKey(_cloudBackupKey));

      if (backupJson == null) {
        AppLogger.info('No local conversation backup found');
        return false;
      }

      final backupData = json.decode(backupJson) as Map<String, dynamic>;

      // Verify user ID matches
      if (backupData['user_id'] != _currentUserId) {
        AppLogger.warning('Local backup user ID mismatch');
        return false;
      }

      // Restore conversation history
      if (backupData['conversation_history'] != null) {
        await _prefs.setString(
          _getUserSpecificKey('ai_conversation_history'),
          backupData['conversation_history'],
        );
      }

      // Restore user preferences
      if (backupData['user_preferences'] != null) {
        await _prefs.setString(
          _getUserSpecificKey('ai_user_preferences'),
          backupData['user_preferences'],
        );
      }

      // Restore topics of interest
      if (backupData['topics_interest'] != null) {
        await _prefs.setString(
          _getUserSpecificKey('ai_topics_interest'),
          backupData['topics_interest'],
        );
      }

      // Restore frequent questions
      if (backupData['frequent_questions'] != null) {
        await _prefs.setString(
          _getUserSpecificKey('ai_frequent_questions'),
          backupData['frequent_questions'],
        );
      }

      // Restore personalized insights
      if (backupData['personalized_insights'] != null) {
        await _prefs.setString(
          _getUserSpecificKey('ai_personalized_insights'),
          backupData['personalized_insights'],
        );
      }

      AppLogger.sync('Conversation data restored from local backup');
      AppLogger.info('Backup timestamp: ${backupData['last_updated']}');

      return true;
    } catch (e) {
      AppLogger.error('Failed to restore conversation data from local backup', e);
      return false;
    }
  }

  /// Check if there's pending sync data
  Future<bool> hasPendingSync() async {
    if (!_isInitialized) return false;
    return _prefs.getBool(_getUserSpecificKey(_pendingSyncKey)) ?? false;
  }

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    if (!_isInitialized) return null;

    final syncTimeStr = _prefs.getString(_getUserSpecificKey(_lastSyncKey));
    if (syncTimeStr == null) return null;

    try {
      return DateTime.parse(syncTimeStr);
    } catch (e) {
      return null;
    }
  }

  /// Refresh the local backup after each new message.
  Future<void> syncMessage(types.Message message) async {
    // Refresh the device-local backup.
    await syncToCloud();
  }

  /// Refresh the device-local backup at regular intervals.
  Future<void> startAutoSync() async {
    if (!_isInitialized || _currentUserId == null) return;
    if (_autoSyncTimer?.isActive ?? false) return;

    _autoSyncTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      if (_isInitialized && _currentUserId != null) {
        await syncToCloud();
      }
    });
  }

  /// Detach the active account without deleting its persisted backup.
  Future<void> resetSession() async {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    _currentUserId = null;
    _isInitialized = false;
  }

  /// Clear this account's device-local backup.
  Future<void> clearCloudBackup() async {
    if (!_isInitialized) return;

    await _prefs.remove(_getUserSpecificKey(_cloudBackupKey));
    await _prefs.remove(_getUserSpecificKey(_lastSyncKey));
    await _prefs.remove(_getUserSpecificKey(_pendingSyncKey));

    AppLogger.sync('Local conversation backup cleared for user: $_currentUserId');
  }

  /// Get user-specific key for data isolation
  String _getUserSpecificKey(String baseKey) {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      throw StateError(
        'Conversation cloud sync cannot access unscoped user data.',
      );
    }
    return '${baseKey}_$userId';
  }

  /// Get sync status for UI display
  Future<Map<String, dynamic>> getSyncStatus() async {
    final lastSync = await getLastSyncTime();
    final hasPending = await hasPendingSync();

    return {
      'is_synced': !hasPending && lastSync != null,
      'last_sync': lastSync?.toIso8601String(),
      'pending_sync': hasPending,
      'sync_enabled': _isInitialized,
    };
  }
}
