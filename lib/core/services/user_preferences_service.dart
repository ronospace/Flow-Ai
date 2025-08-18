import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

/// Service for managing user preferences and settings
class UserPreferencesService {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguageCode = 'language_code';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyBiometrics = 'biometrics_enabled';
  static const String _keyUserProfile = 'user_profile';
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyPrivacySettings = 'privacy_settings';
  static const String _keyHealthGoals = 'health_goals';
  static const String _keyReminderSettings = 'reminder_settings';
  
  late SharedPreferences _prefs;

  /// Initialize the preferences service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Theme settings
  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'system';
  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }

  // Language settings
  String get languageCode => _prefs.getString(_keyLanguageCode) ?? 'en';
  Future<void> setLanguageCode(String code) async {
    await _prefs.setString(_keyLanguageCode, code);
  }

  // Notification settings
  bool get notificationsEnabled => _prefs.getBool(_keyNotifications) ?? true;
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_keyNotifications, enabled);
  }

  // Biometric settings
  bool get biometricsEnabled => _prefs.getBool(_keyBiometrics) ?? false;
  Future<void> setBiometricsEnabled(bool enabled) async {
    await _prefs.setBool(_keyBiometrics, enabled);
  }

  // Onboarding status
  bool get onboardingComplete => _prefs.getBool(_keyOnboardingComplete) ?? false;
  Future<void> setOnboardingComplete(bool complete) async {
    await _prefs.setBool(_keyOnboardingComplete, complete);
  }

  // User profile
  UserProfile? get userProfile {
    final jsonString = _prefs.getString(_keyUserProfile);
    if (jsonString == null) return null;
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserProfile.fromMap(map);
    } catch (e) {
      return null;
    }
  }

  Future<void> setUserProfile(UserProfile profile) async {
    final jsonString = jsonEncode(profile.toMap());
    await _prefs.setString(_keyUserProfile, jsonString);
  }

  // Privacy settings
  Map<String, bool> get privacySettings {
    final jsonString = _prefs.getString(_keyPrivacySettings);
    if (jsonString == null) {
      return {
        'shareWithPartner': false,
        'anonymousAnalytics': true,
        'dataExport': true,
        'cloudSync': false,
      };
    }
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return map.map((key, value) => MapEntry(key, value as bool));
    } catch (e) {
      return {
        'shareWithPartner': false,
        'anonymousAnalytics': true,
        'dataExport': true,
        'cloudSync': false,
      };
    }
  }

  Future<void> setPrivacySettings(Map<String, bool> settings) async {
    final jsonString = jsonEncode(settings);
    await _prefs.setString(_keyPrivacySettings, jsonString);
  }

  // Health goals
  Map<String, dynamic> get healthGoals {
    final jsonString = _prefs.getString(_keyHealthGoals);
    if (jsonString == null) {
      return {
        'water': {'target': 8, 'enabled': true},
        'exercise': {'target': 30, 'enabled': true},
        'sleep': {'target': 8, 'enabled': true},
        'meditation': {'target': 10, 'enabled': false},
      };
    }
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return {
        'water': {'target': 8, 'enabled': true},
        'exercise': {'target': 30, 'enabled': true},
        'sleep': {'target': 8, 'enabled': true},
        'meditation': {'target': 10, 'enabled': false},
      };
    }
  }

  Future<void> setHealthGoals(Map<String, dynamic> goals) async {
    final jsonString = jsonEncode(goals);
    await _prefs.setString(_keyHealthGoals, jsonString);
  }

  // Reminder settings
  Map<String, dynamic> get reminderSettings {
    final jsonString = _prefs.getString(_keyReminderSettings);
    if (jsonString == null) {
      return {
        'periodReminder': {'enabled': true, 'daysBefore': 1},
        'ovulationReminder': {'enabled': true, 'daysBefore': 1},
        'pmsReminder': {'enabled': true, 'daysBefore': 3},
        'symptomReminder': {'enabled': true, 'time': '21:00'},
        'medicationReminder': {'enabled': false, 'times': []},
        'wellnessCheck': {'enabled': true, 'frequency': 'weekly'},
      };
    }
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return {
        'periodReminder': {'enabled': true, 'daysBefore': 1},
        'ovulationReminder': {'enabled': true, 'daysBefore': 1},
        'pmsReminder': {'enabled': true, 'daysBefore': 3},
        'symptomReminder': {'enabled': true, 'time': '21:00'},
        'medicationReminder': {'enabled': false, 'times': []},
        'wellnessCheck': {'enabled': true, 'frequency': 'weekly'},
      };
    }
  }

  Future<void> setReminderSettings(Map<String, dynamic> settings) async {
    final jsonString = jsonEncode(settings);
    await _prefs.setString(_keyReminderSettings, jsonString);
  }

  // Generic preference methods
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int getInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }

  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  Set<String> getKeys() {
    return _prefs.getKeys();
  }
  
  // Additional methods for onboarding
  Future<void> setOnboardingCompleted(bool completed) async {
    await setBool(_keyOnboardingComplete, completed);
  }
  
  Future<void> setFirstLaunch(bool isFirst) async {
    await setBool('first_launch', isFirst);
  }
  
  Future<void> setAverageCycleLength(int length) async {
    await setInt('average_cycle_length', length);
  }
  
  Future<void> setAveragePeriodLength(int length) async {
    await setInt('average_period_length', length);
  }
  
  Future<void> setTrackingGoals(List<String> goals) async {
    final goalsString = goals.join(',');
    await setString('tracking_goals', goalsString);
  }
}
