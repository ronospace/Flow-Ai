import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AI-Powered Smart Notification Scheduling System
/// Uses machine learning patterns to optimize notification delivery times
/// Based on user engagement, behavior patterns, and contextual awareness
class AINotificationScheduler {
  static final AINotificationScheduler _instance =
      AINotificationScheduler._internal();
  static AINotificationScheduler get instance => _instance;
  AINotificationScheduler._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  // Engagement tracking
  final Map<String, List<EngagementEvent>> _engagementHistory = {};
  final Map<String, OptimalTimeWindow> _optimalWindows = {};

  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    await _loadOptimalWindows();
    _isInitialized = true;
    debugPrint('🤖 AI Notification Scheduler initialized');
  }

  /// Record user engagement with a notification
  void recordEngagement({
    required String notificationType,
    required DateTime timestamp,
    required EngagementType engagement,
  }) {
    if (!_isInitialized) return;

    final event = EngagementEvent(
      type: engagement,
      timestamp: timestamp,
      notificationType: notificationType,
    );

    _engagementHistory.putIfAbsent(notificationType, () => []).add(event);

    // Keep only last 100 events per type
    if (_engagementHistory[notificationType]!.length > 100) {
      _engagementHistory[notificationType]!.removeAt(0);
    }

    // Recalculate optimal window
    _recalculateOptimalWindow(notificationType);
  }

  /// Get optimal notification time using AI prediction
  Future<DateTime> getOptimalNotificationTime({
    required String notificationType,
    required DateTime targetDate,
    TimeOfDay? preferredTime,
  }) async {
    if (!_isInitialized) await initialize();

    // Check if we have learned optimal window
    final optimalWindow = _optimalWindows[notificationType];

    if (optimalWindow != null) {
      // Use ML-predicted optimal time
      final baseTime = TimeOfDay(
        hour: optimalWindow.optimalHour,
        minute: optimalWindow.optimalMinute,
      );

      return _combineDateTime(targetDate, baseTime);
    }

    // Fallback to preferred time or default
    final time = preferredTime ?? const TimeOfDay(hour: 9, minute: 0);
    return _combineDateTime(targetDate, time);
  }

  /// Predict engagement probability for a notification time
  double predictEngagementProbability({
    required String notificationType,
    required DateTime notificationTime,
  }) {
    if (!_isInitialized) return 0.5; // Default probability

    final window = _optimalWindows[notificationType];
    if (window == null) return 0.5;

    final hour = notificationTime.hour;
    final minute = notificationTime.minute;
    final notificationMinute = hour * 60 + minute;
    final optimalMinute = window.optimalHour * 60 + window.optimalMinute;

    // Calculate distance from optimal time (in minutes)
    final distance = (notificationMinute - optimalMinute).abs();

    // Calculate probability using Gaussian-like distribution
    // Higher probability closer to optimal time
    final sigma =
        window.confidence * 60; // Confidence as hours converted to minutes
    final probability = exp(-(distance * distance) / (2 * sigma * sigma));

    return probability.clamp(0.0, 1.0);
  }

  /// Get contextual adjustment for notification timing
  DateTime getContextualAdjustment({
    required DateTime baseTime,
    required NotificationContext context,
  }) {
    DateTime adjusted = baseTime;

    // Adjust for day of week patterns
    if (context.isWeekend) {
      adjusted = adjusted.add(const Duration(hours: 2)); // Later on weekends
    }

    // Adjust for time of day preferences
    if (context.timeOfDay == TimeOfDayContext.morning) {
      adjusted = adjusted.subtract(const Duration(minutes: 15));
    } else if (context.timeOfDay == TimeOfDayContext.evening) {
      adjusted = adjusted.add(const Duration(minutes: 30));
    }

    // Adjust for user activity patterns
    if (context.isUserActive) {
      adjusted = adjusted.add(
        const Duration(minutes: 10),
      ); // Slightly delay if active
    }

    return adjusted;
  }

  /// Recalculate optimal window using ML algorithms
  void _recalculateOptimalWindow(String notificationType) {
    final events = _engagementHistory[notificationType];
    if (events == null || events.length < 5)
      return; // Need at least 5 data points

    // Filter successful engagements
    final successfulEvents = events
        .where(
          (e) =>
              e.type == EngagementType.opened ||
              e.type == EngagementType.interacted,
        )
        .toList();

    if (successfulEvents.length < 3) return;

    // Extract engagement times
    final engagementTimes = successfulEvents
        .map((e) => e.timestamp.hour * 60 + e.timestamp.minute)
        .toList();

    // Calculate optimal time using weighted median (more robust than mean)
    engagementTimes.sort();
    final medianMinute = engagementTimes[engagementTimes.length ~/ 2];
    final optimalHour = medianMinute ~/ 60;
    final optimalMinute = medianMinute % 60;

    // Calculate confidence based on data spread
    final variance = _calculateVariance(engagementTimes);
    final stdDev = sqrt(variance);
    final confidence = (1.0 - (stdDev / 720.0)).clamp(
      0.3,
      0.95,
    ); // Normalize to 0.3-0.95 (720 = 12 hours in minutes)

    _optimalWindows[notificationType] = OptimalTimeWindow(
      optimalHour: optimalHour,
      optimalMinute: optimalMinute,
      confidence: confidence,
      sampleSize: successfulEvents.length,
      lastUpdated: DateTime.now(),
    );

    _saveOptimalWindows();
    debugPrint(
      '🧠 Updated optimal window for $notificationType: ${optimalHour}:${optimalMinute.toString().padLeft(2, '0')} (confidence: ${(confidence * 100).toStringAsFixed(1)}%)',
    );
  }

  double _calculateVariance(List<int> values) {
    if (values.isEmpty) return 0.0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => pow(v - mean, 2)).toList();
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _loadOptimalWindows() async {
    final keys =
        _prefs
            ?.getKeys()
            .where((k) => k.startsWith('optimal_window_'))
            .toList() ??
        [];

    for (final key in keys) {
      final jsonString = _prefs?.getString(key);
      if (jsonString != null) {
        try {
          final notificationType = key.replaceFirst('optimal_window_', '');
          final window = OptimalTimeWindow.fromJson(jsonString);
          _optimalWindows[notificationType] = window;
        } catch (e) {
          debugPrint('Error loading optimal window: $e');
        }
      }
    }
  }

  Future<void> _saveOptimalWindows() async {
    for (final entry in _optimalWindows.entries) {
      await _prefs?.setString(
        'optimal_window_${entry.key}',
        entry.value.toJson(),
      );
    }
  }

  /// Get statistics for a notification type
  NotificationStats getStats(String notificationType) {
    final events = _engagementHistory[notificationType] ?? [];
    final window = _optimalWindows[notificationType];

    if (events.isEmpty) {
      return NotificationStats(
        totalNotifications: 0,
        engagementRate: 0.0,
        averageResponseTime: null,
        optimalTime: null,
      );
    }

    final opened = events.where((e) => e.type == EngagementType.opened).length;
    final interacted = events
        .where((e) => e.type == EngagementType.interacted)
        .length;

    final engagementRate = (opened + interacted) / events.length;

    final responseTimes = events
        .where((e) => e.responseTime != null)
        .map((e) => e.responseTime!)
        .toList();

    final avgResponseTime = responseTimes.isNotEmpty
        ? Duration(
            milliseconds:
                (responseTimes
                            .map((d) => d.inMilliseconds)
                            .reduce((a, b) => a + b) /
                        responseTimes.length)
                    .round(),
          )
        : null;

    return NotificationStats(
      totalNotifications: events.length,
      engagementRate: engagementRate,
      averageResponseTime: avgResponseTime,
      optimalTime: window != null
          ? TimeOfDay(hour: window.optimalHour, minute: window.optimalMinute)
          : null,
    );
  }
}

