import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _preferencesKey = 'user_preferences';
  
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
        return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
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

  // Update display name
  Future<void> updateDisplayName(String name) async {
    _preferences = _preferences.copyWith(
      displayName: name,
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
}
