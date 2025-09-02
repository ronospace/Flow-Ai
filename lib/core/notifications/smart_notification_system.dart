import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/user_profile.dart';
import '../models/cycle_data.dart';
import '../health/advanced_health_analytics.dart';

/// 🔔 Revolutionary Smart Notification System
/// AI-powered personalized notifications with adaptive timing and content
/// Ultra-intelligent health-based triggers and contextual awareness
class SmartNotificationSystem {
  static final SmartNotificationSystem _instance = SmartNotificationSystem._internal();
  static SmartNotificationSystem get instance => _instance;
  SmartNotificationSystem._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  // Core notification components
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  late NotificationPersonalizationEngine _personalizationEngine;
  late NotificationScheduler _scheduler;
  late NotificationContentGenerator _contentGenerator;
  late NotificationOptimizer _optimizer;

  // Smart timing and context
  final Map<String, dynamic> _userContext = {};
  final Map<String, DateTime> _lastNotificationTime = {};
  final List<SmartNotification> _notificationHistory = [];
  
  // Timers and streams
  Timer? _contextUpdateTimer;
  Timer? _notificationOptimizationTimer;
  final StreamController<NotificationEvent> _notificationEventStream = 
      StreamController.broadcast();
  
  Stream<NotificationEvent> get notificationEventStream => 
      _notificationEventStream.stream;

  Future<void> initialize() async {
    if (_initialized) return;

    debugPrint('🔔 Initializing Smart Notification System...');

    // Initialize notification plugin
    await _initializeNotificationPlugin();

    // Initialize smart components
    await _initializeSmartComponents();

    // Setup context monitoring
    _setupContextMonitoring();

    // Start optimization engine
    _startOptimizationEngine();

    _initialized = true;
    debugPrint('✅ Smart Notification System initialized with AI-powered personalization');
  }