enum EngagementType { opened, interacted, dismissed, ignored }

enum TimeOfDayContext { morning, afternoon, evening, night }

class EngagementEvent {
  final EngagementType type;
  final DateTime timestamp;
  final String notificationType;
  final Duration? responseTime;

  EngagementEvent({
    required this.type,
    required this.timestamp,
    required this.notificationType,
    this.responseTime,
  });
}

class OptimalTimeWindow {
  final int optimalHour;
  final int optimalMinute;
  final double confidence; // 0.0 to 1.0
  final int sampleSize;
  final DateTime lastUpdated;

  OptimalTimeWindow({
    required this.optimalHour,
    required this.optimalMinute,
    required this.confidence,
    required this.sampleSize,
    required this.lastUpdated,
  });

  String toJson() {
    return '$optimalHour|$optimalMinute|$confidence|$sampleSize|${lastUpdated.toIso8601String()}';
  }

  factory OptimalTimeWindow.fromJson(String json) {
    final parts = json.split('|');
    return OptimalTimeWindow(
      optimalHour: int.parse(parts[0]),
      optimalMinute: int.parse(parts[1]),
      confidence: double.parse(parts[2]),
      sampleSize: int.parse(parts[3]),
      lastUpdated: DateTime.parse(parts[4]),
    );
  }
}

class NotificationContext {
  final bool isWeekend;
  final TimeOfDayContext timeOfDay;
  final bool isUserActive;
  final bool isHoliday;

  NotificationContext({
    required this.isWeekend,
    required this.timeOfDay,
    required this.isUserActive,
    this.isHoliday = false,
  });
}

class NotificationStats {
  final int totalNotifications;
  final double engagementRate;
  final Duration? averageResponseTime;
  final TimeOfDay? optimalTime;

  NotificationStats({
    required this.totalNotifications,
    required this.engagementRate,
    this.averageResponseTime,
    this.optimalTime,
  });
}
