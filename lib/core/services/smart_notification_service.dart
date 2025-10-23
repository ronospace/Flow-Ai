import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/cycle_data.dart';
import '../models/biometric_data.dart';
import 'enhanced_ai_engine.dart';
import 'biometric_integration_service.dart';

/// AI-powered smart notification system for personalized cycle and health insights
class SmartNotificationService {
  static final SmartNotificationService _instance = SmartNotificationService._internal();
  static SmartNotificationService get instance => _instance;
  SmartNotificationService._internal();

  bool _isInitialized = false;
  Timer? _notificationTimer;
  Timer? _insightTimer;
  Timer? _biometricAnalysisTimer;
  
  // Notification preferences
  final Map<String, bool> _notificationPreferences = {
    'cycle_predictions': true,
    'fertile_window_alerts': true,
    'symptom_reminders': true,
    'medication_reminders': true,
    'biometric_insights': true,
    'health_anomalies': true,
    'daily_check_ins': true,
    'ai_coaching': true,
  };

  final Map<String, TimeOfDay> _notificationTimes = {
    'morning_insight': TimeOfDay(hour: 9, minute: 0),
    'evening_reflection': TimeOfDay(hour: 21, minute: 0),
    'medication_reminder': TimeOfDay(hour: 8, minute: 0),
  };

  final List<SmartNotification> _pendingNotifications = [];
  final List<SmartNotification> _deliveredNotifications = [];

  static const _notificationChannel = MethodChannel('flowsense.notifications/smart');
  
  bool get isInitialized => _isInitialized;
  Map<String, bool> get preferences => Map.from(_notificationPreferences);

  /// Initialize the smart notification system
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    debugPrint('🔔 Initializing Smart Notification Service...');
    
