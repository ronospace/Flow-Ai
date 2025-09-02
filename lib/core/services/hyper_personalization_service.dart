import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/personalization.dart';

/// Hyper-Personalization Service
/// - Multi-language and emotional tone adaptation
/// - Adaptive reminders based on behavior
/// - Cycle phase-based notifications
class HyperPersonalizationService {
  static final HyperPersonalizationService _instance = HyperPersonalizationService._internal();
  static HyperPersonalizationService get instance => _instance;
  HyperPersonalizationService._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    debugPrint('✨ Initializing Hyper-Personalization Service...');
    // Placeholder: load tone dictionaries, localization packs, and user defaults
    _initialized = true;
    debugPrint('✅ Hyper-Personalization Service initialized');
  }

  // Tone adaptation: adjusts message style to target language and tone profile
  String adaptTone({
    required String message,
    required String targetLocale,
    ToneProfile tone = ToneProfile.supportive,
  }) {
    final localized = _localize(message, targetLocale);
    return _applyTone(localized, tone, targetLocale);
  }

  // Generate adaptive reminders based on user behavior and goals
  List<Reminder> generateAdaptiveReminders({
    required UserProfile user,
    required String currentPhase,
    required List<String> goals,
    Map<String, dynamic>? behaviorSignals, // e.g., last_open_time, adherence_rate
  }) {
    final locale = _getLocale(user);
    final adherence = (behaviorSignals?['adherence_rate'] as num?)?.toDouble() ?? 0.7;
    final prefersMorning = behaviorSignals?['prefers_morning'] == true;

    final List<Reminder> reminders = [];

    // Hydration reminder
    reminders.add(Reminder(
      id: 'hydrate-morning',
      title: _t('Hydration boost', locale),
      body: _t('Start your day with a glass of water', locale),
      timeWindow: prefersMorning ? TimeWindow.morning : TimeWindow.midMorning,
      priority: adherence < 0.6 ? ReminderPriority.high : ReminderPriority.medium,
      category: ReminderCategory.hydration,
    ));

    // Movement reminder (phase aware intensity)
    final movementBody = currentPhase == 'menstrual'
        ? _t('Gentle movement break: 5–10 min stretch', locale)
        : _t('Stand up and get a quick movement break', locale);
    reminders.add(Reminder(
      id: 'move-midday',
      title: _t('Move a little', locale),
      body: movementBody,
      timeWindow: TimeWindow.afternoon,
      priority: ReminderPriority.medium,
      category: ReminderCategory.movement,
    ));

    // Sleep wind-down reminder (luteal heavier)
    final windDown = currentPhase == 'luteal'
        ? _t('Earlier wind-down routine tonight for deeper sleep', locale)
        : _t('Begin your wind-down routine', locale);
    reminders.add(Reminder(
      id: 'sleep-evening',
      title: _t('Wind-down cue', locale),
      body: windDown,
      timeWindow: TimeWindow.evening,
      priority: adherence < 0.5 ? ReminderPriority.high : ReminderPriority.medium,
      category: ReminderCategory.sleep,
    ));

    // Goal reinforcement reminder (if goals provided)
    if (goals.isNotEmpty) {
      reminders.add(Reminder(
        id: 'goal-reinforcement',
        title: _t('You\'re on track', locale),
        body: '${_t('Tiny steps count towards: ', locale)}${goals.first}',
        timeWindow: prefersMorning ? TimeWindow.morning : TimeWindow.night,
        priority: ReminderPriority.low,
        category: ReminderCategory.motivation,
      ));
    }

    return reminders;
  }

  // Cycle phase-based push notification payloads
  NotificationPayload buildPhaseNotification({
    required String phase,
    required UserProfile user,
  }) {
    final locale = _getLocale(user);
    late final String title;
    late final String body;

    switch (phase) {
      case 'menstrual':
        title = _t('Rest & restore', locale);
        body = _t('Lower intensity today. Your body is rebuilding—gentle care goes far.', locale);
        break;
      case 'follicular':
        title = _t('Momentum rising', locale);
        body = _t('Great time to plan and build. Try a strength-focused session.', locale);
        break;
      case 'ovulatory':
        title = _t('Peak power', locale);
        body = _t('Energy is high—lean into your big tasks and confident movement.', locale);
        break;
      case 'luteal':
        title = _t('Steady & supported', locale);
        body = _t('Focus on stability, sleep, and emotional care. You\'ve got this.', locale);
        break;
      default:
        title = _t('Daily focus', locale);
        body = _t('Honor your body. Small consistent actions compound.', locale);
    }

    return NotificationPayload(
      title: title,
      body: body,
      data: {
        'phase': phase,
        'category': 'cycle_phase',
'locale': locale,
      },
    );
  }

  // Helpers
  String _localize(String message, String locale) {
    // Placeholder minimal localization stub
    if (locale.startsWith('es')) {
      // Simple demo translations
      return message
          .replaceAll('Hydration boost', 'Impulso de hidratación')
          .replaceAll('Start your day with a glass of water', 'Comienza tu día con un vaso de agua')
          .replaceAll('Move a little', 'Muévete un poco')
          .replaceAll('Begin your wind-down routine', 'Comienza tu rutina para relajarte')
          .replaceAll('Earlier wind-down routine tonight for deeper sleep', 'Relájate más temprano esta noche para un sueño más profundo')
          .replaceAll('Rest & restore', 'Descansa y recupérate')
          .replaceAll('Momentum rising', 'Impulso en aumento')
          .replaceAll('Peak power', 'Poder máximo')
          .replaceAll('Steady & supported', 'Constante y con apoyo')
          .replaceAll('Daily focus', 'Enfoque diario')
          .replaceAll('Lower intensity today. Your body is rebuilding—gentle care goes far.', 'Menor intensidad hoy. Tu cuerpo se está recuperando—el cuidado suave ayuda mucho.')
          .replaceAll('Great time to plan and build. Try a strength-focused session.', 'Buen momento para planear y construir. Prueba una sesión enfocada en fuerza.')
          .replaceAll('Energy is high—lean into your big tasks and confident movement.', 'La energía está alta—apóyate en tus grandes tareas y movimiento con confianza.')
          .replaceAll('Focus on stability, sleep, and emotional care. You\'ve got this.', 'Enfócate en estabilidad, sueño y cuidado emocional. Tú puedes.')
          .replaceAll('Honor your body. Small consistent actions compound.', 'Honra tu cuerpo. Acciones pequeñas y consistentes se acumulan.');
    }
    return message; // default passthrough
  }

  String _applyTone(String message, ToneProfile tone, String locale) {
    // Lightweight tonal adjustments by simple prefixes/suffixes
    switch (tone) {
      case ToneProfile.supportive:
        return _wrap(message, prefix: '🤗 ', suffix: ' ${_t('You\'re doing great.', locale)}');
      case ToneProfile.coach:
        return _wrap(message, prefix: '🎯 ', suffix: ' ${_t('Let\'s make it happen.', locale)}');
      case ToneProfile.gentle:
        return _wrap(message, prefix: '🌿 ', suffix: ' ${_t('Take it at your pace.', locale)}');
      case ToneProfile.celebratory:
        return _wrap(message, prefix: '✨ ', suffix: ' ${_t('Nice work!', locale)}');
    }
  }

  String _t(String message, String locale) => _localize(message, locale);

  String _wrap(String base, {String? prefix, String? suffix}) =>
      '${prefix ?? ''}$base${suffix ?? ''}'.trim();

  String _getLocale(UserProfile user) {
    final prefs = user.preferences;
    final loc = prefs['locale'];
    if (loc is String && loc.isNotEmpty) return loc;
    return 'en';
  }
}

