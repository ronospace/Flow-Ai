import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/app_logger.dart';
import 'app_runtime_metadata_service.dart';

/// Production-ready analytics and monitoring service
/// Tracks user behavior, app performance, and business metrics
class ProductionAnalyticsService {
  static const bool _runtimeDiagnosticsEnabled = bool.fromEnvironment(
    'FLOW_AI_RUNTIME_DIAGNOSTICS',
    defaultValue: false,
  );

  static final ProductionAnalyticsService _instance =
      ProductionAnalyticsService._internal();
  factory ProductionAnalyticsService() => _instance;
  ProductionAnalyticsService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;
  bool _initializing = false;
  bool _analyticsEnabled = false;
  String? _userId;
  Map<String, dynamic> _sessionData = {};

  static const String _keyAnalyticsEnabled = 'analytics_enabled';
  static const String _keySessionData = 'session_data';
  static const String _keyAppEvents = 'app_events';

  /// Initialize the production analytics service
  Future<void> initialize({String? userId}) async {
    if (_isInitialized || _initializing) return;
    _initializing = true;

    try {
      _prefs = await SharedPreferences.getInstance();
      _analyticsEnabled = _prefs?.getBool(_keyAnalyticsEnabled) ?? false;
      _userId = userId;
      final appVersion =
          await AppRuntimeMetadataService.instance.versionWithBuild;

      _sessionData = {
        'session_start': DateTime.now().toIso8601String(),
        'app_version': appVersion,
        'platform': defaultTargetPlatform.name,
        'session_id': _generateSessionId(),
      };

      _isInitialized = true;
      _initializing = false;

      // Track app launch
      await trackEvent('app_launch', {
        'timestamp': DateTime.now().toIso8601String(),
        'cold_start': true,
      });

      if (!_sessionData.containsKey('init_logged')) {
        AppLogger.success('Production Analytics Service initialized');
        _sessionData['init_logged'] = true;
      }
    } catch (e) {
      AppLogger.error('Failed to initialize Production Analytics Service', e);
    }
  }

  /// Bind analytics attribution to the current authenticated account.
  ///
  /// Account changes clear queued account-attributed events before the new
  /// identity is accepted, preventing cross-account attribution.
  Future<void> setAuthenticatedUser(String? userId) async {
    if (!_isInitialized) {
      await initialize(userId: userId);
      return;
    }

    if (_userId == userId) return;

    await _prefs?.remove(_keyAppEvents);
    await _prefs?.remove(_keySessionData);

    _userId = userId;
    final appVersion =
        await AppRuntimeMetadataService.instance.versionWithBuild;

    _sessionData = {
      'session_start': DateTime.now().toIso8601String(),
      'app_version': appVersion,
      'platform': defaultTargetPlatform.name,
      'session_id': _generateSessionId(),
    };

    AppLogger.info('Production analytics account scope updated');
  }

  /// Track user events for analytics
  Future<void> trackEvent(
    String eventName,
    Map<String, dynamic> properties,
  ) async {
    if (!_analyticsEnabled || !_isInitialized) return;

    try {
      final event = {
        'event_name': eventName,
        'timestamp': DateTime.now().toIso8601String(),
        'session_id': _sessionData['session_id'],
        'properties': properties,
      };

      await _storeEvent(event);
    } catch (e) {
      AppLogger.error('Failed to track event: $eventName', e);
    }
  }

  /// Release-validation navigation diagnostics.
  ///
  /// Disabled by default and enabled only with
  /// --dart-define=FLOW_AI_RUNTIME_DIAGNOSTICS=true.
  /// Persists route paths only; no user identity or route arguments.
  Future<void> recordNavigationDiagnostic({
    required String path,
    String? previousPath,
  }) async {
    if (!_runtimeDiagnosticsEnabled) return;
    if (path.isEmpty) return;

    try {
      final Directory directory;
      if (Platform.isAndroid) {
        directory =
            await getExternalStorageDirectory() ??
            await getApplicationSupportDirectory();
      } else {
        directory = await getApplicationSupportDirectory();
      }

      final file = File('${directory.path}/flow_runtime_navigation.jsonl');

      final safePath = path.replaceAll('"', r'\"');
      final safePrevious = previousPath?.replaceAll('"', r'\"');

      final line = StringBuffer()
        ..write('{"ts":"')
        ..write(DateTime.now().toUtc().toIso8601String())
        ..write('","type":"navigation","route":"')
        ..write(safePath)
        ..write('"');

      if (safePrevious != null && safePrevious.isNotEmpty) {
        line
          ..write(',"previous":"')
          ..write(safePrevious)
          ..write('"');
      }

      line.write('}\n');

      await file.writeAsString(
        line.toString(),
        mode: FileMode.append,
        flush: true,
      );
    } catch (e) {
      AppLogger.error('Failed to persist runtime navigation diagnostic', e);
    }
  }