    try {
      // Request notification permissions
      await _requestNotificationPermissions();
      
      // Load user preferences
      await _loadUserPreferences();
      
      // Set up notification channels
      await _setupNotificationChannels();
      
      // Start background processing timers
      _startNotificationTimers();
      
      _isInitialized = true;
      debugPrint('✅ Smart Notification Service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize Smart Notification Service: $e');
    }
  }

  /// Request notification permissions from the system
  Future<bool> _requestNotificationPermissions() async {
    try {
      final result = await _notificationChannel.invokeMethod('requestPermissions');
      return result as bool? ?? false;
    } catch (e) {
      debugPrint('Failed to request notification permissions: $e');
      return false;
    }
  }

  /// Load user's notification preferences
  Future<void> _loadUserPreferences() async {
    // In a real app, this would load from persistent storage
    // For now, use defaults
    debugPrint('📱 Loaded notification preferences');
  }

  /// Set up system notification channels
  Future<void> _setupNotificationChannels() async {
    try {
      await _notificationChannel.invokeMethod('setupChannels', {
        'channels': [
          {
            'id': 'cycle_insights',
            'name': 'Cycle Insights',
            'description': 'AI-powered cycle predictions and insights',
            'importance': 'high',
          },
          {
            'id': 'health_alerts',
            'name': 'Health Alerts',
            'description': 'Important health notifications and anomalies',
            'importance': 'high',
          },
          {
            'id': 'daily_reminders',
            'name': 'Daily Reminders',
            'description': 'Check-ins, medication, and tracking reminders',
            'importance': 'default',
          },
          {
            'id': 'ai_coaching',
            'name': 'AI Coaching',
            'description': 'Personalized coaching tips and recommendations',
            'importance': 'default',
          },
        ],
      });
    } catch (e) {
      debugPrint('Failed to setup notification channels: $e');
    }
  }

  /// Start background timers for smart notifications
  void _startNotificationTimers() {
    // Main notification processing timer (runs every 15 minutes)
    _notificationTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      _processSmartNotifications();
    });

    // AI insight generation timer (runs every hour)
    _insightTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _generateAIInsightNotifications();
    });

    // Biometric analysis timer (runs every 30 minutes)
    _biometricAnalysisTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _processBiometricAlerts();
    });

    debugPrint('⏰ Smart notification timers started');
  }

  /// Process and generate smart notifications based on current context
  Future<void> _processSmartNotifications() async {
    if (!_isInitialized) return;

    final currentTime = DateTime.now();
    final notifications = <SmartNotification>[];

    // Generate different types of notifications based on time and context
    notifications.addAll(await _generateCycleNotifications(currentTime));
    notifications.addAll(await _generateBiometricNotifications(currentTime));
    notifications.addAll(await _generateReminderNotifications(currentTime));
    notifications.addAll(await _generateCoachingNotifications(currentTime));

    // Prioritize and schedule notifications
    for (final notification in notifications) {
      await _scheduleNotification(notification);
    }
  }

  /// Generate cycle-related notifications
  Future<List<SmartNotification>> _generateCycleNotifications(DateTime currentTime) async {
    final notifications = <SmartNotification>[];
    
    if (!_notificationPreferences['cycle_predictions']!) return notifications;

    try {
      // Get recent cycle data for analysis
      // In a real app, this would come from the cycle provider
      final mockCycles = _generateMockCycleData();
      
      // Generate AI predictions
      final aiEngine = EnhancedAIEngine.instance;
      if (aiEngine.isInitialized) {
        final prediction = await aiEngine.predictNextCycleAdvanced(mockCycles);
        
        // Check if we should send a cycle prediction alert
        final daysUntilNextCycle = prediction.predictedStartDate.difference(currentTime).inDays;
        
        if (daysUntilNextCycle <= 3 && daysUntilNextCycle > 0) {
          notifications.add(SmartNotification(
            id: 'cycle_prediction_${currentTime.millisecondsSinceEpoch}',
            type: NotificationType.cyclePrediction,
            title: 'Cycle Starting Soon 🌸',
            message: 'Your next cycle is predicted to start in $daysUntilNextCycle days (${prediction.confidence * 100}% confidence)',
            scheduledTime: currentTime.add(const Duration(minutes: 5)),
            priority: NotificationPriority.high,
            actionData: {
              'predicted_date': prediction.predictedStartDate.toIso8601String(),
              'confidence': prediction.confidence,
            },
          ));
        }

        // Fertile window notifications
        if (_notificationPreferences['fertile_window_alerts']!) {
          final fertileStart = prediction.fertileWindow.start;
          final daysUntilFertile = fertileStart.difference(currentTime).inDays;
          
          if (daysUntilFertile <= 2 && daysUntilFertile >= 0) {
            notifications.add(SmartNotification(
              id: 'fertile_window_${currentTime.millisecondsSinceEpoch}',
              type: NotificationType.fertileWindow,
              title: 'Fertile Window Approaching 🌟',
              message: daysUntilFertile == 0 
                  ? 'Your fertile window starts today!'
                  : 'Your fertile window starts in $daysUntilFertile days',
              scheduledTime: currentTime.add(const Duration(minutes: 10)),
              priority: NotificationPriority.high,
              actionData: {
                'fertile_start': fertileStart.toIso8601String(),
                'fertile_end': prediction.fertileWindow.end.toIso8601String(),
              },
            ));
          }
        }
      }
    } catch (e) {
      debugPrint('Error generating cycle notifications: $e');
    }

    return notifications;
  }

  /// Generate biometric-based notifications
  Future<List<SmartNotification>> _generateBiometricNotifications(DateTime currentTime) async {
    final notifications = <SmartNotification>[];
    
    if (!_notificationPreferences['biometric_insights']!) return notifications;

    try {
      final biometricService = BiometricIntegrationService.instance;
      if (biometricService.isInitialized && biometricService.hasHealthPermission) {
        
        // Get recent biometric analysis
        final analysis = await biometricService.getBiometricAnalysis(
          startDate: currentTime.subtract(const Duration(days: 1)),
          endDate: currentTime,
        );

        // Check for health anomalies
        if (_notificationPreferences['health_anomalies']!) {
          final anomalies = await _detectBiometricAnomalies(analysis);
          for (final anomaly in anomalies) {
            notifications.add(SmartNotification(
              id: 'health_anomaly_${anomaly.hashCode}',
              type: NotificationType.healthAnomaly,
              title: 'Health Pattern Alert 📊',
              message: anomaly,
              scheduledTime: currentTime.add(const Duration(minutes: 2)),
              priority: NotificationPriority.high,
              actionData: {'anomaly_type': 'biometric_pattern'},
            ));
          }
        }

        // Sleep quality insights
        if (analysis.sleepData.isNotEmpty) {
          final recentSleep = analysis.sleepData.last;
          if (recentSleep.value < 0.6) { // Poor sleep quality
            notifications.add(SmartNotification(
              id: 'sleep_insight_${currentTime.millisecondsSinceEpoch}',
              type: NotificationType.healthInsight,
              title: 'Sleep Quality Alert 😴',
              message: 'Your sleep quality was ${(recentSleep.value * 100).round()}% last night. This may affect your cycle patterns.',
              scheduledTime: currentTime.add(const Duration(hours: 1)),
              priority: NotificationPriority.medium,
              actionData: {'sleep_quality': recentSleep.value},
            ));
          }
        }

        // Heart rate variability insights
        if (analysis.hrvData.isNotEmpty) {
          final avgHRV = analysis.hrvData.map((r) => r.value).reduce((a, b) => a + b) / analysis.hrvData.length;
          if (avgHRV < 30) { // Low HRV may indicate stress
            notifications.add(SmartNotification(
              id: 'hrv_insight_${currentTime.millisecondsSinceEpoch}',
              type: NotificationType.wellnessCoaching,
              title: 'Stress Recovery Insight 💚',
              message: 'Your heart rate variability suggests elevated stress. Consider some relaxation techniques today.',
              scheduledTime: currentTime.add(const Duration(minutes: 30)),
              priority: NotificationPriority.medium,
              actionData: {'avg_hrv': avgHRV},
            ));
          }
        }
      }
    } catch (e) {
      debugPrint('Error generating biometric notifications: $e');
    }

    return notifications;
  }

  /// Generate reminder notifications
  Future<List<SmartNotification>> _generateReminderNotifications(DateTime currentTime) async {
    final notifications = <SmartNotification>[];
    
    // Daily tracking reminder
    if (_notificationPreferences['daily_check_ins']!) {
      final morningTime = _notificationTimes['morning_insight']!;
      final morningToday = DateTime(
        currentTime.year, 
        currentTime.month, 
        currentTime.day, 
        morningTime.hour, 
        morningTime.minute
      );

      if (_shouldSendDailyReminder(currentTime, morningToday)) {
        notifications.add(SmartNotification(
          id: 'daily_checkin_${currentTime.day}',
          type: NotificationType.dailyReminder,
          title: 'Good Morning! ☀️',
          message: 'Ready to track your day? Log your morning symptoms and mood.',
          scheduledTime: morningToday,
          priority: NotificationPriority.medium,
          actionData: {'reminder_type': 'morning_checkin'},
        ));
      }

      // Evening reflection reminder
      final eveningTime = _notificationTimes['evening_reflection']!;
      final eveningToday = DateTime(
        currentTime.year, 
        currentTime.month, 
        currentTime.day, 
        eveningTime.hour, 
        eveningTime.minute
      );

      if (_shouldSendEveningReminder(currentTime, eveningToday)) {
        notifications.add(SmartNotification(
          id: 'evening_reflection_${currentTime.day}',
          type: NotificationType.dailyReminder,
          title: 'Evening Reflection 🌙',
          message: 'How was your day? Complete your daily tracking to see patterns.',
          scheduledTime: eveningToday,
          priority: NotificationPriority.low,
          actionData: {'reminder_type': 'evening_reflection'},
        ));
      }
    }

    // Medication reminders (placeholder - would integrate with user's medication schedule)
    if (_notificationPreferences['medication_reminders']!) {
      // This would be based on user's actual medication schedule
      notifications.add(SmartNotification(
        id: 'medication_reminder_${currentTime.day}',
        type: NotificationType.medicationReminder,
        title: 'Medication Reminder 💊',
        message: 'Time for your daily supplement',
        scheduledTime: currentTime.add(const Duration(minutes: 5)),
        priority: NotificationPriority.high,
        actionData: {'medication_type': 'daily_supplement'},
      ));
    }

    return notifications;
  }

  /// Generate AI coaching notifications
  Future<List<SmartNotification>> _generateCoachingNotifications(DateTime currentTime) async {
    final notifications = <SmartNotification>[];
    
    if (!_notificationPreferences['ai_coaching']!) return notifications;

    try {
      final coachingTips = await _generatePersonalizedCoachingTips();
      
      if (coachingTips.isNotEmpty) {
        final tip = coachingTips[math.Random().nextInt(coachingTips.length)];
        
        notifications.add(SmartNotification(
          id: 'coaching_tip_${currentTime.millisecondsSinceEpoch}',
          type: NotificationType.aiCoaching,
          title: 'AI Coach Tip 🤖',
          message: tip,
          scheduledTime: currentTime.add(const Duration(hours: 2)),
          priority: NotificationPriority.low,
          actionData: {'coaching_category': 'personalized_tip'},
        ));
      }
    } catch (e) {
      debugPrint('Error generating coaching notifications: $e');
    }

    return notifications;
  }

  /// Generate AI insight notifications
  Future<void> _generateAIInsightNotifications() async {
    if (!_notificationPreferences['ai_coaching']!) return;

    try {
      final aiEngine = EnhancedAIEngine.instance;
      if (aiEngine.isInitialized) {
        final mockCycles = _generateMockCycleData();
        final insights = await aiEngine.generateAdvancedInsights(mockCycles);
        
        for (final insight in insights.take(1)) { // Only send the top insight
          final notification = SmartNotification(
            id: 'ai_insight_${DateTime.now().millisecondsSinceEpoch}',
            type: NotificationType.aiInsight,
            title: insight.title,
            message: insight.description,
            scheduledTime: DateTime.now().add(const Duration(minutes: 30)),
            priority: NotificationPriority.medium,
            actionData: {
              'insight_type': insight.type.toString(),
              'confidence': insight.confidence,
            },
          );
          
          await _scheduleNotification(notification);
        }
      }
    } catch (e) {
      debugPrint('Error generating AI insight notifications: $e');
    }
  }

  /// Process biometric alerts
  Future<void> _processBiometricAlerts() async {
    if (!_notificationPreferences['biometric_insights']!) return;

    try {
      final biometricService = BiometricIntegrationService.instance;
      if (biometricService.isInitialized) {
        final analysis = await biometricService.getBiometricAnalysis();
        
        // Check for immediate alerts that need attention
        final urgentAlerts = await _checkForUrgentBiometricAlerts(analysis);
        
        for (final alert in urgentAlerts) {
          await _scheduleNotification(alert);
        }
      }
    } catch (e) {
      debugPrint('Error processing biometric alerts: $e');
    }
  }

  /// Schedule a notification for delivery
  Future<void> _scheduleNotification(SmartNotification notification) async {
    try {
      // Check if we should actually send this notification
      if (!_shouldDeliverNotification(notification)) {
        return;
      }

      // Add to pending queue
      _pendingNotifications.add(notification);

      // Schedule with system
      await _notificationChannel.invokeMethod('scheduleNotification', {
        'id': notification.id,
        'title': notification.title,
        'message': notification.message,
        'scheduledTime': notification.scheduledTime.millisecondsSinceEpoch,
        'channel': _getChannelForType(notification.type),
        'priority': notification.priority.name,
        'actionData': notification.actionData,
      });

      debugPrint('📱 Scheduled notification: ${notification.title}');
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }

  /// Check if a notification should be delivered
  bool _shouldDeliverNotification(SmartNotification notification) {
    // Check if we've already sent this type recently
    final recentSimilar = _deliveredNotifications
        .where((n) => n.type == notification.type)
        .where((n) => DateTime.now().difference(n.deliveredAt!).inHours < 6);

    if (recentSimilar.isNotEmpty && notification.priority != NotificationPriority.high) {
      return false;
    }

    // Don't send during quiet hours (10 PM - 7 AM)
    final hour = notification.scheduledTime.hour;
    if (hour >= 22 || hour <= 7) {
      if (notification.priority != NotificationPriority.high) {
        return false;
      }
    }

    return true;
  }

  /// Get notification channel for a notification type
  String _getChannelForType(NotificationType type) {
    switch (type) {
      case NotificationType.cyclePrediction:
      case NotificationType.fertileWindow:
        return 'cycle_insights';
      case NotificationType.healthAnomaly:
      case NotificationType.healthInsight:
        return 'health_alerts';
      case NotificationType.dailyReminder:
      case NotificationType.medicationReminder:
        return 'daily_reminders';
      case NotificationType.aiCoaching:
      case NotificationType.aiInsight:
      case NotificationType.wellnessCoaching:
        return 'ai_coaching';
      default:
        return 'cycle_insights';
    }
  }

  /// Update notification preferences
  Future<void> updatePreferences(Map<String, bool> newPreferences) async {
    _notificationPreferences.addAll(newPreferences);
    // In a real app, save to persistent storage
    debugPrint('📝 Updated notification preferences');
  }

  /// Update notification times
  Future<void> updateNotificationTimes(Map<String, TimeOfDay> newTimes) async {
    _notificationTimes.addAll(newTimes);
    // In a real app, save to persistent storage
    debugPrint('⏰ Updated notification times');
  }

  /// Get delivered notifications history
  List<SmartNotification> getNotificationHistory({int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _deliveredNotifications
        .where((n) => n.deliveredAt?.isAfter(cutoff) ?? false)
        .toList();
  }

  // === HELPER METHODS ===

  List<CycleData> _generateMockCycleData() {
    // Generate mock data for development
    final now = DateTime.now();
    return List.generate(3, (index) {
      final startDate = now.subtract(Duration(days: 30 * (index + 1)));
      return CycleData(
        id: 'mock_$index',
        userId: 'mock_user',
        startDate: startDate,
        endDate: startDate.add(Duration(days: 28)),
        cycleLength: 28 + index,
        dailyData: {},
        flowIntensity: FlowIntensity.medium,
        symptoms: ['cramps', 'fatigue'],
        mood: 3.5,
        energy: 3.0,
        pain: 2.5,
        createdAt: startDate,
        lastUpdated: startDate,
      );
    });
  }

  Future<List<String>> _detectBiometricAnomalies(BiometricAnalysis analysis) async {
    final anomalies = <String>[];

    // Heart rate anomalies
    if (analysis.heartRateData.isNotEmpty) {
      final avgHR = analysis.heartRateData.map((r) => r.value).reduce((a, b) => a + b) / analysis.heartRateData.length;
      if (avgHR > 100) {
        anomalies.add('Your average heart rate has been elevated (${avgHR.round()} BPM)');
      }
    }

    // Temperature anomalies
    if (analysis.temperatureData.isNotEmpty) {
      final avgTemp = analysis.temperatureData.map((r) => r.value).reduce((a, b) => a + b) / analysis.temperatureData.length;
      if (avgTemp > 99.5) {
        anomalies.add('Your body temperature has been elevated (${avgTemp.toStringAsFixed(1)}°F)');
      }
    }

    return anomalies;
  }

  bool _shouldSendDailyReminder(DateTime currentTime, DateTime reminderTime) {
    // Send if it's past the reminder time and we haven't sent today
    return currentTime.isAfter(reminderTime) && 
           !_deliveredNotifications.any((n) => 
               n.type == NotificationType.dailyReminder &&
               n.deliveredAt?.day == currentTime.day);
  }

  bool _shouldSendEveningReminder(DateTime currentTime, DateTime reminderTime) {
    return currentTime.isAfter(reminderTime) && 
           !_deliveredNotifications.any((n) => 
               n.id.contains('evening_reflection') &&
               n.deliveredAt?.day == currentTime.day);
  }

  Future<List<String>> _generatePersonalizedCoachingTips() async {
    return [
      'Staying hydrated can help reduce bloating and cramping during your cycle.',
      'Regular exercise, even light walking, can help improve mood and energy levels.',
      'Getting consistent sleep supports hormone regulation and cycle regularity.',
      'Tracking your symptoms can help identify patterns and improve predictions.',
      'Stress management techniques like deep breathing can help with PMS symptoms.',
    ];
  }

  Future<List<SmartNotification>> _checkForUrgentBiometricAlerts(BiometricAnalysis analysis) async {
    final alerts = <SmartNotification>[];

    // Check for critical health patterns that need immediate attention
    // This is a simplified example - real implementation would be more sophisticated
    
    if (analysis.stressData.isNotEmpty) {
      final avgStress = analysis.stressData.map((r) => r.value).reduce((a, b) => a + b) / analysis.stressData.length;
      if (avgStress > 8.0) { // Very high stress
        alerts.add(SmartNotification(
          id: 'urgent_stress_${DateTime.now().millisecondsSinceEpoch}',
          type: NotificationType.healthAnomaly,
          title: 'High Stress Alert ⚠️',
          message: 'Your stress levels have been consistently high. Consider taking a break.',
          scheduledTime: DateTime.now().add(const Duration(minutes: 1)),
          priority: NotificationPriority.high,
          actionData: {'stress_level': avgStress},
        ));
      }
    }

    return alerts;
  }

  /// Clean up resources
  void dispose() {
    _notificationTimer?.cancel();
    _insightTimer?.cancel();
    _biometricAnalysisTimer?.cancel();
    _isInitialized = false;
    debugPrint('🔔 Smart Notification Service disposed');
  }
}

/// Notification types for different categories
enum NotificationType {
  cyclePrediction,
  fertileWindow,
  dailyReminder,
  medicationReminder,
  healthAnomaly,
  healthInsight,
  aiCoaching,
  aiInsight,
  wellnessCoaching,
}

/// Notification priority levels
enum NotificationPriority {
  low,
  medium,
  high,
}

/// Time of day helper class
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});
  
  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// Smart notification data model
@immutable
class SmartNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime scheduledTime;
  final NotificationPriority priority;
  final Map<String, dynamic> actionData;
  final DateTime? deliveredAt;
  final bool isDelivered;

  const SmartNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.scheduledTime,
    required this.priority,
    required this.actionData,
    this.deliveredAt,
    this.isDelivered = false,
  });

  SmartNotification copyWith({
    DateTime? deliveredAt,
    bool? isDelivered,
  }) {
    return SmartNotification(
      id: id,
      type: type,
      title: title,
      message: message,
      scheduledTime: scheduledTime,
      priority: priority,
      actionData: actionData,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      isDelivered: isDelivered ?? this.isDelivered,
    );
  }
}
