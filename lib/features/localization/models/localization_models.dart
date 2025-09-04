import 'package:flutter/material.dart';

/// Supported locale model
class SupportedLocale {
  final String languageCode;
  final String countryCode;
  final String englishName;
  final String nativeName;

  const SupportedLocale(
    this.languageCode,
    this.countryCode,
    this.englishName,
    this.nativeName,
  );

  /// Create locale from language and country parts
  factory SupportedLocale.fromParts(String languageCode, String countryCode) {
    // Find matching locale from predefined list
    const List<SupportedLocale> supportedLocales = [
      SupportedLocale('en', 'US', 'English', 'English'),
      SupportedLocale('es', 'ES', 'Spanish', 'Español'),
      SupportedLocale('fr', 'FR', 'French', 'Français'),
      SupportedLocale('de', 'DE', 'German', 'Deutsch'),
      SupportedLocale('pt', 'BR', 'Portuguese', 'Português'),
      SupportedLocale('zh', 'CN', 'Chinese Simplified', '简体中文'),
      SupportedLocale('ja', 'JP', 'Japanese', '日本語'),
      SupportedLocale('ko', 'KR', 'Korean', '한국어'),
      SupportedLocale('ar', 'SA', 'Arabic', 'العربية'),
      SupportedLocale('hi', 'IN', 'Hindi', 'हिन्दी'),
    ];

    for (final locale in supportedLocales) {
      if (locale.languageCode == languageCode && locale.countryCode == countryCode) {
        return locale;
      }
    }

    // If exact match not found, try language code only
    for (final locale in supportedLocales) {
      if (locale.languageCode == languageCode) {
        return locale;
      }
    }

    // Default to English if no match
    return const SupportedLocale('en', 'US', 'English', 'English');
  }

  /// Convert to Flutter Locale
  Locale toLocale() => Locale(languageCode, countryCode);

  /// Convert to string representation
  @override
  String toString() => '${languageCode}_$countryCode';

  /// Get display name for current context
  String getDisplayName({bool useNative = false}) {
    return useNative ? nativeName : englishName;
  }

  /// Check if locale is RTL
  bool get isRTL => languageCode == 'ar';

  /// Get text direction
  TextDirection get textDirection => isRTL ? TextDirection.rtl : TextDirection.ltr;

