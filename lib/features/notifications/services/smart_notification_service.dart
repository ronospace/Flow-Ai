import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/user_service.dart';

/// Smart notification service with personalized timing and content
class SmartNotificationService {
  static SmartNotificationService? _instance;
  static SmartNotificationService get instance {
    _instance ??= SmartNotificationService._internal();
    return _instance!;
  }

  SmartNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  Timer? _adaptiveTimer;
  SharedPreferences? _prefs;

  // Notification channels
  static const String _cycleReminderChannel = 'cycle_reminder';
  static const String _symptomTrackingChannel = 'symptom_tracking';
  static const String _feelingsTrackerChannel = 'feelings_tracker';
  static const String _insightsChannel = 'insights';
  static const String _medicationChannel = 'medication';
  static const String _appointmentChannel = 'appointment';
  static const String _wellnessChannel = 'wellness';

  // Notification IDs
  static const int cycleReminderID = 1000;
  static const int symptomTrackingID = 2000;
  static const int feelingsTrackerID = 3000;
  static const int insightsID = 4000;
  static const int medicationBaseID = 5000;
  static const int appointmentBaseID = 6000;
  static const int wellnessBaseID = 7000;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      tz.initializeTimeZones();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Start adaptive scheduling
      await _startAdaptiveScheduling();