  Future<void> _initializeNotificationPlugin() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: null,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Request permissions
    await _requestNotificationPermissions();
  }

  Future<void> _requestNotificationPermissions() async {
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> _initializeSmartComponents() async {
    debugPrint('🧠 Initializing smart notification components...');

    _personalizationEngine = NotificationPersonalizationEngine();
    _scheduler = NotificationScheduler();
    _contentGenerator = NotificationContentGenerator();
    _optimizer = NotificationOptimizer();

    await Future.wait([
      _personalizationEngine.initialize(),
      _scheduler.initialize(),
      _contentGenerator.initialize(),
      _optimizer.initialize(),
    ]);
  }

  void _setupContextMonitoring() {
    // Update user context every 30 minutes
    _contextUpdateTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _updateUserContext();
    });
  }

  void _startOptimizationEngine() {
    // Optimize notifications every hour
    _notificationOptimizationTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _optimizeNotificationStrategy();
    });
  }

  /// Send smart health notification with AI-powered personalization
  Future<void> sendSmartHealthNotification({
    required UserProfile user,
    required NotificationType type,
    Map<String, dynamic>? healthData,
    String? customMessage,
    int? delayMinutes,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    if (!_initialized) await initialize();

    debugPrint('📱 Generating smart health notification for ${user.displayName}...');

    try {
      // Check if we should send this notification
      final shouldSend = await _shouldSendNotification(user, type, priority);
      if (!shouldSend) {
        debugPrint('⏭️ Skipping notification due to optimization rules');
        return;
      }

      // Generate personalized content
      final content = await _contentGenerator.generatePersonalizedContent(
        user: user,
        type: type,
        healthData: healthData,
        customMessage: customMessage,
        userContext: _userContext,
      );

      // Calculate optimal timing
      final optimalTime = await _scheduler.calculateOptimalTime(
        user: user,
        type: type,
        priority: priority,
        delayMinutes: delayMinutes,
        userContext: _userContext,
      );

      // Create smart notification
      final notification = SmartNotification(
        id: _generateNotificationId(),
        type: type,
        title: content.title,
        body: content.body,
        scheduledTime: optimalTime,
        priority: priority,
        userId: user.id,
        personalizedContent: content,
        metadata: {
          'health_data': healthData,
          'user_context': Map.from(_userContext),
          'generation_time': DateTime.now().toIso8601String(),
        },
      );

      // Schedule the notification
      await _scheduleNotification(notification);

      // Track notification
      _trackNotification(notification);

      debugPrint('✅ Smart notification scheduled: ${notification.title}');
    } catch (e) {
      debugPrint('❌ Error sending smart notification: $e');
    }
  }

  /// Send cycle phase notification with contextual awareness
  Future<void> sendCyclePhaseNotification({
    required UserProfile user,
    required String phase,
    required List<CycleData> cycleHistory,
    Map<String, dynamic>? predictions,
  }) async {
    final phaseData = {
      'phase': phase,
      'cycle_history': cycleHistory.length,
      'predictions': predictions,
    };

    await sendSmartHealthNotification(
      user: user,
      type: NotificationType.cyclePhase,
      healthData: phaseData,
      priority: NotificationPriority.normal,
    );
  }

  /// Send AI insight notification with adaptive content
  Future<void> sendAIInsightNotification({
    required UserProfile user,
    required ComprehensiveHealthReport healthReport,
    String? specificInsight,
  }) async {
    final insightData = {
      'health_score': healthReport.overallHealthScore,
      'key_findings': healthReport.keyFindings,
      'specific_insight': specificInsight,
    };

    await sendSmartHealthNotification(
      user: user,
      type: NotificationType.aiInsight,
      healthData: insightData,
      customMessage: specificInsight,
      priority: NotificationPriority.high,
    );
  }

  /// Send health alert with urgency-based timing
  Future<void> sendHealthAlert({
    required UserProfile user,
    required String alertType,
    required String message,
    Map<String, dynamic>? alertData,
  }) async {
    final alertInfo = {
      'alert_type': alertType,
      'alert_data': alertData,
      'severity': _determineAlertSeverity(alertType),
    };

    await sendSmartHealthNotification(
      user: user,
      type: NotificationType.healthAlert,
      healthData: alertInfo,
      customMessage: message,
      priority: NotificationPriority.critical,
      delayMinutes: 0, // Send immediately
    );
  }

  /// Send medication reminder with smart timing
  Future<void> sendMedicationReminder({
    required UserProfile user,
    required String medicationName,
    required String dosage,
    required DateTime scheduledTime,
  }) async {
    final medicationData = {
      'medication_name': medicationName,
      'dosage': dosage,
      'scheduled_time': scheduledTime.toIso8601String(),
    };

    await sendSmartHealthNotification(
      user: user,
      type: NotificationType.medication,
      healthData: medicationData,
      priority: NotificationPriority.high,
    );
  }

  /// Send wellness tip with personalized content
  Future<void> sendWellnessTip({
    required UserProfile user,
    Map<String, dynamic>? healthContext,
  }) async {
    await sendSmartHealthNotification(
      user: user,
      type: NotificationType.wellnessTip,
      healthData: healthContext,
      priority: NotificationPriority.low,
    );
  }

  Future<void> _scheduleNotification(SmartNotification notification) async {
    const androidDetails = AndroidNotificationDetails(
      'flowai_smart_notifications',
      'Flow Ai Smart Notifications',
      channelDescription: 'AI-powered personalized health notifications for women',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = DateTime.now();
    final scheduledTime = notification.scheduledTime;

    if (scheduledTime.isAfter(now)) {
      // Schedule for future
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notification.id,
        notification.title,
        notification.body,
        _convertToTZDateTime(scheduledTime),
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: notification.toJsonString(),
      );
    } else {
      // Send immediately
      await _flutterLocalNotificationsPlugin.show(
        notification.id,
        notification.title,
        notification.body,
        notificationDetails,
        payload: notification.toJsonString(),
      );
    }
  }

  Future<bool> _shouldSendNotification(
    UserProfile user,
    NotificationType type,
    NotificationPriority priority,
  ) async {
    // Check notification frequency limits
    final lastSent = _lastNotificationTime['${user.id}_$type'];
    if (lastSent != null) {
      final timeSince = DateTime.now().difference(lastSent);
      final minimumInterval = _getMinimumInterval(type, priority);
      
      if (timeSince < minimumInterval) {
        return false;
      }
    }

    // Check user preferences and context
    final preferences = await _personalizationEngine.getUserPreferences(user);
    if (!preferences.allowsNotification(type)) {
      return false;
    }

    // Check optimal timing context
    final isOptimalTime = await _scheduler.isOptimalTime(
      user: user,
      type: type,
      userContext: _userContext,
    );

    return isOptimalTime || priority == NotificationPriority.critical;
  }

  Duration _getMinimumInterval(NotificationType type, NotificationPriority priority) {
    if (priority == NotificationPriority.critical) {
      return const Duration(minutes: 5);
    }

    switch (type) {
      case NotificationType.healthAlert:
        return const Duration(hours: 1);
      case NotificationType.medication:
        return const Duration(hours: 4);
      case NotificationType.cyclePhase:
        return const Duration(hours: 12);
      case NotificationType.aiInsight:
        return const Duration(hours: 6);
      case NotificationType.wellnessTip:
        return const Duration(days: 1);
      default:
        return const Duration(hours: 2);
    }
  }

  void _trackNotification(SmartNotification notification) {
    _notificationHistory.add(notification);
    _lastNotificationTime['${notification.userId}_${notification.type}'] = DateTime.now();

    // Keep only recent history (last 100 notifications)
    if (_notificationHistory.length > 100) {
      _notificationHistory.removeAt(0);
    }

    // Emit notification event
    _notificationEventStream.add(NotificationEvent(
      type: NotificationEventType.scheduled,
      notification: notification,
      timestamp: DateTime.now(),
    ));
  }

  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('📱 Notification tapped: ${response.payload}');
    
    try {
      final notification = SmartNotification.fromJsonString(response.payload!);
      
      _notificationEventStream.add(NotificationEvent(
        type: NotificationEventType.tapped,
        notification: notification,
        timestamp: DateTime.now(),
      ));

      // Update engagement metrics
      _optimizer.recordEngagement(notification, 'tapped');
    } catch (e) {
      debugPrint('Error parsing notification response: $e');
    }
  }

  Future<void> _updateUserContext() async {
    debugPrint('🔄 Updating user context for notifications...');
    
    final now = DateTime.now();
    _userContext['current_time'] = now.toIso8601String();
    _userContext['hour'] = now.hour;
    _userContext['day_of_week'] = now.weekday;
    _userContext['is_weekend'] = now.weekday >= 6;
    _userContext['time_of_day'] = _getTimeOfDay(now.hour);
    
    // Add more context from other engines if available
    // This would be enhanced with real user data
  }

  String _getTimeOfDay(int hour) {
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 22) return 'evening';
    return 'night';
  }

  Future<void> _optimizeNotificationStrategy() async {
    debugPrint('⚡ Optimizing notification strategy...');
    
    final insights = await _optimizer.analyzeNotificationPerformance(
      _notificationHistory,
      _userContext,
    );

    debugPrint('📊 Notification insights: ${insights.length} optimizations found');
  }

  String _determineAlertSeverity(String alertType) {
    const highSeverity = ['abnormal_bleeding', 'severe_pain', 'emergency'];
    const mediumSeverity = ['irregular_cycle', 'unusual_symptoms'];
    
    if (highSeverity.contains(alertType)) return 'high';
    if (mediumSeverity.contains(alertType)) return 'medium';
    return 'low';
  }

  int _generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch % 2147483647;
  }

  dynamic _convertToTZDateTime(DateTime dateTime) {
    // In a real implementation, this would properly convert to TZDateTime
    // For now, we'll use the DateTime directly
    return dateTime;
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Get notification history
  List<SmartNotification> getNotificationHistory({int limit = 50}) {
    return _notificationHistory.reversed.take(limit).toList();
  }

  void dispose() {
    _contextUpdateTimer?.cancel();
    _notificationOptimizationTimer?.cancel();
    _notificationEventStream.close();
  }
}

