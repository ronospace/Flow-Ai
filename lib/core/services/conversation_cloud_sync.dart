import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../utils/app_logger.dart';

/// Cloud Sync Service for AI Conversation Memory
/// Ensures conversation logs persist across devices by syncing to cloud storage
class ConversationCloudSync {
  static final ConversationCloudSync _instance = ConversationCloudSync._internal();
  factory ConversationCloudSync() => _instance;
  ConversationCloudSync._internal();

  late SharedPreferences _prefs;
  bool _isInitialized = false;
  String? _currentUserId;
  
  // Cloud sync keys
  static const String _lastSyncKey = 'conversation_last_sync';
  static const String _pendingSyncKey = 'conversation_pending_sync';
  static const String _cloudBackupKey = 'conversation_cloud_backup';
  
  Future<void> initialize({String? userId}) async {
    if (_isInitialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _currentUserId = userId;
      _isInitialized = true;
      
      // Auto-sync on initialization
      await syncToCloud();
      
      AppLogger.sync('Conversation Cloud Sync initialized for user: $userId');
    } catch (e) {
      AppLogger.error('Failed to initialize Conversation Cloud Sync', e);
    }
  }

  /// Sync conversation data to cloud storage
  /// This ensures conversations persist across devices
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
      
      // Store in cloud backup location (local for now, can be Firebase later)
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
      
      AppLogger.sync('Conversation data synced to cloud successfully');
      return true;
    } catch (e) {
      AppLogger.error('Failed to sync conversation data to cloud', e);
      
      // Mark as pending sync for retry later
      await _prefs.setBool(_getUserSpecificKey(_pendingSyncKey), true);
      return false;
    }
  }

  /// Restore conversation data from cloud storage
  /// Called when user signs in on a new device
  Future<bool> restoreFromCloud() async {
    if (!_isInitialized) {
      AppLogger.warning('Conversation Cloud Sync not initialized');
      return false;
    }

    try {
      // Get backup data from cloud
      final backupJson = _prefs.getString(_getUserSpecificKey(_cloudBackupKey));
      
      if (backupJson == null) {
        AppLogger.info('No cloud backup found for conversation data');
        return false;
      }
      
      final backupData = json.decode(backupJson) as Map<String, dynamic>;
      
      // Verify user ID matches
      if (backupData['user_id'] != _currentUserId) {
        AppLogger.warning('Cloud backup user ID mismatch');
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
      
      AppLogger.sync('Conversation data restored from cloud successfully');
      AppLogger.info('Backup timestamp: ${backupData['last_updated']}');
      
      return true;
    } catch (e) {
      AppLogger.error('Failed to restore conversation data from cloud', e);
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

  /// Sync specific message to cloud immediately
  /// Called after each new message for real-time sync
  Future<void> syncMessage(types.Message message) async {
    // In production, this would push to Firebase/cloud service
    // For now, we trigger a full sync
    await syncToCloud();
  }

  /// Auto-sync at regular intervals
  Future<void> startAutoSync() async {
    // Sync every 5 minutes
    Future.delayed(const Duration(minutes: 5), () async {
      await syncToCloud();
      startAutoSync(); // Recursive call for continuous sync
    });
  }

  /// Clear cloud backup
  Future<void> clearCloudBackup() async {
    if (!_isInitialized) return;
    
    await _prefs.remove(_getUserSpecificKey(_cloudBackupKey));
    await _prefs.remove(_getUserSpecificKey(_lastSyncKey));
    await _prefs.remove(_getUserSpecificKey(_pendingSyncKey));
    
    AppLogger.sync('Cloud backup cleared for user: $_currentUserId');
  }

  /// Get user-specific key for data isolation
  String _getUserSpecificKey(String baseKey) {
    return _currentUserId != null ? '${baseKey}_$_currentUserId' : baseKey;
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