      _isInitialized = true;
      debugPrint('🔔 Smart notification service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize notifications: $e');
      throw NotificationException('Failed to initialize notification service: $e');
    }
  }

  /// Initialize Flutter Local Notifications
  Future<void> _initializeLocalNotifications() async {
    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createAndroidNotificationChannels();
    }
  }

  /// Create Android notification channels
  Future<void> _createAndroidNotificationChannels() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Cycle reminder channel
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          _cycleReminderChannel,
          'Cycle Reminders',
          description: 'Notifications for cycle predictions and reminders',
          importance: Importance.high,
          enableVibration: true,
        ),
      );

      // Symptom tracking channel
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          _symptomTrackingChannel,
          'Symptom Tracking',
          description: 'Reminders to track symptoms and health data',
          importance: Importance.defaultImportance,
        ),
      );

      // Feelings tracker channel
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          _feelingsTrackerChannel,
          'Feelings Tracker',
          description: 'Daily reminders to log mood and wellbeing',
          importance: Importance.defaultImportance,
        ),
      );

      // Insights channel
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          _insightsChannel,
          'Health Insights',
          description: 'AI-generated insights and recommendations',
          importance: Importance.high,
        ),
      );

      // Medication channel
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          _medicationChannel,
          'Medication Reminders',
          description: 'Reminders to take medication',
          importance: Importance.max,
          enableVibration: true,
          sound: RawResourceAndroidNotificationSound('medication_alert'),
        ),
      );

      // Appointment channel
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          _appointmentChannel,
          'Appointments',
          description: 'Healthcare appointment reminders',
          importance: Importance.high,
        ),
      );

      // Wellness channel
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          _wellnessChannel,
          'Wellness Tips',
          description: 'Daily wellness tips and motivation',
          importance: Importance.low,
        ),
      );
    }
  }

  /// Handle iOS local notification when app is in foreground
  void _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // Handle iOS notification in foreground
    debugPrint('📱 iOS notification received: $id - $title');
  }

  /// Handle notification tap
  void _onDidReceiveNotificationResponse(NotificationResponse response) async {
    final String? payload = response.payload;
    debugPrint('🔔 Notification tapped with payload: $payload');

    if (payload != null) {
      try {
        final Map<String, dynamic> data = json.decode(payload);
        await _handleNotificationAction(data);
      } catch (e) {
        debugPrint('❌ Error handling notification action: $e');
      }
    }
  }

  /// Handle notification actions
  Future<void> _handleNotificationAction(Map<String, dynamic> data) async {
    final String action = data['action'] ?? '';
    
    switch (action) {
      case 'open_cycle_tracker':
        // Navigate to cycle tracker
        debugPrint('🔄 Opening cycle tracker');
        break;
      case 'open_symptom_tracker':
        // Navigate to symptom tracker
        debugPrint('🩺 Opening symptom tracker');
        break;
      case 'open_feelings_tracker':
        // Navigate to feelings tracker
        debugPrint('💭 Opening feelings tracker');
        break;
      case 'view_insights':
        // Navigate to insights
        debugPrint('💡 Opening insights');
        break;
      case 'medication_taken':
        // Mark medication as taken
        await _markMedicationTaken(data['medicationId']);
        break;
      default:
        debugPrint('❓ Unknown notification action: $action');
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? granted = await androidImplementation.requestPermission();
        return granted ?? false;
      }
    } else if (Platform.isIOS) {
      final bool? granted = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return granted ?? false;
    }

    return false;
  }

  /// Schedule cycle prediction notification
  Future<void> scheduleCyclePrediction({
    required DateTime predictedDate,
    required String cyclePhase,
    String? customMessage,
  }) async {
    if (!_isInitialized) await initialize();

    final String title = _getCyclePredictionTitle(cyclePhase);
    final String body = customMessage ?? _getCyclePredictionMessage(cyclePhase, predictedDate);

    final String payload = json.encode({
      'action': 'open_cycle_tracker',
      'cyclePhase': cyclePhase,
      'predictedDate': predictedDate.toIso8601String(),
    });

    await _scheduleNotification(
      id: cycleReminderID,
      title: title,
      body: body,
      scheduledDate: predictedDate.subtract(const Duration(days: 1)),
      channel: _cycleReminderChannel,
      payload: payload,
    );
  }

  /// Schedule daily symptom tracking reminder
  Future<void> scheduleSymptomTrackingReminder({
    required TimeOfDay preferredTime,
    List<String> customSymptoms = const [],
  }) async {
    if (!_isInitialized) await initialize();

    // Calculate optimal time based on user behavior
    final TimeOfDay optimalTime = await _calculateOptimalTime(
      'symptom_tracking',
      preferredTime,
    );

    final String title = 'Track Your Symptoms';
    final String body = customSymptoms.isNotEmpty
        ? 'How are you feeling today? Track: ${customSymptoms.take(3).join(', ')}'
        : 'How are you feeling today? Log your symptoms to track patterns.';

    final String payload = json.encode({
      'action': 'open_symptom_tracker',
      'customSymptoms': customSymptoms,
    });

    await _scheduleDailyNotification(
      id: symptomTrackingID,
      title: title,
      body: body,
      time: optimalTime,
      channel: _symptomTrackingChannel,
      payload: payload,
    );
  }

  /// Schedule daily feelings tracker reminder
  Future<void> scheduleFeelingTrackerReminder({
    required TimeOfDay preferredTime,
    String? personalizedMessage,
  }) async {
    if (!_isInitialized) await initialize();

    final TimeOfDay optimalTime = await _calculateOptimalTime(
      'feelings_tracking',
      preferredTime,
    );

    final String title = 'Daily Check-in';
    final String body = personalizedMessage ?? await _getPersonalizedFeelingsMessage();

    final String payload = json.encode({
      'action': 'open_feelings_tracker',
      'timestamp': DateTime.now().toIso8601String(),
    });

    await _scheduleDailyNotification(
      id: feelingsTrackerID,
      title: title,
      body: body,
      time: optimalTime,
      channel: _feelingsTrackerChannel,
      payload: payload,
    );
  }

  /// Schedule insight notification
  Future<void> scheduleInsightNotification({
    required String insight,
    required String category,
    String? actionText,
    String? actionData,
  }) async {
    if (!_isInitialized) await initialize();

    final String title = _getInsightTitle(category);
    final String body = insight;

    final String payload = json.encode({
      'action': 'view_insights',
      'category': category,
      'insight': insight,
      'actionData': actionData,
    });

    await _scheduleNotification(
      id: insightsID + _getInsightOffset(category),
      title: title,
      body: body,
      scheduledDate: DateTime.now().add(const Duration(seconds: 5)),
      channel: _insightsChannel,
      payload: payload,
    );
  }

  /// Schedule medication reminder
  Future<void> scheduleMedicationReminder({
    required String medicationId,
    required String medicationName,
    required DateTime reminderTime,
    String? dosage,
    String? instructions,
  }) async {
    if (!_isInitialized) await initialize();

    final String title = 'Medication Reminder';
    final String body = _getMedicationReminderMessage(medicationName, dosage);

    final String payload = json.encode({
      'action': 'medication_taken',
      'medicationId': medicationId,
      'medicationName': medicationName,
      'dosage': dosage,
    });

    final int notificationId = medicationBaseID + medicationId.hashCode.abs() % 1000;

    await _scheduleNotification(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: reminderTime,
      channel: _medicationChannel,
      payload: payload,
    );
  }

  /// Schedule appointment reminder
  Future<void> scheduleAppointmentReminder({
    required String appointmentId,
    required String appointmentType,
    required DateTime appointmentTime,
    String? doctorName,
    String? location,
  }) async {
    if (!_isInitialized) await initialize();

    final String title = 'Upcoming Appointment';
    final String body = _getAppointmentReminderMessage(
      appointmentType,
      appointmentTime,
      doctorName,
      location,
    );

    final String payload = json.encode({
      'action': 'view_appointment',
      'appointmentId': appointmentId,
      'appointmentType': appointmentType,
    });

    final int notificationId = appointmentBaseID + appointmentId.hashCode.abs() % 1000;

    // Schedule 1 hour before
    await _scheduleNotification(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: appointmentTime.subtract(const Duration(hours: 1)),
      channel: _appointmentChannel,
      payload: payload,
    );
  }

  /// Schedule wellness tip notification
  Future<void> scheduleWellnessTip({
    required String tip,
    required String category,
    TimeOfDay? preferredTime,
  }) async {
    if (!_isInitialized) await initialize();

    final TimeOfDay optimalTime = await _calculateOptimalTime(
      'wellness_tip',
      preferredTime ?? const TimeOfDay(hour: 9, minute: 0),
    );

    final String title = _getWellnessTipTitle(category);
    final String body = tip;

    final String payload = json.encode({
      'action': 'view_wellness_tips',
      'category': category,
      'tip': tip,
    });

    final int notificationId = wellnessBaseID + DateTime.now().day;

    await _scheduleDailyNotification(
      id: notificationId,
      title: title,
      body: body,
      time: optimalTime,
      channel: _wellnessChannel,
      payload: payload,
    );
  }

  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Start adaptive scheduling based on user behavior
  Future<void> _startAdaptiveScheduling() async {
    _adaptiveTimer = Timer.periodic(const Duration(hours: 6), (_) async {
      await _optimizeNotificationTiming();
    });
  }

  /// Optimize notification timing based on user engagement
  Future<void> _optimizeNotificationTiming() async {
    try {
      // Analyze user engagement patterns
      final Map<String, List<int>> engagementPatterns = await _analyzeEngagementPatterns();

      // Update optimal notification times
      for (final category in engagementPatterns.keys) {
        final List<int> engagementTimes = engagementPatterns[category]!;
        if (engagementTimes.isNotEmpty) {
          final int averageHour = (engagementTimes.reduce((a, b) => a + b) / engagementTimes.length).round();
          await _saveOptimalTime(category, TimeOfDay(hour: averageHour, minute: 0));
        }
      }
    } catch (e) {
      debugPrint('❌ Error optimizing notification timing: $e');
    }
  }

  /// Analyze user engagement patterns
  Future<Map<String, List<int>>> _analyzeEngagementPatterns() async {
    // This would typically analyze user behavior data
    // For now, return mock data
    return {
      'symptom_tracking': [8, 9, 10, 20, 21],
      'feelings_tracking': [7, 8, 9, 19, 20],
      'wellness_tip': [9, 10, 11],
    };
  }

  /// Calculate optimal notification time
  Future<TimeOfDay> _calculateOptimalTime(String category, TimeOfDay fallback) async {
    final String? savedTime = _prefs?.getString('optimal_time_$category');
    if (savedTime != null) {
      final List<String> parts = savedTime.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return fallback;
  }

  /// Save optimal time for category
  Future<void> _saveOptimalTime(String category, TimeOfDay time) async {
    await _prefs?.setString('optimal_time_$category', '${time.hour}:${time.minute}');
  }

  /// Schedule a notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String channel,
    String? payload,
  }) async {
    final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel,
          _getChannelName(channel),
          channelDescription: _getChannelDescription(channel),
          importance: _getChannelImportance(channel),
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule daily recurring notification
  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required String channel,
    String? payload,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the scheduled time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel,
          _getChannelName(channel),
          channelDescription: _getChannelDescription(channel),
          importance: _getChannelImportance(channel),
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Helper methods for notification content
  String _getCyclePredictionTitle(String cyclePhase) {
    switch (cyclePhase) {
      case 'menstrual':
        return '🔴 Period Prediction';
      case 'follicular':
        return '🌱 Follicular Phase';
      case 'ovulation':
        return '🥚 Ovulation Window';
      case 'luteal':
        return '🌙 Luteal Phase';
      default:
        return '📅 Cycle Update';
    }
  }

  String _getCyclePredictionMessage(String cyclePhase, DateTime date) {
    final String dateStr = '${date.day}/${date.month}';
    switch (cyclePhase) {
      case 'menstrual':
        return 'Your period is predicted to start around $dateStr. Prepare with supplies and self-care.';
      case 'ovulation':
        return 'Your fertile window is approaching around $dateStr. Track symptoms if trying to conceive.';
      default:
        return 'Your $cyclePhase phase is expected around $dateStr.';
    }
  }

  Future<String> _getPersonalizedFeelingsMessage() async {
    final List<String> messages = [
      'How are you feeling today? Take a moment to check in with yourself.',
      'Your daily mood matters. Let\'s track how you\'re doing.',
      'Time for your daily wellness check-in. How\'s your energy?',
      'A quick moment to reflect on your day and mood.',
      'Your feelings are valid. Let\'s log how you\'re doing today.',
    ];

    // In a real app, this would be personalized based on user history
    return messages[DateTime.now().day % messages.length];
  }

  String _getInsightTitle(String category) {
    switch (category) {
      case 'mood':
        return '💭 Mood Insight';
      case 'cycle':
        return '🔄 Cycle Insight';
      case 'symptoms':
        return '🩺 Health Pattern';
      case 'wellness':
        return '🌟 Wellness Tip';
      default:
        return '💡 Health Insight';
    }
  }

  int _getInsightOffset(String category) {
    switch (category) {
      case 'mood':
        return 1;
      case 'cycle':
        return 2;
      case 'symptoms':
        return 3;
      case 'wellness':
        return 4;
      default:
        return 0;
    }
  }

  String _getMedicationReminderMessage(String name, String? dosage) {
    if (dosage != null) {
      return 'Time to take your $name ($dosage)';
    }
    return 'Time to take your $name';
  }

  String _getAppointmentReminderMessage(
      String type, DateTime time, String? doctor, String? location) {
    final String timeStr = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    String message = 'You have a $type appointment at $timeStr';
    
    if (doctor != null) {
      message += ' with Dr. $doctor';
    }
    
    if (location != null) {
      message += ' at $location';
    }
    
    return message;
  }

  String _getWellnessTipTitle(String category) {
    switch (category) {
      case 'nutrition':
        return '🥗 Nutrition Tip';
      case 'exercise':
        return '🏃‍♀️ Exercise Tip';
      case 'mindfulness':
        return '🧘‍♀️ Mindfulness Tip';
      case 'sleep':
        return '😴 Sleep Tip';
      default:
        return '🌟 Wellness Tip';
    }
  }

  String _getChannelName(String channel) {
    switch (channel) {
      case _cycleReminderChannel:
        return 'Cycle Reminders';
      case _symptomTrackingChannel:
        return 'Symptom Tracking';
      case _feelingsTrackerChannel:
        return 'Feelings Tracker';
      case _insightsChannel:
        return 'Health Insights';
      case _medicationChannel:
        return 'Medication Reminders';
      case _appointmentChannel:
        return 'Appointments';
      case _wellnessChannel:
        return 'Wellness Tips';
      default:
        return 'ZyraFlow';
    }
  }

  String _getChannelDescription(String channel) {
    switch (channel) {
      case _cycleReminderChannel:
        return 'Notifications for cycle predictions and reminders';
      case _symptomTrackingChannel:
        return 'Reminders to track symptoms and health data';
      case _feelingsTrackerChannel:
        return 'Daily reminders to log mood and wellbeing';
      case _insightsChannel:
        return 'AI-generated insights and recommendations';
      case _medicationChannel:
        return 'Reminders to take medication';
      case _appointmentChannel:
        return 'Healthcare appointment reminders';
      case _wellnessChannel:
        return 'Daily wellness tips and motivation';
      default:
        return 'ZyraFlow notifications';
    }
  }

  Importance _getChannelImportance(String channel) {
    switch (channel) {
      case _medicationChannel:
        return Importance.max;
      case _cycleReminderChannel:
      case _insightsChannel:
      case _appointmentChannel:
        return Importance.high;
      case _symptomTrackingChannel:
      case _feelingsTrackerChannel:
        return Importance.defaultImportance;
      case _wellnessChannel:
        return Importance.low;
      default:
        return Importance.defaultImportance;
    }
  }

  Future<void> _markMedicationTaken(String medicationId) async {
    try {
      // This would typically update the medication tracking system
      debugPrint('💊 Marked medication $medicationId as taken');
      
      // You could integrate with a medication service here
      // await MedicationService.instance.markAsTaken(medicationId);
    } catch (e) {
      debugPrint('❌ Error marking medication as taken: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _adaptiveTimer?.cancel();
    _isInitialized = false;
  }
}

// === SUPPORTING DATA MODELS ===

class NotificationPreferences {
  final bool enableCycleReminders;
  final bool enableSymptomTracking;
  final bool enableFeelingsTracker;
  final bool enableInsights;
  final bool enableMedicationReminders;
  final bool enableAppointmentReminders;
  final bool enableWellnessTips;
  final TimeOfDay symptomTrackingTime;
  final TimeOfDay feelingsTrackingTime;
  final TimeOfDay wellnessTime;
  final bool adaptiveTiming;
  final List<String> mutedCategories;

  NotificationPreferences({
    this.enableCycleReminders = true,
    this.enableSymptomTracking = true,
    this.enableFeelingsTracker = true,
    this.enableInsights = true,
    this.enableMedicationReminders = true,
    this.enableAppointmentReminders = true,
    this.enableWellnessTips = true,
    this.symptomTrackingTime = const TimeOfDay(hour: 9, minute: 0),
    this.feelingsTrackingTime = const TimeOfDay(hour: 20, minute: 0),
    this.wellnessTime = const TimeOfDay(hour: 8, minute: 0),
    this.adaptiveTiming = true,
    this.mutedCategories = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'enableCycleReminders': enableCycleReminders,
      'enableSymptomTracking': enableSymptomTracking,
      'enableFeelingsTracker': enableFeelingsTracker,
      'enableInsights': enableInsights,
      'enableMedicationReminders': enableMedicationReminders,
      'enableAppointmentReminders': enableAppointmentReminders,
      'enableWellnessTips': enableWellnessTips,
      'symptomTrackingTime': '${symptomTrackingTime.hour}:${symptomTrackingTime.minute}',
      'feelingsTrackingTime': '${feelingsTrackingTime.hour}:${feelingsTrackingTime.minute}',
      'wellnessTime': '${wellnessTime.hour}:${wellnessTime.minute}',
      'adaptiveTiming': adaptiveTiming,
      'mutedCategories': mutedCategories,
    };
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      enableCycleReminders: json['enableCycleReminders'] ?? true,
      enableSymptomTracking: json['enableSymptomTracking'] ?? true,
      enableFeelingsTracker: json['enableFeelingsTracker'] ?? true,
      enableInsights: json['enableInsights'] ?? true,
      enableMedicationReminders: json['enableMedicationReminders'] ?? true,
      enableAppointmentReminders: json['enableAppointmentReminders'] ?? true,
      enableWellnessTips: json['enableWellnessTips'] ?? true,
      symptomTrackingTime: _parseTimeOfDay(json['symptomTrackingTime']) ?? const TimeOfDay(hour: 9, minute: 0),
      feelingsTrackingTime: _parseTimeOfDay(json['feelingsTrackingTime']) ?? const TimeOfDay(hour: 20, minute: 0),
      wellnessTime: _parseTimeOfDay(json['wellnessTime']) ?? const TimeOfDay(hour: 8, minute: 0),
      adaptiveTiming: json['adaptiveTiming'] ?? true,
      mutedCategories: List<String>.from(json['mutedCategories'] ?? []),
    );
  }

  static TimeOfDay? _parseTimeOfDay(String? timeString) {
    if (timeString == null) return null;
    final List<String> parts = timeString.split(':');
    if (parts.length != 2) return null;
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}

class NotificationException implements Exception {
  final String message;
  NotificationException(this.message);

  @override
  String toString() => 'NotificationException: $message';
}