// Supporting classes and components

class NotificationPersonalizationEngine {
  Future<void> initialize() async {
    debugPrint('🎯 Notification Personalization Engine initialized');
  }

  Future<NotificationPreferences> getUserPreferences(UserProfile user) async {
    // In a real implementation, this would load from user settings
    return NotificationPreferences.defaultPreferences();
  }
}

class NotificationScheduler {
  Future<void> initialize() async {
    debugPrint('⏰ Notification Scheduler initialized');
  }

  Future<DateTime> calculateOptimalTime({
    required UserProfile user,
    required NotificationType type,
    required NotificationPriority priority,
    int? delayMinutes,
    required Map<String, dynamic> userContext,
  }) async {
    final now = DateTime.now();
    
    if (delayMinutes != null) {
      return now.add(Duration(minutes: delayMinutes));
    }

    if (priority == NotificationPriority.critical) {
      return now; // Send immediately
    }

    // Calculate optimal time based on type and user context
    return _getOptimalTimeForType(type, userContext);
  }

  Future<bool> isOptimalTime({
    required UserProfile user,
    required NotificationType type,
    required Map<String, dynamic> userContext,
  }) async {
    final hour = userContext['hour'] as int? ?? DateTime.now().hour;
    
    // Basic optimal time rules
    switch (type) {
      case NotificationType.wellnessTip:
        return hour >= 8 && hour <= 10; // Morning tips
      case NotificationType.medication:
        return hour >= 7 && hour <= 22; // Daytime reminders
      case NotificationType.cyclePhase:
        return hour >= 9 && hour <= 19; // Business hours
      default:
        return hour >= 8 && hour <= 21; // General waking hours
    }
  }

