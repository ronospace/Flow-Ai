import '../models/personalization.dart';

abstract class NotificationAdapter {
  Future<void> schedule({
    required NotificationPayload payload,
    required DateTime scheduledAt,
  });
}

class NoopNotificationAdapter implements NotificationAdapter {
  @override
  Future<void> schedule({
    required NotificationPayload payload,
    required DateTime scheduledAt,
  }) async {
    // No-op: useful in tests or when notifications are disabled
    return;
  }
}