  /// Track screen views
  Future<void> trackScreenView(
    String screenName, {
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent('screen_view', {
      'screen_name': screenName,
      'timestamp': DateTime.now().toIso8601String(),
      ...?properties,
    });
  }

  /// Track user actions
  Future<void> trackUserAction(
    String action, {
    Map<String, dynamic>? context,
  }) async {
    await trackEvent('user_action', {
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
      ...?context,
    });
  }

  /// Track monetization user actions without store credentials or receipt data.
  Future<void> trackMonetizationAction(
    String action, {
    String? platform,
    String? productId,
    String? result,
  }) async {
    await trackUserAction(
      action,
      context: <String, dynamic>{
        if (platform != null) 'platform': platform,
        if (productId != null) 'product_id': productId,
        if (result != null) 'result': result,
      },
    );
  }

  /// Track ad lifecycle using non-sensitive operational metadata only.
  Future<void> trackAdLifecycle(
    String phase, {
    required String format,
    String? result,
  }) async {
    await trackEvent('ad_lifecycle', <String, dynamic>{
      'phase': phase,
      'format': format,
      if (result != null) 'result': result,
    });
  }

  /// Track consent lifecycle without consent strings, identifiers or PII.
  Future<void> trackConsentLifecycle(
    String phase, {
    bool? canRequestAds,
    bool? privacyOptionsRequired,
    String? result,
  }) async {
    await trackEvent('consent_lifecycle', <String, dynamic>{
      'phase': phase,
      if (canRequestAds != null) 'can_request_ads': canRequestAds,
      if (privacyOptionsRequired != null)
        'privacy_options_required': privacyOptionsRequired,
      if (result != null) 'result': result,
    });
  }

  /// Track app performance metrics
  Future<void> trackPerformanceMetric(
    String metricName,
    double value, {
    String? unit,
  }) async {
    await trackEvent('performance_metric', {
      'metric_name': metricName,
      'value': value,
      'unit': unit ?? 'ms',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track errors and crashes
  Future<void> trackError(
    String errorType,
    String errorMessage, {
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
  Future<void> trackOnboardingStep(
    String stepName,
    bool completed, {
    int? stepNumber,
  }) async {
    await trackEvent('onboarding_step', {
      'step_name': stepName,
      'step_number': stepNumber,
      'completed': completed,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track feature usage
  Future<void> trackFeatureUsage(
    String featureName, {
    Map<String, dynamic>? metadata,
  }) async {
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
    return List.generate(
      length,
      (index) =>
          chars[(DateTime.now().millisecondsSinceEpoch + index) % chars.length],
    ).join();
  }

  /// Clear all stored analytics data (for privacy compliance)
  Future<void> clearAnalyticsData() async {
    await _prefs?.remove(_keyAppEvents);
    await _prefs?.remove(_keySessionData);

    _userId = null;
    _sessionData = {};

    AppLogger.info('Analytics data cleared');
  }

  /// Convenience methods for common events
  Future<void> trackAppStart() => trackEvent('app_start', {});
  Future<void> trackAppBackground() => trackEvent('app_background', {});
  Future<void> trackAppForeground() => trackEvent('app_foreground', {});

  Future<void> trackUserLogin(String method) =>
      trackEvent('user_login', {'method': method});
  Future<void> trackUserLogout() => trackEvent('user_logout', {});
  Future<void> trackUserSignup(String method) =>
      trackEvent('user_signup', {'method': method});

  Future<void> trackCycleAdded() => trackEvent('cycle_added', {});
  Future<void> trackSymptomLogged(String symptom) =>
      trackEvent('symptom_logged', {'symptom': symptom});
  Future<void> trackAIPredictionViewed() =>
      trackEvent('ai_prediction_viewed', {});
  Future<void> trackSettingsChanged(String setting) =>
      trackEvent('settings_changed', {'setting': setting});
}

/// Extension for easy analytics tracking
extension AnalyticsTracker on Object {
  Future<void> trackEvent(
    String eventName, [
    Map<String, dynamic>? properties,
  ]) async {
    await ProductionAnalyticsService().trackEvent(eventName, properties ?? {});
  }

  Future<void> trackScreen(String screenName) async {
    await ProductionAnalyticsService().trackScreenView(screenName);
  }
}