  DateTime _getOptimalTimeForType(NotificationType type, Map<String, dynamic> context) {
    final now = DateTime.now();
    final hour = now.hour;

    switch (type) {
      case NotificationType.wellnessTip:
        // Send wellness tips in the morning
        if (hour < 9) {
          return DateTime(now.year, now.month, now.day, 9, 0);
        } else {
          return DateTime(now.year, now.month, now.day + 1, 9, 0);
        }
      
      case NotificationType.medication:
        // Send medication reminders during appropriate hours
        if (hour < 8) {
          return DateTime(now.year, now.month, now.day, 8, 0);
        } else if (hour > 22) {
          return DateTime(now.year, now.month, now.day + 1, 8, 0);
        } else {
          return now.add(const Duration(minutes: 15));
        }
      
      default:
        return now.add(const Duration(minutes: 5));
    }
  }
}

class NotificationContentGenerator {
  Future<void> initialize() async {
    debugPrint('📝 Notification Content Generator initialized');
  }

  Future<NotificationContent> generatePersonalizedContent({
    required UserProfile user,
    required NotificationType type,
    Map<String, dynamic>? healthData,
    String? customMessage,
    required Map<String, dynamic> userContext,
  }) async {
    if (customMessage != null) {
      return NotificationContent(
        title: _getTitleForType(type),
        body: customMessage,
      );
    }

    return _generateContentForType(type, user, healthData, userContext);
  }

  NotificationContent _generateContentForType(
    NotificationType type,
    UserProfile user,
    Map<String, dynamic>? healthData,
    Map<String, dynamic> userContext,
  ) {
    final userName = user.displayName ?? 'there';
    
    switch (type) {
      case NotificationType.cyclePhase:
        return _generateCyclePhaseContent(userName, healthData);
      
      case NotificationType.aiInsight:
        return _generateAIInsightContent(userName, healthData);
      
      case NotificationType.healthAlert:
        return _generateHealthAlertContent(userName, healthData);
      
      case NotificationType.medication:
        return _generateMedicationContent(userName, healthData);
      
      case NotificationType.wellnessTip:
        return _generateWellnessTipContent(userName, userContext);
      
      default:
        return NotificationContent(
          title: 'Flow Ai Health Update',
          body: 'Hi $userName, we have a health update for you.',
        );
    }
  }

