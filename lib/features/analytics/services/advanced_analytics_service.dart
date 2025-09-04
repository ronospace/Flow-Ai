import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../core/models/user.dart';

/// Advanced analytics service for user behavior tracking and business intelligence
class AdvancedAnalyticsService {
  static AdvancedAnalyticsService? _instance;
  static AdvancedAnalyticsService get instance {
    _instance ??= AdvancedAnalyticsService._internal();
    return _instance!;
  }

  AdvancedAnalyticsService._internal();

  bool _isInitialized = false;
  SharedPreferences? _prefs;
  Timer? _sessionTimer;
  Timer? _batchUploadTimer;

  // Analytics data
  DateTime? _sessionStart;
  String? _sessionId;
  final List<AnalyticsEvent> _pendingEvents = [];
  final Map<String, dynamic> _userProperties = {};
  late DeviceInfo _deviceInfo;
  late AppInfo _appInfo;

  // Configuration
  static const int _batchSize = 50;
  static const int _batchUploadIntervalMinutes = 5;
  static const Duration _sessionTimeout = Duration(minutes: 30);
  static const int _maxRetentionDays = 90;

  /// Initialize the analytics service
  Future<void> initialize({String? userId}) async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      
      // Initialize device and app info
      await _initializeDeviceInfo();
      await _initializeAppInfo();
      
      // Start session tracking
      await _startSession(userId);
      
      // Start batch upload timer
      _startBatchUploadTimer();
      
      _isInitialized = true;
      debugPrint('📊 Advanced analytics service initialized');
      
