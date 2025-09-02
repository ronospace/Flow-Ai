enum ToneProfile { supportive, coach, gentle, celebratory }

enum ReminderPriority { low, medium, high }

enum ReminderCategory { hydration, movement, sleep, nutrition, motivation }

enum TimeWindow { morning, midMorning, afternoon, evening, night }

class Reminder {
  final String id;
  final String title;
  final String body;
  final TimeWindow timeWindow;
  final ReminderPriority priority;
  final ReminderCategory category;
  final Map<String, dynamic>? metadata;

  Reminder({
    required this.id,
    required this.title,
    required this.body,
    required this.timeWindow,
    required this.priority,
    required this.category,
    this.metadata,
  });
}

class NotificationPayload {
  final String title;
  final String body;
  final Map<String, dynamic>? data;

  NotificationPayload({
    required this.title,
    required this.body,
    this.data,
  });
}

