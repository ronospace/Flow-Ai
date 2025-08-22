import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('🔔 Initializing Notification Service...');

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    const macosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: macosSettings,
    );

    await _notifications.initialize(settings);
    _isInitialized = true;
    
    debugPrint('✅ Notification Service initialized');
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();
    
    const androidDetails = AndroidNotificationDetails(
      'flowsense_reminders',
      'FlowSense Reminders',
      channelDescription: 'Smart reminders for cycle tracking',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const macosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: macosDetails,
    );

    // Convert DateTime to TZDateTime
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
    
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      notificationDetails,
      payload: payload,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> schedulePeriodicReminder({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await scheduleNotification(
      id: 0,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );
  }

  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await initialize();
    await _notifications.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) await initialize();
    await _notifications.cancel(id);
  }

  Future<bool> requestPermission() async {
    if (!_isInitialized) await initialize();
    
    // Request permissions for different platforms
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        return await androidPlugin.requestNotificationsPermission() ?? false;
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        return await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ?? false;
      }
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      final macOSPlugin = _notifications.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
      if (macOSPlugin != null) {
        return await macOSPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ?? false;
      }
    }
    
    // Default to true for unsupported platforms
    return true;
  }

  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) await initialize();
    
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        return await androidPlugin.areNotificationsEnabled() ?? false;
      }
    }
    
    // For other platforms, assume true
    return true;
  }
}