  /// JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'language_code': languageCode,
      'country_code': countryCode,
      'english_name': englishName,
      'native_name': nativeName,
    };
  }

  factory SupportedLocale.fromJson(Map<String, dynamic> json) {
    return SupportedLocale(
      json['language_code'],
      json['country_code'],
      json['english_name'],
      json['native_name'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportedLocale &&
          runtimeType == other.runtimeType &&
          languageCode == other.languageCode &&
          countryCode == other.countryCode;

  @override
  int get hashCode => languageCode.hashCode ^ countryCode.hashCode;
}

/// Translation key metadata
class TranslationKey {
  final String key;
  final String description;
  final String category;
  final bool requiresPluralization;
  final List<String> parameters;

  const TranslationKey({
    required this.key,
    required this.description,
    this.category = 'general',
    this.requiresPluralization = false,
    this.parameters = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'description': description,
      'category': category,
      'requires_pluralization': requiresPluralization,
      'parameters': parameters,
    };
  }

  factory TranslationKey.fromJson(Map<String, dynamic> json) {
    return TranslationKey(
      key: json['key'],
      description: json['description'],
      category: json['category'] ?? 'general',
      requiresPluralization: json['requires_pluralization'] ?? false,
      parameters: List<String>.from(json['parameters'] ?? []),
    );
  }
}

/// Translation progress for a locale
class LocaleTranslationProgress {
  final SupportedLocale locale;
  final int totalKeys;
  final int translatedKeys;
  final int reviewedKeys;
  final DateTime lastUpdated;
  final List<String> missingKeys;

  LocaleTranslationProgress({
    required this.locale,
    required this.totalKeys,
    required this.translatedKeys,
    required this.reviewedKeys,
    required this.lastUpdated,
    this.missingKeys = const [],
  });

  /// Get completion percentage
  double get completionPercentage {
    if (totalKeys == 0) return 100.0;
    return (translatedKeys / totalKeys) * 100;
  }

  /// Get review percentage
  double get reviewPercentage {
    if (translatedKeys == 0) return 0.0;
    return (reviewedKeys / translatedKeys) * 100;
  }

  /// Check if translation is complete
  bool get isComplete => translatedKeys >= totalKeys;

  /// Check if translation is reviewed
  bool get isFullyReviewed => reviewedKeys >= translatedKeys;

  Map<String, dynamic> toJson() {
    return {
      'locale': locale.toJson(),
      'total_keys': totalKeys,
      'translated_keys': translatedKeys,
      'reviewed_keys': reviewedKeys,
      'last_updated': lastUpdated.toIso8601String(),
      'missing_keys': missingKeys,
      'completion_percentage': completionPercentage,
      'review_percentage': reviewPercentage,
    };
  }

  factory LocaleTranslationProgress.fromJson(Map<String, dynamic> json) {
    return LocaleTranslationProgress(
      locale: SupportedLocale.fromJson(json['locale']),
      totalKeys: json['total_keys'],
      translatedKeys: json['translated_keys'],
      reviewedKeys: json['reviewed_keys'],
      lastUpdated: DateTime.parse(json['last_updated']),
      missingKeys: List<String>.from(json['missing_keys'] ?? []),
    );
  }
}

/// Localization configuration
class LocalizationConfig {
  final SupportedLocale defaultLocale;
  final List<SupportedLocale> supportedLocales;
  final bool fallbackToEnglish;
  final bool enablePseudoLocalization;
  final bool enableTranslationDebugging;
  final Map<String, dynamic> customSettings;

  const LocalizationConfig({
    this.defaultLocale = const SupportedLocale('en', 'US', 'English', 'English'),
    this.supportedLocales = const [
      SupportedLocale('en', 'US', 'English', 'English'),
      SupportedLocale('es', 'ES', 'Spanish', 'Español'),
      SupportedLocale('fr', 'FR', 'French', 'Français'),
      SupportedLocale('de', 'DE', 'German', 'Deutsch'),
      SupportedLocale('pt', 'BR', 'Portuguese', 'Português'),
      SupportedLocale('zh', 'CN', 'Chinese Simplified', '简体中文'),
      SupportedLocale('ja', 'JP', 'Japanese', '日本語'),
      SupportedLocale('ko', 'KR', 'Korean', '한국어'),
      SupportedLocale('ar', 'SA', 'Arabic', 'العربية'),
      SupportedLocale('hi', 'IN', 'Hindi', 'हिन्दी'),
    ],
    this.fallbackToEnglish = true,
    this.enablePseudoLocalization = false,
    this.enableTranslationDebugging = false,
    this.customSettings = const {},
  });

  /// Check if locale is supported
  bool isLocaleSupported(SupportedLocale locale) {
    return supportedLocales.contains(locale);
  }

  /// Get closest supported locale
  SupportedLocale getClosestSupportedLocale(String languageCode) {
    // Try exact match first
    for (final locale in supportedLocales) {
      if (locale.languageCode == languageCode) {
        return locale;
      }
    }
    
    // Fallback to default
    return defaultLocale;
  }

  Map<String, dynamic> toJson() {
    return {
      'default_locale': defaultLocale.toJson(),
      'supported_locales': supportedLocales.map((l) => l.toJson()).toList(),
      'fallback_to_english': fallbackToEnglish,
      'enable_pseudo_localization': enablePseudoLocalization,
      'enable_translation_debugging': enableTranslationDebugging,
      'custom_settings': customSettings,
    };
  }

  factory LocalizationConfig.fromJson(Map<String, dynamic> json) {
    return LocalizationConfig(
      defaultLocale: SupportedLocale.fromJson(json['default_locale']),
      supportedLocales: (json['supported_locales'] as List)
          .map((l) => SupportedLocale.fromJson(l))
          .toList(),
      fallbackToEnglish: json['fallback_to_english'] ?? true,
      enablePseudoLocalization: json['enable_pseudo_localization'] ?? false,
      enableTranslationDebugging: json['enable_translation_debugging'] ?? false,
      customSettings: json['custom_settings'] ?? {},
    );
  }
}

/// Text direction helper
enum TextDirectionality {
  ltr,
  rtl,
  auto,
}

extension TextDirectionalityExtension on TextDirectionality {
  TextDirection toTextDirection([SupportedLocale? locale]) {
    switch (this) {
      case TextDirectionality.ltr:
        return TextDirection.ltr;
      case TextDirectionality.rtl:
        return TextDirection.rtl;
      case TextDirectionality.auto:
        return locale?.textDirection ?? TextDirection.ltr;
    }
  }
}

/// Date format preferences
class LocaleDateFormat {
  final String pattern;
  final String description;
  final List<SupportedLocale> applicableLocales;

  const LocaleDateFormat({
    required this.pattern,
    required this.description,
    this.applicableLocales = const [],
  });

  /// Common date format patterns
  static const LocaleDateFormat shortDate = LocaleDateFormat(
    pattern: 'M/d/y',
    description: 'Short date (1/1/2024)',
  );

  static const LocaleDateFormat mediumDate = LocaleDateFormat(
    pattern: 'MMM d, y',
    description: 'Medium date (Jan 1, 2024)',
  );

  static const LocaleDateFormat longDate = LocaleDateFormat(
    pattern: 'MMMM d, y',
    description: 'Long date (January 1, 2024)',
  );

  static const LocaleDateFormat fullDate = LocaleDateFormat(
    pattern: 'EEEE, MMMM d, y',
    description: 'Full date (Monday, January 1, 2024)',
  );

  Map<String, dynamic> toJson() {
    return {
      'pattern': pattern,
      'description': description,
      'applicable_locales': applicableLocales.map((l) => l.toJson()).toList(),
    };
  }

  factory LocaleDateFormat.fromJson(Map<String, dynamic> json) {
    return LocaleDateFormat(
      pattern: json['pattern'],
      description: json['description'],
      applicableLocales: (json['applicable_locales'] as List?)
          ?.map((l) => SupportedLocale.fromJson(l))
          .toList() ?? [],
    );
  }
}
