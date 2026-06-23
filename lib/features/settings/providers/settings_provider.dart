import 'package:flow_ai/core/services/auth_service.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_preferences.dart';
import '../../../core/services/app_state_service.dart';
import 'package:flow_ai/core/utils/user_display_name_resolver.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _preferencesKey = 'user_preferences';
  static const String _userMetadataKey = 'user_metadata';

  UserPreferences _preferences = UserPreferences(
    userId: 'default_user',
    lastUpdated: DateTime.now(),
  );

  UserPreferences get preferences => _preferences;

  bool get isDarkMode {
    switch (_preferences.themeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    }
  }

  ThemeMode get themeMode {
    switch (_preferences.themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  Locale get locale => _preferences.language.locale;

  // Initialize settings from storage
  Future<void> initializeSettings() async {
    await _loadPreferences();

    final appState = AppStateService();
    if (!appState.isInitialized) {
      await appState.initialize();
    }

    final existingUser = await appState.auth.getUserData();
    if (existingUser == null) {
      debugPrint("🆕 Creating initial local user");
      await appState.auth.signUpWithEmail(
        email: "local.ai",
        password: "password123",
        displayName:
            (await appState.auth.getUserData())?["email"]?.split("@")[0] ??
            "User",
      );
    }
    await _syncUserDataFromAuth();
  }

  // Sync authenticated identity into profile and greeting preferences.
  Future<void> _syncUserDataFromAuth() async {
    try {
      final appState = AppStateService();
      if (!appState.isInitialized) {
        await appState.initialize();
      }
      final userData = await appState.auth.getUserData();

      if (userData == null) {
        debugPrint('⚠️ No user data found in AuthService');
        return;
      }

      final uid = (userData['uid'] as String?)?.trim() ?? '';
      final email = userData['email'] as String?;
      final photoUrl = (userData['photoURL'] as String?)?.trim() ?? '';
      final identity = UserDisplayNameResolver.resolveIdentity(
        userId: uid,
        email: email,
        displayName: userData['displayName'] as String?,
        existingUserId: _preferences.userId,
        existingDisplayName: _preferences.displayName,
      );
      final sameUser = uid.isNotEmpty && uid == _preferences.userId;
      final resolvedAvatarUrl = photoUrl.isNotEmpty
          ? photoUrl
          : sameUser
          ? _preferences.avatarUrl
          : '';
      final resolvedUserId = uid.isNotEmpty ? uid : _preferences.userId;

      final hasChanges =
          _preferences.userId != resolvedUserId ||
          _preferences.displayName != identity.displayName ||
          _preferences.greetingName != identity.greetingName ||
          _preferences.avatarUrl != resolvedAvatarUrl;

      if (!hasChanges) {
        debugPrint('ℹ️ No user identity changes detected');
        return;
      }

      _preferences = _preferences.copyWith(
        userId: resolvedUserId,
        displayName: identity.displayName,
        greetingName: identity.greetingName,
        avatarUrl: resolvedAvatarUrl,
        lastUpdated: DateTime.now(),
      );

      await storeUserMetadata({
        'email': email,
        'photoURL': resolvedAvatarUrl,
        'provider': userData['provider'],
        'profileComplete': userData['profileComplete'] ?? true,
        'lastSync': DateTime.now().toIso8601String(),
        'displayName': identity.displayName,
        'greetingName': identity.greetingName,
        'uid': resolvedUserId,
      });
      await _savePreferences();
      notifyListeners();
      debugPrint('✅ User identity sync completed successfully');
    } catch (e) {
      debugPrint('❌ Error syncing user data from auth: $e');
    }
  }

  /// Force user data synchronization - called after authentication
  Future<void> forceUserDataSync() async {
    debugPrint('🔄 Forcing user data sync...');
    await _syncUserDataFromAuth();
  }

  // Load preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferencesJson = prefs.getString(_preferencesKey);

      if (preferencesJson != null) {
        final json = jsonDecode(preferencesJson) as Map<String, dynamic>;
        _preferences = UserPreferences.fromJson(json);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  // Save preferences to SharedPreferences
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferencesJson = jsonEncode(_preferences.toJson());
      await prefs.setString(_preferencesKey, preferencesJson);
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    }
  }

  // Update the canonical profile name and its short greeting name together.
  Future<void> updateDisplayName(String name) async {
    final displayName = UserDisplayNameResolver.normalizeDisplayName(name);
    if (displayName.isEmpty) {
      return;
    }

    _preferences = _preferences.copyWith(
      displayName: displayName,
      greetingName: UserDisplayNameResolver.firstNameFromDisplayName(
        displayName,
      ),
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _savePreferences();
  }

  // Update theme mode
  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    _preferences = _preferences.copyWith(
      themeMode: themeMode,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _savePreferences();
  }

  // Update language
  Future<void> updateLanguage(AppLanguage language) async {
    _preferences = _preferences.copyWith(
      language: language,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _savePreferences();
  }

  // Update notifications settings
  Future<void> updateNotificationsEnabled(bool enabled) async {
    _preferences = _preferences.copyWith(
      notificationsEnabled: enabled,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _savePreferences();
  }

  Future<void> updateNotificationTime(TimeOfDay time) async {
    _preferences = _preferences.copyWith(
      notificationTime: time,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _savePreferences();
  }

  // Update reminder settings
  Future<void> updatePeriodReminders(bool enabled) async {
    _preferences = _preferences.copyWith(
      periodReminders: enabled,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _savePreferences();
  }

  Future<void> updateOvulationReminders(bool enabled) async {
    _preferences = _preferences.copyWith(
      ovulationReminders: enabled,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _savePreferences();
  }

  Future<void> updateSymptomReminders(bool enabled) async {
    _preferences = _preferences.copyWith(
      symptomReminders: enabled,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _savePreferences();
  }

  Future<void> updateReminderDaysBefore(int days) async {
    _preferences = _preferences.copyWith(
      reminderDaysBefore: days,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _savePreferences();
  }

  // Update app features
  Future<void> updateAiInsightsEnabled(bool enabled) async {
    _preferences = _preferences.copyWith(
      aiInsightsEnabled: enabled,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _savePreferences();
  }

  Future<void> updateHapticFeedbackEnabled(bool enabled) async {
    _preferences = _preferences.copyWith(
      hapticFeedbackEnabled: enabled,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _savePreferences();
  }

  Future<void> updateSoundsEnabled(bool enabled) async {
    _preferences = _preferences.copyWith(
      soundsEnabled: enabled,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _savePreferences();
  }

  // Update privacy settings
  Future<void> updatePrivacyMode(bool enabled) async {
    _preferences = _preferences.copyWith(
      privacyMode: enabled,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _savePreferences();
  }

  Future<void> updateBiometricAuth(bool enabled) async {
    _preferences = _preferences.copyWith(
      biometricAuth: enabled,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _savePreferences();
    final auth = AuthService();
    await auth.setBiometricEnabled(enabled);
  }

  // Update CycleSync integration
  Future<void> updateCycleSyncIntegration(bool enabled, String? userId) async {
    _preferences = _preferences.copyWith(
      syncWithCycleSync: enabled,
      cycleSyncUserId: userId,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _savePreferences();
  }

  // Update avatar
  Future<void> updateAvatar(String avatarUrl) async {
    _preferences = _preferences.copyWith(
      avatarUrl: avatarUrl,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _savePreferences();
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    _preferences = UserPreferences(
      userId: _preferences.userId,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _savePreferences();
  }

  // Export settings
  Map<String, dynamic> exportSettings() {
    return _preferences.toJson();
  }

  // Import settings
  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      _preferences = UserPreferences.fromJson(settings);
      notifyListeners();
      await _savePreferences();
    } catch (e) {
      debugPrint('Error importing settings: $e');
    }
  }

  // Store additional user metadata
  Future<void> storeUserMetadata(Map<String, dynamic> metadata) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userMetadataKey, jsonEncode(metadata));
      debugPrint('📝 User metadata stored: ${metadata.keys}');
    } catch (e) {
      debugPrint('Error storing user metadata: $e');
    }
  }

  // Retrieve user metadata
  Future<Map<String, dynamic>?> getUserMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadataJson = prefs.getString(_userMetadataKey);
      if (metadataJson != null) {
        return Map<String, dynamic>.from(jsonDecode(metadataJson));
      }
    } catch (e) {
      debugPrint('Error retrieving user metadata: $e');
    }
    return null;
  }
}