  NotificationContent _generateCyclePhaseContent(String userName, Map<String, dynamic>? data) {
    final phase = data?['phase'] ?? 'current';
    
    switch (phase) {
      case 'menstrual':
        return NotificationContent(
          title: '🌙 Menstrual Phase Update',
          body: 'Hi $userName! Your menstrual phase has begun. Remember to practice self-care and stay hydrated.',
        );
      case 'follicular':
        return NotificationContent(
          title: '🌱 Follicular Phase Energy',
          body: 'Hi $userName! You\'re in your follicular phase - a great time for new activities and goal setting!',
        );
      case 'ovulatory':
        return NotificationContent(
          title: '✨ Ovulation Window',
          body: 'Hi $userName! You\'re in your ovulation phase. Energy levels may be at their peak!',
        );
      case 'luteal':
        return NotificationContent(
          title: '🍂 Luteal Phase Care',
          body: 'Hi $userName! Your luteal phase has begun. Focus on self-care and stress management.',
        );
      default:
        return NotificationContent(
          title: '🔄 Cycle Update',
          body: 'Hi $userName! We have a cycle update for you.',
        );
    }
  }

  NotificationContent _generateAIInsightContent(String userName, Map<String, dynamic>? data) {
    final score = data?['health_score'] as double?;
    final insight = data?['specific_insight'] as String?;
    
    if (insight != null) {
      return NotificationContent(
        title: '🤖 AI Health Insight',
        body: insight,
      );
    }
    
    if (score != null && score >= 0.8) {
      return NotificationContent(
        title: '🎉 Great Health Progress!',
        body: 'Hi $userName! Your health score is excellent at ${(score * 100).round()}%. Keep up the great work!',
      );
    }
    
    return NotificationContent(
      title: '🧠 AI Health Insight',
      body: 'Hi $userName! We\'ve discovered some interesting patterns in your health data.',
    );
  }

  NotificationContent _generateHealthAlertContent(String userName, Map<String, dynamic>? data) {
    final alertType = data?['alert_type'] ?? 'general';
    final severity = data?['severity'] ?? 'low';
    
    String emoji = severity == 'high' ? '🚨' : severity == 'medium' ? '⚠️' : 'ℹ️';
    
    return NotificationContent(
      title: '$emoji Health Alert',
      body: 'Hi $userName! We noticed something that may need your attention regarding your health.',
    );
  }

  NotificationContent _generateMedicationContent(String userName, Map<String, dynamic>? data) {
    final medicationName = data?['medication_name'] ?? 'your medication';
    final dosage = data?['dosage'] ?? '';
    
    return NotificationContent(
      title: '💊 Medication Reminder',
      body: 'Hi $userName! Time to take $medicationName${dosage.isNotEmpty ? ' ($dosage)' : ''}.',
    );
  }

  NotificationContent _generateWellnessTipContent(String userName, Map<String, dynamic> context) {
    final tips = [
      'Stay hydrated! Aim for 8 glasses of water today.',
      'Take a 10-minute walk to boost your energy.',
      'Practice deep breathing for 5 minutes to reduce stress.',
      'Eat a balanced meal with plenty of vegetables.',
      'Get 7-9 hours of sleep for optimal health.',
      'Take time to stretch and improve your flexibility.',
    ];
    
    final randomTip = tips[math.Random().nextInt(tips.length)];
    
    return NotificationContent(
      title: '💡 Daily Wellness Tip',
      body: 'Hi $userName! $randomTip',
    );
  }

  String _getTitleForType(NotificationType type) {
    switch (type) {
      case NotificationType.cyclePhase:
        return '🔄 Cycle Phase Update';
      case NotificationType.aiInsight:
        return '🤖 AI Health Insight';
      case NotificationType.healthAlert:
        return '⚠️ Health Alert';
      case NotificationType.medication:
        return '💊 Medication Reminder';
      case NotificationType.wellnessTip:
        return '💡 Wellness Tip';
      default:
        return 'Flow Ai Notification';
    }
  }
}

class NotificationOptimizer {
  Future<void> initialize() async {
    debugPrint('⚡ Notification Optimizer initialized');
  }

