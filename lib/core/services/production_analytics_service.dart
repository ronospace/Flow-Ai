import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// Production-ready analytics and monitoring service
/// Tracks user behavior, app performance, and business metrics
class ProductionAnalyticsService {
  static final ProductionAnalyticsService _instance = ProductionAnalyticsService._internal();
  factory ProductionAnalyticsService() => _instance;
  ProductionAnalyticsService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;
  bool _analyticsEnabled = true;
  String? _userId;
  Map<String, dynamic> _sessionData = {};

  static const String _keyAnalyticsEnabled = 'analytics_enabled';
  static const String _keyUserId = 'user_id';
  static const String _keySessionData = 'session_data';
  static const String _keyAppEvents = 'app_events';

  /// Initialize the production analytics service
  Future<void> initialize({String? userId}) async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _analyticsEnabled = _prefs?.getBool(_keyAnalyticsEnabled) ?? true;
      _userId = userId ?? _prefs?.getString(_keyUserId);
      
      _sessionData = {
        'session_start': DateTime.now().toIso8601String(),
        'app_version': '2.0.0+2',
        'platform': defaultTargetPlatform.name,
        'session_id': _generateSessionId(),
      };
      
      _isInitialized = true;
      
      // Track app launch
      await trackEvent('app_launch', {
        'timestamp': DateTime.now().toIso8601String(),
        'cold_start': true,
      });
      
