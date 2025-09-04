import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../models/localization_models.dart';

/// Localization service for multi-language support
class LocalizationService {
  static LocalizationService? _instance;
  static LocalizationService get instance {
    _instance ??= LocalizationService._internal();
    return _instance!;
  }

  LocalizationService._internal();

  bool _isInitialized = false;
  SharedPreferences? _prefs;
  late SupportedLocale _currentLocale;
  Map<String, Map<String, String>> _localizedStrings = {};
  final StreamController<SupportedLocale> _localeController = StreamController<SupportedLocale>.broadcast();

  // Configuration
  static const String _selectedLocaleKey = 'selected_locale';
  static const List<SupportedLocale> _supportedLocales = [
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

  /// Initialize the localization service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      
      // Load current locale
      await _loadCurrentLocale();
      
      // Load localized strings
      await _loadLocalizedStrings();
      
      // Initialize date formatting
      await initializeDateFormatting(_currentLocale.toString());
      
      _isInitialized = true;
      debugPrint('🌍 Localization service initialized with locale: $_currentLocale');
    } catch (e) {
      debugPrint('❌ Failed to initialize localization: $e');
      throw LocalizationException('Failed to initialize localization service: $e');
    }
  }

  /// Get current locale
  SupportedLocale get currentLocale => _currentLocale;

  /// Get supported locales
  List<SupportedLocale> get supportedLocales => List.from(_supportedLocales);

  /// Get locale change stream
  Stream<SupportedLocale> get localeStream => _localeController.stream;

  /// Check if locale is RTL
  bool get isRTL => _currentLocale.languageCode == 'ar';

  /// Set current locale
  Future<void> setLocale(SupportedLocale locale) async {
    if (!_isInitialized) await initialize();

    try {
      if (_currentLocale == locale) return;

      _currentLocale = locale;
      await _saveCurrentLocale();
      await _loadLocalizedStrings();
      await initializeDateFormatting(locale.toString());

      // Notify listeners
      _localeController.add(locale);

      debugPrint('🌍 Locale changed to: $locale');
    } catch (e) {
      debugPrint('❌ Failed to set locale: $e');
      throw LocalizationException('Failed to set locale: $e');
    }
  }

  /// Get localized string
  String getString(String key, [Map<String, String>? params]) {
    if (!_isInitialized) {
      return key; // Fallback to key if not initialized
    }

    final String localeKey = _currentLocale.toString();
    String? localizedString = _localizedStrings[localeKey]?[key];

    // Fallback to English if key not found in current locale
    localizedString ??= _localizedStrings['en_US']?[key];

    // Fallback to key if not found in any locale
    localizedString ??= key;

    // Replace parameters if provided
    if (params != null) {
      for (final entry in params.entries) {
        localizedString = localizedString!.replaceAll('{${entry.key}}', entry.value);
      }
    }

    return localizedString!;
  }

  /// Get localized string with pluralization
  String getPlural(String key, int count, [Map<String, String>? params]) {
    if (!_isInitialized) return key;

    String pluralKey = key;
    
    // Simple pluralization rules
    if (count == 0) {
      pluralKey = '${key}_zero';
    } else if (count == 1) {
      pluralKey = '${key}_one';
    } else {
      pluralKey = '${key}_other';
    }

    // Add count to params
    final Map<String, String> finalParams = {
      'count': count.toString(),
      ...(params ?? {}),
    };

    return getString(pluralKey, finalParams);
  }

  /// Format date according to current locale
  String formatDate(DateTime date, {DateFormat? customFormat}) {
    if (!_isInitialized) return date.toString();

    try {
      final DateFormat formatter = customFormat ?? DateFormat.yMMMd(_currentLocale.toString());
      return formatter.format(date);
    } catch (e) {
      debugPrint('⚠️ Date formatting error: $e');
      return DateFormat.yMMMd().format(date); // Fallback to default
    }
  }

  /// Format time according to current locale
  String formatTime(DateTime time, {bool use24Hour = false}) {
    if (!_isInitialized) return time.toString();

    try {
      final DateFormat formatter = use24Hour 
          ? DateFormat.Hm(_currentLocale.toString())
          : DateFormat.jm(_currentLocale.toString());
      return formatter.format(time);
    } catch (e) {
      debugPrint('⚠️ Time formatting error: $e');
      return DateFormat.jm().format(time); // Fallback to default
    }
  }

  /// Format datetime according to current locale
  String formatDateTime(DateTime dateTime, {DateFormat? customFormat}) {
    if (!_isInitialized) return dateTime.toString();

    try {
      final DateFormat formatter = customFormat ?? DateFormat.yMMMd(_currentLocale.toString()).add_jm();
      return formatter.format(dateTime);
    } catch (e) {
      debugPrint('⚠️ DateTime formatting error: $e');
      return DateFormat.yMMMd().add_jm().format(dateTime); // Fallback to default
    }
  }

  /// Format number according to current locale
  String formatNumber(num number, {int? decimalDigits}) {
    if (!_isInitialized) return number.toString();

    try {
      final NumberFormat formatter = NumberFormat.decimalPattern(_currentLocale.toString());
      if (decimalDigits != null) {
        formatter.minimumFractionDigits = decimalDigits;
        formatter.maximumFractionDigits = decimalDigits;
      }
      return formatter.format(number);
    } catch (e) {
      debugPrint('⚠️ Number formatting error: $e');
      return number.toString(); // Fallback to default
    }
  }

  /// Format currency according to current locale
  String formatCurrency(double amount, {String? currencyCode}) {
    if (!_isInitialized) return amount.toString();

    try {
      final String currency = currencyCode ?? _getCurrencyForLocale(_currentLocale);
      final NumberFormat formatter = NumberFormat.currency(
        locale: _currentLocale.toString(),
        symbol: currency,
      );
      return formatter.format(amount);
    } catch (e) {
      debugPrint('⚠️ Currency formatting error: $e');
      return amount.toString(); // Fallback to default
    }
  }

  /// Get localized month names
  List<String> getMonthNames() {
    if (!_isInitialized) return [];

    try {
      final DateFormat formatter = DateFormat('MMMM', _currentLocale.toString());
      return List.generate(12, (index) {
        final DateTime date = DateTime(2024, index + 1, 1);
        return formatter.format(date);
      });
    } catch (e) {
      debugPrint('⚠️ Month names formatting error: $e');
      return [];
    }
  }

  /// Get localized day names
  List<String> getDayNames() {
    if (!_isInitialized) return [];

    try {
      final DateFormat formatter = DateFormat('EEEE', _currentLocale.toString());
      return List.generate(7, (index) {
        // Start from Monday (index 1 in DateTime.monday)
        final DateTime date = DateTime(2024, 1, index + 1);
        return formatter.format(date);
      });
    } catch (e) {
      debugPrint('⚠️ Day names formatting error: $e');
      return [];
    }
  }

  /// Export current translations for external tools
  Future<Map<String, dynamic>> exportTranslations() async {
    if (!_isInitialized) await initialize();

    return {
      'current_locale': _currentLocale.toString(),
      'supported_locales': _supportedLocales.map((l) => l.toJson()).toList(),
      'translations': _localizedStrings,
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  /// Import translations from external source
  Future<void> importTranslations(Map<String, dynamic> translationsData) async {
    if (!_isInitialized) await initialize();

    try {
      if (translationsData['translations'] != null) {
        final Map<String, dynamic> translations = translationsData['translations'];
        
        for (final localeKey in translations.keys) {
          _localizedStrings[localeKey] = Map<String, String>.from(translations[localeKey]);
        }

        debugPrint('🌍 Imported translations for ${translations.keys.length} locales');
      }
    } catch (e) {
      debugPrint('❌ Failed to import translations: $e');
      throw LocalizationException('Failed to import translations: $e');
    }
  }

  /// Load current locale from storage
  Future<void> _loadCurrentLocale() async {
    try {
      final String? savedLocale = _prefs?.getString(_selectedLocaleKey);
      
      if (savedLocale != null) {
        final List<String> parts = savedLocale.split('_');
        if (parts.length == 2) {
          _currentLocale = SupportedLocale.fromParts(parts[0], parts[1]);
        } else {
          _currentLocale = _getDefaultLocale();
        }
      } else {
        _currentLocale = _getDefaultLocale();
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load locale, using default: $e');
      _currentLocale = _getDefaultLocale();
    }
  }

  /// Save current locale to storage
  Future<void> _saveCurrentLocale() async {
    try {
      await _prefs?.setString(_selectedLocaleKey, _currentLocale.toString());
    } catch (e) {
      debugPrint('⚠️ Failed to save locale: $e');
    }
  }

  /// Load localized strings from assets
  Future<void> _loadLocalizedStrings() async {
    try {
      final String localeKey = _currentLocale.toString();
      
      // Load current locale strings
      await _loadStringsForLocale(localeKey);
      
      // Always load English as fallback
      if (localeKey != 'en_US') {
        await _loadStringsForLocale('en_US');
      }
    } catch (e) {
      debugPrint('❌ Failed to load localized strings: $e');
      // Load fallback strings
      _loadFallbackStrings();
    }
  }

  /// Load strings for specific locale
  Future<void> _loadStringsForLocale(String localeKey) async {
    try {
      final String fileName = 'lib/features/localization/assets/strings_$localeKey.json';
      final String jsonString = await rootBundle.loadString(fileName);
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      
      _localizedStrings[localeKey] = Map<String, String>.from(jsonMap);
    } catch (e) {
      debugPrint('⚠️ Failed to load strings for $localeKey: $e');
      // Create with fallback strings if asset loading fails
      _localizedStrings[localeKey] = _getFallbackStrings();
    }
  }

  /// Get default locale based on system
  SupportedLocale _getDefaultLocale() {
    try {
      final String systemLocale = Intl.getCurrentLocale();
      final List<String> parts = systemLocale.split('_');
      
      if (parts.isNotEmpty) {
        // Find matching supported locale
        for (final locale in _supportedLocales) {
          if (locale.languageCode == parts[0]) {
            return locale;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Failed to get system locale: $e');
    }
    
    // Default to English
    return const SupportedLocale('en', 'US', 'English', 'English');
  }

  /// Get currency symbol for locale
  String _getCurrencyForLocale(SupportedLocale locale) {
    switch (locale.languageCode) {
      case 'en':
        return locale.countryCode == 'US' ? '\$' : '£';
      case 'es':
        return '€';
      case 'fr':
        return '€';
      case 'de':
        return '€';
      case 'pt':
        return 'R\$';
      case 'zh':
        return '¥';
      case 'ja':
        return '¥';
      case 'ko':
        return '₩';
      case 'ar':
        return 'ر.س';
      case 'hi':
        return '₹';
      default:
        return '\$';
    }
  }

  /// Load fallback strings when asset loading fails
  void _loadFallbackStrings() {
    _localizedStrings['en_US'] = _getFallbackStrings();
  }

  /// Get fallback strings
  Map<String, String> _getFallbackStrings() {
    return {
      // App basics
      'app_name': 'ZyraFlow',
      'welcome': 'Welcome',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'done': 'Done',
      'next': 'Next',
      'back': 'Back',
      'continue': 'Continue',
      'skip': 'Skip',
      'retry': 'Retry',
      
      // Navigation
      'home': 'Home',
      'tracking': 'Tracking',
      'insights': 'Insights',
      'settings': 'Settings',
      'profile': 'Profile',
      
      // Health tracking
      'cycle_tracking': 'Cycle Tracking',
      'mood_tracking': 'Mood Tracking',
      'symptoms': 'Symptoms',
      'notes': 'Notes',
      'predictions': 'Predictions',
      
      // Time and dates
      'today': 'Today',
      'yesterday': 'Yesterday',
      'tomorrow': 'Tomorrow',
      'this_week': 'This Week',
      'this_month': 'This Month',
      
      // Common actions
      'add': 'Add',
      'remove': 'Remove',
      'update': 'Update',
      'share': 'Share',
      'export': 'Export',
      'import': 'Import',
      'backup': 'Backup',
      'restore': 'Restore',
      
      // Status messages
      'data_saved': 'Data saved successfully',
      'data_loaded': 'Data loaded',
      'sync_complete': 'Synchronization complete',
      'backup_created': 'Backup created',
      
      // Pluralization examples
      'day_zero': '{count} days',
      'day_one': '{count} day',
      'day_other': '{count} days',
      'entry_zero': 'No entries',
      'entry_one': '{count} entry',
      'entry_other': '{count} entries',
    };
  }

  /// Dispose resources
  void dispose() {
    _localeController.close();
    _isInitialized = false;
  }
}

class LocalizationException implements Exception {
  final String message;
  LocalizationException(this.message);

  @override
  String toString() => 'LocalizationException: $message';
}