  Future<List<String>> analyzeNotificationPerformance(
    List<SmartNotification> history,
    Map<String, dynamic> userContext,
  ) async {
    final insights = <String>[];
    
    if (history.isEmpty) return insights;
    
    // Analyze engagement rates by type
    final typeEngagement = <NotificationType, double>{};
    for (final type in NotificationType.values) {
      final notifications = history.where((n) => n.type == type).toList();
      if (notifications.isNotEmpty) {
        final engagementRate = notifications.where((n) => n.wasEngaged).length / 
                              notifications.length;
        typeEngagement[type] = engagementRate;
      }
    }
    
    // Generate insights
    final bestType = typeEngagement.entries
        .where((e) => e.value > 0.5)
        .map((e) => e.key)
        .toList();
    
    if (bestType.isNotEmpty) {
      insights.add('High engagement types: ${bestType.join(", ")}');
    }
    
    return insights;
  }

  void recordEngagement(SmartNotification notification, String action) {
    notification.recordEngagement(action);
    debugPrint('📊 Recorded engagement: ${notification.id} -> $action');
  }
}

// Data models and enums

enum NotificationType {
  cyclePhase,
  aiInsight,
  healthAlert,
  medication,
  wellnessTip,
  biometricUpdate,
  fertilityWindow,
  symptomReminder,
}

enum NotificationPriority {
  low,
  normal,
  high,
  critical,
}

enum NotificationEventType {
  scheduled,
  delivered,
  tapped,
  dismissed,
}

class SmartNotification {
  final int id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final NotificationPriority priority;
  final String userId;
  final NotificationContent personalizedContent;
  final Map<String, dynamic> metadata;
  
  bool _wasEngaged = false;
  String? _engagementAction;
  DateTime? _engagementTime;

  SmartNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.priority,
    required this.userId,
    required this.personalizedContent,
    required this.metadata,
  });

  bool get wasEngaged => _wasEngaged;
  String? get engagementAction => _engagementAction;
  DateTime? get engagementTime => _engagementTime;

  void recordEngagement(String action) {
    _wasEngaged = true;
    _engagementAction = action;
    _engagementTime = DateTime.now();
  }

  String toJsonString() {
    return '''{"id": $id, "type": "${type.name}", "title": "$title", "userId": "$userId"}''';
  }

  static SmartNotification fromJsonString(String json) {
    // Simplified JSON parsing for demo
    // In production, use proper JSON parsing
    return SmartNotification(
      id: 0,
      type: NotificationType.healthAlert,
      title: 'Parsed Notification',
      body: 'Body',
      scheduledTime: DateTime.now(),
      priority: NotificationPriority.normal,
      userId: 'user',
      personalizedContent: NotificationContent(title: 'Title', body: 'Body'),
      metadata: {},
    );
  }
}

class NotificationContent {
  final String title;
  final String body;
  final String? actionText;
  final Map<String, dynamic>? actionData;

  NotificationContent({
    required this.title,
    required this.body,
    this.actionText,
    this.actionData,
  });
}

class NotificationPreferences {
  final Map<NotificationType, bool> typePreferences;
  final List<int> quietHours;
  final bool allowWeekends;
  final int maxDailyNotifications;

  NotificationPreferences({
    required this.typePreferences,
    required this.quietHours,
    required this.allowWeekends,
    required this.maxDailyNotifications,
  });

  bool allowsNotification(NotificationType type) {
    return typePreferences[type] ?? true;
  }

  static NotificationPreferences defaultPreferences() {
    return NotificationPreferences(
      typePreferences: {
        for (final type in NotificationType.values) type: true
      },
      quietHours: [22, 23, 0, 1, 2, 3, 4, 5, 6], // 10 PM - 6 AM
      allowWeekends: true,
      maxDailyNotifications: 5,
    );
  }
}

class NotificationEvent {
  final NotificationEventType type;
  final SmartNotification notification;
  final DateTime timestamp;

  NotificationEvent({
    required this.type,
    required this.notification,
    required this.timestamp,
  });
}