      AppLogger.success('Production Analytics Service initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize Production Analytics Service', e);
    }
  }

  /// Track user events for analytics
  Future<void> trackEvent(String eventName, Map<String, dynamic> properties) async {
    if (!_analyticsEnabled || !_isInitialized) return;

    try {
      final event = {
        'event_name': eventName,
        'timestamp': DateTime.now().toIso8601String(),
        'user_id': _userId,
        'session_id': _sessionData['session_id'],
        'properties': properties,
      };

      await _storeEvent(event);
      
      // In production, you would send this to your analytics service
      // For now, we'll log it for development
      if (kDebugMode) {
        AppLogger.info('Analytics Event: $eventName - ${jsonEncode(event)}');
      }
    } catch (e) {
      AppLogger.error('Failed to track event: $eventName', e);
    }
  }

  /// Track screen views
  Future<void> trackScreenView(String screenName, {Map<String, dynamic>? properties}) async {
    await trackEvent('screen_view', {
      'screen_name': screenName,
      'timestamp': DateTime.now().toIso8601String(),
      ...?properties,
    });
  }

  /// Track user actions
  Future<void> trackUserAction(String action, {Map<String, dynamic>? context}) async {
    await trackEvent('user_action', {
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
      ...?context,
    });
  }

  /// Track app performance metrics
  Future<void> trackPerformanceMetric(String metricName, double value, {String? unit}) async {
    await trackEvent('performance_metric', {
      'metric_name': metricName,
      'value': value,
      'unit': unit ?? 'ms',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track errors and crashes
  Future<void> trackError(String errorType, String errorMessage, {
    String? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    await trackEvent('app_error', {
      'error_type': errorType,
      'error_message': errorMessage,
      'stack_trace': stackTrace,
      'timestamp': DateTime.now().toIso8601String(),
      'context': context,
    });
  }

  /// Track business metrics
  Future<void> trackBusinessMetric(String metricName, dynamic value) async {
    await trackEvent('business_metric', {
      'metric_name': metricName,
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track user onboarding progress
  Future<void> trackOnboardingStep(String stepName, bool completed, {int? stepNumber}) async {
    await trackEvent('onboarding_step', {
      'step_name': stepName,
      'step_number': stepNumber,
      'completed': completed,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track feature usage
  Future<void> trackFeatureUsage(String featureName, {Map<String, dynamic>? metadata}) async {
    await trackEvent('feature_usage', {
      'feature_name': featureName,
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': metadata,
    });
  }

  /// Track user retention milestones
  Future<void> trackRetentionMilestone(String milestone) async {
    await trackEvent('retention_milestone', {
      'milestone': milestone,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track app session duration
  Future<void> trackSessionEnd() async {
    if (_sessionData.containsKey('session_start')) {
      final startTime = DateTime.parse(_sessionData['session_start']);
      final duration = DateTime.now().difference(startTime).inSeconds;
      
      await trackEvent('session_end', {
        'session_duration_seconds': duration,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Set user properties for analytics
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    if (!_analyticsEnabled || !_isInitialized) return;

    try {
      await trackEvent('user_properties_updated', {
        'properties': properties,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      AppLogger.error('Failed to set user properties', e);
    }
  }

  /// Enable or disable analytics
  Future<void> setAnalyticsEnabled(bool enabled) async {
    _analyticsEnabled = enabled;
    await _prefs?.setBool(_keyAnalyticsEnabled, enabled);
    
    await trackEvent('analytics_settings_changed', {
      'enabled': enabled,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Get analytics summary for debugging
  Future<Map<String, dynamic>> getAnalyticsSummary() async {
    if (!_isInitialized) return {};

    final events = await _getStoredEvents();
    return {
      'total_events': events.length,
      'session_data': _sessionData,
      'analytics_enabled': _analyticsEnabled,
      'user_id': _userId,
      'recent_events': events.take(10).toList(),
    };
  }

  /// Store event locally for batch sending
  Future<void> _storeEvent(Map<String, dynamic> event) async {
    if (_prefs == null) return;

    try {
      final events = await _getStoredEvents();
      events.add(event);
      
      // Keep only last 1000 events to prevent storage bloat
      if (events.length > 1000) {
        events.removeRange(0, events.length - 1000);
      }
      
      await _prefs!.setString(_keyAppEvents, jsonEncode(events));
    } catch (e) {
      AppLogger.error('Failed to store analytics event', e);
    }
  }

  /// Get stored events
  Future<List<Map<String, dynamic>>> _getStoredEvents() async {
    if (_prefs == null) return [];

    try {
      final eventsJson = _prefs!.getString(_keyAppEvents);
      if (eventsJson == null) return [];
      
      final eventsList = jsonDecode(eventsJson) as List;
      return eventsList.cast<Map<String, dynamic>>();
    } catch (e) {
      AppLogger.error('Failed to retrieve stored events', e);
      return [];
    }
  }

  /// Generate unique session ID
  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(8)}';
  }

  /// Generate random string
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (index) => chars[(DateTime.now().millisecondsSinceEpoch + index) % chars.length]).join();
  }

  /// Clear all stored analytics data (for privacy compliance)
  Future<void> clearAnalyticsData() async {
    await _prefs?.remove(_keyAppEvents);
    await _prefs?.remove(_keySessionData);
    
    AppLogger.info('Analytics data cleared');
  }

  /// Convenience methods for common events
  Future<void> trackAppStart() => trackEvent('app_start', {});
  Future<void> trackAppBackground() => trackEvent('app_background', {});
  Future<void> trackAppForeground() => trackEvent('app_foreground', {});
  
  Future<void> trackUserLogin(String method) => trackEvent('user_login', {'method': method});
  Future<void> trackUserLogout() => trackEvent('user_logout', {});
  Future<void> trackUserSignup(String method) => trackEvent('user_signup', {'method': method});
  
  Future<void> trackCycleAdded() => trackEvent('cycle_added', {});
  Future<void> trackSymptomLogged(String symptom) => trackEvent('symptom_logged', {'symptom': symptom});
  Future<void> trackAIPredictionViewed() => trackEvent('ai_prediction_viewed', {});
  Future<void> trackSettingsChanged(String setting) => trackEvent('settings_changed', {'setting': setting});
}

/// Extension for easy analytics tracking
extension AnalyticsTracker on Object {
  Future<void> trackEvent(String eventName, [Map<String, dynamic>? properties]) async {
    await ProductionAnalyticsService().trackEvent(eventName, properties ?? {});
  }
  
  Future<void> trackScreen(String screenName) async {
    await ProductionAnalyticsService().trackScreenView(screenName);
  }
}
