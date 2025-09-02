import 'package:flutter/foundation.dart';
import '../models/personalization.dart';
import '../models/user_profile.dart';
import '../services/hyper_personalization_service.dart';
import '../services/notification_adapter.dart';

class PersonalizationExampleResult {
  final List<Reminder> reminders;
  final NotificationPayload phaseNotification;

  PersonalizationExampleResult({
    required this.reminders,
    required this.phaseNotification,
  });
}

Future<PersonalizationExampleResult> demoPersonalization() async {
  // Example user with locale and basic preferences
  final user = UserProfile(
    id: 'user_123',
    age: 29,
    lifestyle: 'active',
    healthConcerns: const [],
    preferences: const {'locale': 'en'},
    personalizedBaselines: const {},
    adaptationHistory: const [],
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
  );

  const currentPhase = 'luteal';
  const goals = <String>['Strength training 3x/week'];

  // Initialize service (no-op if already initialized)
  await HyperPersonalizationService.instance.initialize();

  // Build adaptive reminders
  final reminders = HyperPersonalizationService.instance.generateAdaptiveReminders(
    user: user,
    currentPhase: currentPhase,
    goals: goals,
    behaviorSignals: {
      'adherence_rate': 0.55,
      'prefers_morning': true,
    },
  );

  // Build a phase-based notification
  final phaseNotification = HyperPersonalizationService.instance.buildPhaseNotification(
    phase: currentPhase,
    user: user,
  );

  // Optionally schedule via an adapter (noop by default)
  final adapter = NoopNotificationAdapter();
  await adapter.schedule(
    payload: phaseNotification,
    scheduledAt: DateTime.now().add(const Duration(minutes: 1)),
  );

  debugPrint('Generated ${reminders.length} reminders and a phase notification');

  return PersonalizationExampleResult(
    reminders: reminders,
    phaseNotification: phaseNotification,
  );
}