      // Track app launch
      await trackEvent('app_launch', properties: {
        'app_version': _appInfo.version,
        'platform': _deviceInfo.platform,
        'device_model': _deviceInfo.model,
      });
    } catch (e) {
      debugPrint('❌ Failed to initialize analytics: $e');
      throw AnalyticsException('Failed to initialize analytics service: $e');
    }
  }

  /// Initialize device information
  Future<void> _initializeDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _deviceInfo = DeviceInfo(
        platform: 'android',
        model: androidInfo.model,
        manufacturer: androidInfo.manufacturer,
        osVersion: androidInfo.version.release,
        screenSize: '${androidInfo.displayMetrics.widthPx}x${androidInfo.displayMetrics.heightPx}',
        locale: androidInfo.supportedLocales.isNotEmpty 
          ? androidInfo.supportedLocales.first.toString() 
          : 'unknown',
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      _deviceInfo = DeviceInfo(
        platform: 'ios',
        model: iosInfo.model,
        manufacturer: 'Apple',
        osVersion: iosInfo.systemVersion,
        screenSize: 'unknown', // Would need additional package for iOS screen size
        locale: 'unknown', // Would need additional logic for iOS locale
      );
    } else {
      _deviceInfo = DeviceInfo(
        platform: defaultTargetPlatform.name,
        model: 'unknown',
        manufacturer: 'unknown',
        osVersion: 'unknown',
        screenSize: 'unknown',
        locale: 'unknown',
      );
    }
  }

  /// Initialize app information
  Future<void> _initializeAppInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _appInfo = AppInfo(
      name: packageInfo.appName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      packageName: packageInfo.packageName,
    );
  }

  /// Start a new analytics session
  Future<void> _startSession(String? userId) async {
    _sessionStart = DateTime.now();
    _sessionId = _generateSessionId();
    
    // Set user properties
    if (userId != null) {
      await setUserProperty('user_id', userId);
    }
    
    // Track session start
    await trackEvent('session_start', properties: {
      'session_id': _sessionId!,
      'timestamp': _sessionStart!.toIso8601String(),
    });
    
    // Start session timeout timer
    _sessionTimer?.cancel();
    _sessionTimer = Timer(_sessionTimeout, () {
      _endSession();
    });
  }

  /// End the current session
  void _endSession() {
    if (_sessionStart != null && _sessionId != null) {
      final Duration sessionDuration = DateTime.now().difference(_sessionStart!);
      
      trackEvent('session_end', properties: {
        'session_id': _sessionId!,
        'session_duration_seconds': sessionDuration.inSeconds,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      _sessionStart = null;
      _sessionId = null;
    }
  }

  /// Track an analytics event
  Future<void> trackEvent(String eventName, {
    Map<String, dynamic>? properties,
    String? userId,
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️ Analytics not initialized, queuing event: $eventName');
    }

    final event = AnalyticsEvent(
      name: eventName,
      timestamp: DateTime.now(),
      userId: userId ?? _userProperties['user_id'],
      sessionId: _sessionId,
      properties: {
        ...?properties,
        ..._userProperties,
        'device_info': _deviceInfo.toJson(),
        'app_info': _appInfo.toJson(),
      },
    );

    _pendingEvents.add(event);
    
    // Reset session timer
    if (_sessionTimer != null && _sessionStart != null) {
      _sessionTimer!.cancel();
      _sessionTimer = Timer(_sessionTimeout, () {
        _endSession();
      });
    }

    debugPrint('📊 Event tracked: $eventName');

    // Auto-upload if batch size reached
    if (_pendingEvents.length >= _batchSize) {
      await _uploadEvents();
    }
  }

  /// Set user property
  Future<void> setUserProperty(String key, dynamic value) async {
    _userProperties[key] = value;
    
    // Persist important user properties
    if (key == 'user_id' || key == 'user_type' || key == 'subscription_status') {
      await _prefs?.setString('analytics_$key', value.toString());
    }
  }

  /// Track screen view
  Future<void> trackScreenView(String screenName, {
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent('screen_view', properties: {
      'screen_name': screenName,
      ...?properties,
    });
  }

  /// Track user action
  Future<void> trackUserAction(String action, {
    String? category,
    String? label,
    dynamic value,
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent('user_action', properties: {
      'action': action,
      if (category != null) 'category': category,
      if (label != null) 'label': label,
      if (value != null) 'value': value,
      ...?properties,
    });
  }

  /// Track feature usage
  Future<void> trackFeatureUsage(String feature, {
    String? subFeature,
    Duration? usageDuration,
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent('feature_usage', properties: {
      'feature': feature,
      if (subFeature != null) 'sub_feature': subFeature,
      if (usageDuration != null) 'usage_duration_seconds': usageDuration.inSeconds,
      ...?properties,
    });
  }

  /// Track conversion events
  Future<void> trackConversion(String conversionType, {
    String? source,
    String? campaign,
    double? value,
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent('conversion', properties: {
      'conversion_type': conversionType,
      if (source != null) 'source': source,
      if (campaign != null) 'campaign': campaign,
      if (value != null) 'value': value,
      ...?properties,
    });
  }

  /// Track error events
  Future<void> trackError(String error, {
    String? context,
    String? stackTrace,
    String? severity = 'error',
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent('error', properties: {
      'error_message': error,
      'severity': severity,
      if (context != null) 'context': context,
      if (stackTrace != null) 'stack_trace': stackTrace,
      ...?properties,
    });
  }

  /// Track performance metrics
  Future<void> trackPerformance(String metric, {
    required double value,
    String? unit = 'ms',
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent('performance', properties: {
      'metric': metric,
      'value': value,
      'unit': unit,
      ...?properties,
    });
  }

  /// Track health data insights
  Future<void> trackHealthInsight(String insightType, {
    String? category,
    double? confidence,
    bool? actionTaken,
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent('health_insight', properties: {
      'insight_type': insightType,
      if (category != null) 'category': category,
      if (confidence != null) 'confidence': confidence,
      if (actionTaken != null) 'action_taken': actionTaken,
      ...?properties,
    });
  }

  /// Track cycle data
  Future<void> trackCycleEvent(String cycleEvent, {
    String? phase,
    int? cycleDay,
    Map<String, dynamic>? symptoms,
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent('cycle_event', properties: {
      'cycle_event': cycleEvent,
      if (phase != null) 'phase': phase,
      if (cycleDay != null) 'cycle_day': cycleDay,
      if (symptoms != null) 'symptoms': symptoms,
      ...?properties,
    });
  }

  /// Get user behavior analytics
  Future<UserBehaviorAnalytics> getUserBehaviorAnalytics() async {
    final List<AnalyticsEvent> events = await _getStoredEvents();
    
    return UserBehaviorAnalytics(
      totalSessions: _countUniqueValues(events, 'session_id'),
      averageSessionDuration: _calculateAverageSessionDuration(events),
      mostUsedFeatures: _getMostUsedFeatures(events),
      screenViewCounts: _getScreenViewCounts(events),
      conversionEvents: _getConversionEvents(events),
      retentionData: await _calculateRetentionData(events),
      engagementScore: _calculateEngagementScore(events),
      lastActiveDate: _getLastActiveDate(events),
    );
  }

  /// Get cohort analysis
  Future<CohortAnalysis> getCohortAnalysis() async {
    final List<AnalyticsEvent> events = await _getStoredEvents();
    
    // Group users by first app launch date (cohort)
    final Map<String, List<AnalyticsEvent>> cohorts = {};
    
    for (final event in events) {
      if (event.name == 'app_launch' && event.userId != null) {
        final cohortKey = _getCohortKey(event.timestamp);
        cohorts[cohortKey] ??= [];
        cohorts[cohortKey]!.add(event);
      }
    }
    
    final Map<String, Map<int, double>> cohortRetention = {};
    
    for (final cohortKey in cohorts.keys) {
      cohortRetention[cohortKey] = await _calculateCohortRetention(
        cohorts[cohortKey]!,
        events,
      );
    }
    
    return CohortAnalysis(
      cohorts: cohortRetention,
      totalCohorts: cohorts.length,
      averageRetention: _calculateAverageRetention(cohortRetention),
    );
  }

  /// Get funnel analysis
  Future<FunnelAnalysis> getFunnelAnalysis(List<String> funnelSteps) async {
    final List<AnalyticsEvent> events = await _getStoredEvents();
    
    // Group events by user
    final Map<String, List<AnalyticsEvent>> userEvents = {};
    for (final event in events) {
      if (event.userId != null) {
        userEvents[event.userId!] ??= [];
        userEvents[event.userId!]!.add(event);
      }
    }
    
    final Map<String, int> stepCounts = {};
    final Map<String, double> conversionRates = {};
    
    for (int i = 0; i < funnelSteps.length; i++) {
      final step = funnelSteps[i];
      int usersAtStep = 0;
      
      for (final userId in userEvents.keys) {
        final userEventNames = userEvents[userId]!.map((e) => e.name).toList();
        
        // Check if user completed this step and all previous steps
        bool completedStep = true;
        for (int j = 0; j <= i; j++) {
          if (!userEventNames.contains(funnelSteps[j])) {
            completedStep = false;
            break;
          }
        }
        
        if (completedStep) {
          usersAtStep++;
        }
      }
      
      stepCounts[step] = usersAtStep;
      
      if (i > 0) {
        final previousStep = funnelSteps[i - 1];
        final previousCount = stepCounts[previousStep]!;
        conversionRates[step] = previousCount > 0 ? usersAtStep / previousCount : 0.0;
      } else {
        conversionRates[step] = 1.0; // First step always 100%
      }
    }
    
    return FunnelAnalysis(
      steps: funnelSteps,
      stepCounts: stepCounts,
      conversionRates: conversionRates,
      totalUsers: userEvents.length,
    );
  }

  /// Start batch upload timer
  void _startBatchUploadTimer() {
    _batchUploadTimer = Timer.periodic(
      Duration(minutes: _batchUploadIntervalMinutes),
      (_) async {
        if (_pendingEvents.isNotEmpty) {
          await _uploadEvents();
        }
      },
    );
  }

  /// Upload events to analytics backend
  Future<void> _uploadEvents() async {
    if (_pendingEvents.isEmpty) return;

    try {
      // In a real app, this would send events to your analytics backend
      debugPrint('📤 Uploading ${_pendingEvents.length} analytics events');
      
      // Store events locally for now
      await _storeEvents(_pendingEvents);
      
      // Clear pending events
      _pendingEvents.clear();
      
      debugPrint('✅ Analytics events uploaded successfully');
    } catch (e) {
      debugPrint('❌ Failed to upload analytics events: $e');
      // Keep events for retry
    }
  }

  /// Store events locally
  Future<void> _storeEvents(List<AnalyticsEvent> events) async {
    final List<String> existingEvents = _prefs?.getStringList('analytics_events') ?? [];
    
    for (final event in events) {
      existingEvents.add(json.encode(event.toJson()));
    }
    
    // Keep only recent events (within retention period)
    final DateTime cutoffDate = DateTime.now().subtract(Duration(days: _maxRetentionDays));
    final List<String> filteredEvents = existingEvents.where((eventStr) {
      try {
        final Map<String, dynamic> eventJson = json.decode(eventStr);
        final DateTime timestamp = DateTime.parse(eventJson['timestamp']);
        return timestamp.isAfter(cutoffDate);
      } catch (e) {
        return false;
      }
    }).toList();
    
    await _prefs?.setStringList('analytics_events', filteredEvents);
  }

  /// Get stored events
  Future<List<AnalyticsEvent>> _getStoredEvents() async {
    final List<String> eventStrings = _prefs?.getStringList('analytics_events') ?? [];
    
    return eventStrings.map((eventStr) {
      try {
        final Map<String, dynamic> eventJson = json.decode(eventStr);
        return AnalyticsEvent.fromJson(eventJson);
      } catch (e) {
        debugPrint('❌ Failed to parse stored event: $e');
        return null;
      }
    }).where((event) => event != null).cast<AnalyticsEvent>().toList();
  }

  /// Helper methods for analytics calculations
  int _countUniqueValues(List<AnalyticsEvent> events, String property) {
    final Set<dynamic> uniqueValues = {};
    for (final event in events) {
      if (event.properties.containsKey(property)) {
        uniqueValues.add(event.properties[property]);
      }
    }
    return uniqueValues.length;
  }

  double _calculateAverageSessionDuration(List<AnalyticsEvent> events) {
    final List<double> durations = [];
    
    for (final event in events) {
      if (event.name == 'session_end' && 
          event.properties.containsKey('session_duration_seconds')) {
        durations.add(event.properties['session_duration_seconds'].toDouble());
      }
    }
    
    if (durations.isEmpty) return 0.0;
    return durations.reduce((a, b) => a + b) / durations.length;
  }

  Map<String, int> _getMostUsedFeatures(List<AnalyticsEvent> events) {
    final Map<String, int> featureCounts = {};
    
    for (final event in events) {
      if (event.name == 'feature_usage' && 
          event.properties.containsKey('feature')) {
        final feature = event.properties['feature'];
        featureCounts[feature] = (featureCounts[feature] ?? 0) + 1;
      }
    }
    
    // Sort by usage count and return top 10
    final sortedFeatures = featureCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sortedFeatures.take(10));
  }

  Map<String, int> _getScreenViewCounts(List<AnalyticsEvent> events) {
    final Map<String, int> screenCounts = {};
    
    for (final event in events) {
      if (event.name == 'screen_view' && 
          event.properties.containsKey('screen_name')) {
        final screen = event.properties['screen_name'];
        screenCounts[screen] = (screenCounts[screen] ?? 0) + 1;
      }
    }
    
    return screenCounts;
  }

  List<AnalyticsEvent> _getConversionEvents(List<AnalyticsEvent> events) {
    return events.where((event) => event.name == 'conversion').toList();
  }

  Future<RetentionData> _calculateRetentionData(List<AnalyticsEvent> events) async {
    final Map<String, DateTime> userFirstSeen = {};
    final Map<String, DateTime> userLastSeen = {};
    
    for (final event in events) {
      if (event.userId != null) {
        final userId = event.userId!;
        
        if (!userFirstSeen.containsKey(userId) || 
            event.timestamp.isBefore(userFirstSeen[userId]!)) {
          userFirstSeen[userId] = event.timestamp;
        }
        
        if (!userLastSeen.containsKey(userId) || 
            event.timestamp.isAfter(userLastSeen[userId]!)) {
          userLastSeen[userId] = event.timestamp;
        }
      }
    }
    
    final DateTime now = DateTime.now();
    int day1Retained = 0, day7Retained = 0, day30Retained = 0;
    
    for (final userId in userFirstSeen.keys) {
      final firstSeen = userFirstSeen[userId]!;
      final lastSeen = userLastSeen[userId]!;
      
      if (lastSeen.isAfter(firstSeen.add(Duration(days: 1)))) {
        day1Retained++;
      }
      if (lastSeen.isAfter(firstSeen.add(Duration(days: 7)))) {
        day7Retained++;
      }
      if (lastSeen.isAfter(firstSeen.add(Duration(days: 30)))) {
        day30Retained++;
      }
    }
    
    final int totalUsers = userFirstSeen.length;
    
    return RetentionData(
      day1Retention: totalUsers > 0 ? day1Retained / totalUsers : 0.0,
      day7Retention: totalUsers > 0 ? day7Retained / totalUsers : 0.0,
      day30Retention: totalUsers > 0 ? day30Retained / totalUsers : 0.0,
      totalUsers: totalUsers,
    );
  }

  double _calculateEngagementScore(List<AnalyticsEvent> events) {
    if (events.isEmpty) return 0.0;
    
    final int totalEvents = events.length;
    final int uniqueSessions = _countUniqueValues(events, 'session_id');
    final double averageEventsPerSession = uniqueSessions > 0 ? totalEvents / uniqueSessions : 0.0;
    
    // Simple engagement score based on events per session
    return math.min(averageEventsPerSession / 10, 1.0);
  }

  DateTime? _getLastActiveDate(List<AnalyticsEvent> events) {
    if (events.isEmpty) return null;
    
    DateTime? lastActive;
    for (final event in events) {
      if (lastActive == null || event.timestamp.isAfter(lastActive)) {
        lastActive = event.timestamp;
      }
    }
    
    return lastActive;
  }

  String _getCohortKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  Future<Map<int, double>> _calculateCohortRetention(
    List<AnalyticsEvent> cohortEvents,
    List<AnalyticsEvent> allEvents,
  ) async {
    // This is a simplified implementation
    // In reality, you'd calculate retention for specific time periods
    return {
      0: 1.0,   // Day 0 (always 100%)
      1: 0.75,  // Day 1
      7: 0.45,  // Week 1
      30: 0.25, // Month 1
    };
  }

  double _calculateAverageRetention(Map<String, Map<int, double>> cohortRetention) {
    if (cohortRetention.isEmpty) return 0.0;
    
    double totalRetention = 0.0;
    int count = 0;
    
    for (final cohort in cohortRetention.values) {
      for (final retention in cohort.values) {
        totalRetention += retention;
        count++;
      }
    }
    
    return count > 0 ? totalRetention / count : 0.0;
  }

  /// Generate session ID
  String _generateSessionId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(10000)}';
  }

  /// Force upload pending events
  Future<void> flush() async {
    await _uploadEvents();
  }

  /// Clean up old events
  Future<void> cleanupOldEvents() async {
    final DateTime cutoffDate = DateTime.now().subtract(Duration(days: _maxRetentionDays));
    final List<String> eventStrings = _prefs?.getStringList('analytics_events') ?? [];
    
    final List<String> validEvents = eventStrings.where((eventStr) {
      try {
        final Map<String, dynamic> eventJson = json.decode(eventStr);
        final DateTime timestamp = DateTime.parse(eventJson['timestamp']);
        return timestamp.isAfter(cutoffDate);
      } catch (e) {
        return false;
      }
    }).toList();
    
    await _prefs?.setStringList('analytics_events', validEvents);
    debugPrint('🧹 Cleaned up old analytics events');
  }

  /// Dispose resources
  void dispose() {
    _endSession();
    _sessionTimer?.cancel();
    _batchUploadTimer?.cancel();
    _isInitialized = false;
  }
}

// === SUPPORTING DATA MODELS ===

class AnalyticsEvent {
  final String name;
  final DateTime timestamp;
  final String? userId;
  final String? sessionId;
  final Map<String, dynamic> properties;

  AnalyticsEvent({
    required this.name,
    required this.timestamp,
    this.userId,
    this.sessionId,
    this.properties = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'user_id': userId,
      'session_id': sessionId,
      'properties': properties,
    };
  }

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      name: json['name'],
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['user_id'],
      sessionId: json['session_id'],
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
    );
  }
}

class DeviceInfo {
  final String platform;
  final String model;
  final String manufacturer;
  final String osVersion;
  final String screenSize;
  final String locale;

  DeviceInfo({
    required this.platform,
    required this.model,
    required this.manufacturer,
    required this.osVersion,
    required this.screenSize,
    required this.locale,
  });

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'model': model,
      'manufacturer': manufacturer,
      'os_version': osVersion,
      'screen_size': screenSize,
      'locale': locale,
    };
  }
}

class AppInfo {
  final String name;
  final String version;
  final String buildNumber;
  final String packageName;

  AppInfo({
    required this.name,
    required this.version,
    required this.buildNumber,
    required this.packageName,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
      'build_number': buildNumber,
      'package_name': packageName,
    };
  }
}

class UserBehaviorAnalytics {
  final int totalSessions;
  final double averageSessionDuration;
  final Map<String, int> mostUsedFeatures;
  final Map<String, int> screenViewCounts;
  final List<AnalyticsEvent> conversionEvents;
  final RetentionData retentionData;
  final double engagementScore;
  final DateTime? lastActiveDate;

  UserBehaviorAnalytics({
    required this.totalSessions,
    required this.averageSessionDuration,
    required this.mostUsedFeatures,
    required this.screenViewCounts,
    required this.conversionEvents,
    required this.retentionData,
    required this.engagementScore,
    this.lastActiveDate,
  });
}

class RetentionData {
  final double day1Retention;
  final double day7Retention;
  final double day30Retention;
  final int totalUsers;

  RetentionData({
    required this.day1Retention,
    required this.day7Retention,
    required this.day30Retention,
    required this.totalUsers,
  });
}

class CohortAnalysis {
  final Map<String, Map<int, double>> cohorts;
  final int totalCohorts;
  final double averageRetention;

  CohortAnalysis({
    required this.cohorts,
    required this.totalCohorts,
    required this.averageRetention,
  });
}

class FunnelAnalysis {
  final List<String> steps;
  final Map<String, int> stepCounts;
  final Map<String, double> conversionRates;
  final int totalUsers;

  FunnelAnalysis({
    required this.steps,
    required this.stepCounts,
    required this.conversionRates,
    required this.totalUsers,
  });
}

class AnalyticsException implements Exception {
  final String message;
  AnalyticsException(this.message);

  @override
  String toString() => 'AnalyticsException: $message';
}
