import 'package:flutter/material.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

enum AppLanguage {
  english,
  spanish,
  french,
  portuguese,
  german,
  italian,
  arabic,
  hindi,
  chinese,
  japanese,
  korean,
  russian,
}

extension AppLanguageExtension on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.spanish:
        return 'es';
      case AppLanguage.french:
        return 'fr';
      case AppLanguage.portuguese:
        return 'pt';
      case AppLanguage.german:
        return 'de';
      case AppLanguage.italian:
        return 'it';
      case AppLanguage.arabic:
        return 'ar';
      case AppLanguage.hindi:
        return 'hi';
      case AppLanguage.chinese:
        return 'zh';
      case AppLanguage.japanese:
        return 'ja';
      case AppLanguage.korean:
        return 'ko';
      case AppLanguage.russian:
        return 'ru';
    }
  }

  String get displayName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.spanish:
        return 'Español';
      case AppLanguage.french:
        return 'Français';
      case AppLanguage.portuguese:
        return 'Português';
      case AppLanguage.german:
        return 'Deutsch';
      case AppLanguage.italian:
        return 'Italiano';
      case AppLanguage.arabic:
        return 'العربية';
      case AppLanguage.hindi:
        return 'हिन्दी';
      case AppLanguage.chinese:
        return '中文';
      case AppLanguage.japanese:
        return '日本語';
      case AppLanguage.korean:
        return '한국어';
      case AppLanguage.russian:
        return 'Русский';
    }
  }

  Locale get locale => Locale(code);
}

class UserPreferences {
  final String userId;
  final String displayName;
  final AppThemeMode themeMode;
  final AppLanguage language;
  final bool notificationsEnabled;
  final TimeOfDay notificationTime;
  final bool periodReminders;
  final bool ovulationReminders;
  final bool symptomReminders;
  final int reminderDaysBefore;
  final bool aiInsightsEnabled;
  final bool hapticFeedbackEnabled;
  final bool soundsEnabled;
  final String avatarUrl;
  final bool syncWithCycleSync;
  final String? cycleSyncUserId;
  final bool privacyMode;
  final bool biometricAuth;
  final DateTime lastUpdated;

  const UserPreferences({
    required this.userId,
    this.displayName = '',
    this.themeMode = AppThemeMode.system,
    this.language = AppLanguage.english,
    this.notificationsEnabled = true,
    this.notificationTime = const TimeOfDay(hour: 9, minute: 0),
    this.periodReminders = true,
    this.ovulationReminders = true,
    this.symptomReminders = false,
    this.reminderDaysBefore = 2,
    this.aiInsightsEnabled = true,
    this.hapticFeedbackEnabled = true,
    this.soundsEnabled = true,
    this.avatarUrl = '',
    this.syncWithCycleSync = false,
    this.cycleSyncUserId,
    this.privacyMode = false,
    this.biometricAuth = false,
    required this.lastUpdated,
  });

  UserPreferences copyWith({
    String? userId,
    String? displayName,
    AppThemeMode? themeMode,
    AppLanguage? language,
    bool? notificationsEnabled,
    TimeOfDay? notificationTime,
    bool? periodReminders,
    bool? ovulationReminders,
    bool? symptomReminders,
    int? reminderDaysBefore,
    bool? aiInsightsEnabled,
    bool? hapticFeedbackEnabled,
    bool? soundsEnabled,
    String? avatarUrl,
    bool? syncWithCycleSync,
    String? cycleSyncUserId,
    bool? privacyMode,
    bool? biometricAuth,
    DateTime? lastUpdated,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      periodReminders: periodReminders ?? this.periodReminders,
      ovulationReminders: ovulationReminders ?? this.ovulationReminders,
      symptomReminders: symptomReminders ?? this.symptomReminders,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      aiInsightsEnabled: aiInsightsEnabled ?? this.aiInsightsEnabled,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      soundsEnabled: soundsEnabled ?? this.soundsEnabled,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      syncWithCycleSync: syncWithCycleSync ?? this.syncWithCycleSync,
      cycleSyncUserId: cycleSyncUserId ?? this.cycleSyncUserId,
      privacyMode: privacyMode ?? this.privacyMode,
      biometricAuth: biometricAuth ?? this.biometricAuth,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'themeMode': themeMode.index,
      'language': language.index,
      'notificationsEnabled': notificationsEnabled,
      'notificationHour': notificationTime.hour,
      'notificationMinute': notificationTime.minute,
      'periodReminders': periodReminders,
      'ovulationReminders': ovulationReminders,
      'symptomReminders': symptomReminders,
      'reminderDaysBefore': reminderDaysBefore,
      'aiInsightsEnabled': aiInsightsEnabled,
      'hapticFeedbackEnabled': hapticFeedbackEnabled,
      'soundsEnabled': soundsEnabled,
      'avatarUrl': avatarUrl,
      'syncWithCycleSync': syncWithCycleSync,
      'cycleSyncUserId': cycleSyncUserId,
      'privacyMode': privacyMode,
      'biometricAuth': biometricAuth,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['userId'] ?? '',
      displayName: json['displayName'] ?? '',
      themeMode: AppThemeMode.values[json['themeMode'] ?? 0],
      language: AppLanguage.values[json['language'] ?? 0],
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      notificationTime: TimeOfDay(
        hour: json['notificationHour'] ?? 9,
        minute: json['notificationMinute'] ?? 0,
      ),
      periodReminders: json['periodReminders'] ?? true,
      ovulationReminders: json['ovulationReminders'] ?? true,
      symptomReminders: json['symptomReminders'] ?? false,
      reminderDaysBefore: json['reminderDaysBefore'] ?? 2,
      aiInsightsEnabled: json['aiInsightsEnabled'] ?? true,
      hapticFeedbackEnabled: json['hapticFeedbackEnabled'] ?? true,
      soundsEnabled: json['soundsEnabled'] ?? true,
      avatarUrl: json['avatarUrl'] ?? '',
      syncWithCycleSync: json['syncWithCycleSync'] ?? false,
      cycleSyncUserId: json['cycleSyncUserId'],
      privacyMode: json['privacyMode'] ?? false,
      biometricAuth: json['biometricAuth'] ?? false,
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }
}
