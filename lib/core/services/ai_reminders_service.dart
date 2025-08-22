import '../database/database_service.dart';
import 'user_preferences_service.dart';
import 'cycle_calculation_engine.dart';
import 'notification_service.dart';

class AIRemindersService {
  final DatabaseService _databaseService = DatabaseService();
  final UserPreferencesService _preferencesService = UserPreferencesService();
  final CycleCalculationEngine _calculationEngine = CycleCalculationEngine.withoutDatabase();
  final NotificationService _notificationService = NotificationService.instance;
  
  // AI learning data
  final Map<String, double> _userBehaviorWeights = {};
  final Map<String, List<DateTime>> _responseHistory = {};
  
  // Initialize the service
  Future<void> initialize() async {
    await _loadUserBehaviorData();
    await _scheduleIntelligentReminders();
  }
  
  // Schedule all types of intelligent reminders
  Future<void> _scheduleIntelligentReminders() async {
    await _scheduleCycleReminders();
    await _scheduleMedicationReminders();
    await _scheduleHealthGoalReminders();
    await _scheduleSymptomTrackingReminders();
    await _scheduleWellnessCheckReminders();
  }
  
  // Cycle-based reminders
  Future<void> _scheduleCycleReminders() async {
    final cycles = await _databaseService.getCyclesInRange(
      DateTime.now().subtract(const Duration(days: 365)),
      DateTime.now(),
    );
    
    if (cycles.isEmpty) return;
    
    final prediction = _calculationEngine.calculateNextCycle(cycles);
    if (prediction == null) return;
    
    // Period start reminder
    await _schedulePeriodStartReminder(prediction.predictedStartDate);
    
    // Ovulation reminder
    final ovulationDate = prediction.fertileWindow.peak;
    await _scheduleOvulationReminder(ovulationDate);
    
    // PMS reminder
    final pmsDate = prediction.predictedStartDate.subtract(const Duration(days: 3));
    await _schedulePMSReminder(pmsDate);
    
    // Fertile window reminders
    await _scheduleFertileWindowReminders(prediction);
  }
  
  Future<void> _schedulePeriodStartReminder(DateTime predictedStart) async {
    final userPrefs = _preferencesService.reminderSettings;
    if (!(userPrefs['period'] ?? true)) return;
    
    final optimalTime = await _getOptimalReminderTime('period');
    final reminderDate = DateTime(
      predictedStart.year,
      predictedStart.month,
      predictedStart.day - 1,
      optimalTime.hour,
      optimalTime.minute,
    );
    
    if (reminderDate.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: 1001,
        title: _getPersonalizedTitle('period_reminder'),
        body: _getPersonalizedMessage('period_reminder'),
        scheduledDate: reminderDate,
        payload: 'period_reminder',
      );
    }
  }
  
  Future<void> _scheduleOvulationReminder(DateTime ovulationDate) async {
    final userPrefs = _preferencesService.reminderSettings;
    if (!(userPrefs['ovulationReminder']?['enabled'] ?? true)) return;
    
    final optimalTime = await _getOptimalReminderTime('ovulation');
    final reminderDate = DateTime(
      ovulationDate.year,
      ovulationDate.month,
      ovulationDate.day,
      optimalTime.hour,
      optimalTime.minute,
    );
    
    if (reminderDate.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: 1002,
        title: _getPersonalizedTitle('ovulation_reminder'),
        body: _getPersonalizedMessage('ovulation_reminder'),
        scheduledDate: reminderDate,
        payload: 'ovulation_reminder',
      );
    }
  }
  
  Future<void> _schedulePMSReminder(DateTime pmsDate) async {
    final optimalTime = await _getOptimalReminderTime('pms');
    final reminderDate = DateTime(
      pmsDate.year,
      pmsDate.month,
      pmsDate.day,
      optimalTime.hour,
      optimalTime.minute,
    );
    
    if (reminderDate.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: 1003,
        title: _getPersonalizedTitle('pms_reminder'),
        body: _getPersonalizedMessage('pms_reminder'),
        scheduledDate: reminderDate,
        payload: 'pms_reminder',
      );
    }
  }
  
  Future<void> _scheduleFertileWindowReminders(prediction) async {
    // Schedule multiple reminders during fertile window
    for (int i = 0; i < 6; i++) {
      final fertileDate = prediction.fertileWindow.start.add(Duration(days: i));
      
      final optimalTime = await _getOptimalReminderTime('fertile');
      final reminderDate = DateTime(
        fertileDate.year,
        fertileDate.month,
        fertileDate.day,
        optimalTime.hour,
        optimalTime.minute,
      );
      
      if (reminderDate.isAfter(DateTime.now())) {
        await _notificationService.scheduleNotification(
          id: 1010 + i,
          title: _getPersonalizedTitle('fertile_reminder'),
          body: _getPersonalizedMessage('fertile_reminder'),
          scheduledDate: reminderDate,
          payload: 'fertile_reminder',
        );
      }
    }
  }
  
  // Medication reminders
  Future<void> _scheduleMedicationReminders() async {
    final medications = await _getMedicationList();
    
    for (final medication in medications) {
      await _scheduleMedicationReminder(medication);
    }
  }
  
  Future<void> _scheduleMedicationReminder(Map<String, dynamic> medication) async {
    final frequency = medication['frequency'] as String; // daily, weekly, etc.
    final times = medication['times'] as List<String>; // ['08:00', '20:00']
    final name = medication['name'] as String;
    
    for (int i = 0; i < 30; i++) { // Schedule for next 30 days
      final date = DateTime.now().add(Duration(days: i));
      
      if (_shouldScheduleMedication(frequency, date)) {
        for (int timeIndex = 0; timeIndex < times.length; timeIndex++) {
          final timeStr = times[timeIndex];
          final timeParts = timeStr.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          
          final reminderDate = DateTime(date.year, date.month, date.day, hour, minute);
          
          if (reminderDate.isAfter(DateTime.now())) {
            await _notificationService.scheduleNotification(
              id: 2000 + (i * 10) + timeIndex,
              title: 'Medication Reminder 💊',
              body: 'Time to take your $name',
              scheduledDate: reminderDate,
              payload: 'medication_reminder:$name',
            );
          }
        }
      }
    }
  }
  
  // Health goal reminders
  Future<void> _scheduleHealthGoalReminders() async {
    final goals = await _getHealthGoals();
    
    for (final goal in goals) {
      await _scheduleHealthGoalReminder(goal);
    }
  }
  
  Future<void> _scheduleHealthGoalReminder(Map<String, dynamic> goal) async {
    final type = goal['type'] as String; // water, exercise, sleep, etc.
    final target = goal['target'] as int;
    final frequency = goal['frequency'] as String; // daily, weekly
    
    final optimalTime = await _getOptimalReminderTime(type);
    
    for (int i = 1; i <= 30; i++) {
      final date = DateTime.now().add(Duration(days: i));
      
      if (_shouldScheduleGoal(frequency, date)) {
        final reminderDate = DateTime(
          date.year,
          date.month,
          date.day,
          optimalTime.hour,
          optimalTime.minute,
        );
        
        if (reminderDate.isAfter(DateTime.now())) {
          await _notificationService.scheduleNotification(
            id: 3000 + i,
            title: _getHealthGoalTitle(type),
            body: _getHealthGoalMessage(type, target),
            scheduledDate: reminderDate,
            payload: 'health_goal:$type',
          );
        }
      }
    }
  }
  
  // Symptom tracking reminders
  Future<void> _scheduleSymptomTrackingReminders() async {
    final userPrefs = _preferencesService.reminderSettings;
    if (!(userPrefs['symptomReminder']?['enabled'] ?? false)) return;
    
    final optimalTime = await _getOptimalReminderTime('symptoms');
    
    for (int i = 1; i <= 30; i++) {
      final date = DateTime.now().add(Duration(days: i));
      final reminderDate = DateTime(
        date.year,
        date.month,
        date.day,
        optimalTime.hour,
        optimalTime.minute,
      );
      
      if (reminderDate.isAfter(DateTime.now())) {
        await _notificationService.scheduleNotification(
          id: 4000 + i,
          title: _getPersonalizedTitle('symptom_reminder'),
          body: _getPersonalizedMessage('symptom_reminder'),
          scheduledDate: reminderDate,
          payload: 'symptom_reminder',
        );
      }
    }
  }
  
  // Wellness check reminders
  Future<void> _scheduleWellnessCheckReminders() async {
    final optimalTime = await _getOptimalReminderTime('wellness');
    
    // Weekly wellness check
    for (int week = 1; week <= 12; week++) {
      final date = DateTime.now().add(Duration(days: week * 7));
      final reminderDate = DateTime(
        date.year,
        date.month,
        date.day,
        optimalTime.hour,
        optimalTime.minute,
      );
      
      if (reminderDate.isAfter(DateTime.now())) {
        await _notificationService.scheduleNotification(
          id: 5000 + week,
          title: _getPersonalizedTitle('wellness_check'),
          body: _getPersonalizedMessage('wellness_check'),
          scheduledDate: reminderDate,
          payload: 'wellness_check',
        );
      }
    }
  }
  
  // AI-powered optimal timing
  Future<DateTime> _getOptimalReminderTime(String reminderType) async {
    final responseHistory = _responseHistory[reminderType] ?? [];
    
    if (responseHistory.isEmpty) {
      // Default times based on reminder type
      switch (reminderType) {
        case 'period':
        case 'pms':
          return DateTime(2023, 1, 1, 19, 0); // 7 PM
        case 'ovulation':
        case 'fertile':
          return DateTime(2023, 1, 1, 8, 0); // 8 AM
        case 'medication':
          return DateTime(2023, 1, 1, 8, 0); // 8 AM
        case 'symptoms':
          return DateTime(2023, 1, 1, 21, 0); // 9 PM
        case 'wellness':
          return DateTime(2023, 1, 1, 10, 0); // 10 AM
        default:
          return DateTime(2023, 1, 1, 9, 0); // 9 AM
      }
    }
    
    // Analyze response history to find optimal time
    final hourCounts = <int, int>{};
    for (final response in responseHistory) {
      hourCounts[response.hour] = (hourCounts[response.hour] ?? 0) + 1;
    }
    
    final optimalHour = hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    return DateTime(2023, 1, 1, optimalHour, 0);
  }
  
  // Personalized message generation
  String _getPersonalizedTitle(String reminderType) {
    final titles = _getTitlesForType(reminderType);
    final weight = _userBehaviorWeights[reminderType] ?? 1.0;
    
    // Higher weight = more urgent/direct titles
    if (weight > 1.5) {
      return titles['urgent'] ?? titles['default']!;
    } else if (weight < 0.5) {
      return titles['gentle'] ?? titles['default']!;
    } else {
      return titles['default']!;
    }
  }
  
  String _getPersonalizedMessage(String reminderType) {
    final messages = _getMessagesForType(reminderType);
    final weight = _userBehaviorWeights[reminderType] ?? 1.0;
    
    if (weight > 1.5) {
      return messages['urgent'] ?? messages['default']!;
    } else if (weight < 0.5) {
      return messages['gentle'] ?? messages['default']!;
    } else {
      return messages['default']!;
    }
  }
  
  Map<String, String> _getTitlesForType(String type) {
    switch (type) {
      case 'period_reminder':
        return {
          'default': 'Period Starting Soon 🌸',
          'gentle': 'Your cycle update is here 💕',
          'urgent': 'Period Alert! Be Prepared 🚨',
        };
      case 'ovulation_reminder':
        return {
          'default': 'Ovulation Day 🥚',
          'gentle': 'Fertile window begins ✨',
          'urgent': 'Peak Fertility Today! 🔥',
        };
      case 'pms_reminder':
        return {
          'default': 'PMS Alert 💙',
          'gentle': 'Take care of yourself 🤗',
          'urgent': 'PMS symptoms may start soon ⚠️',
        };
      case 'fertile_reminder':
        return {
          'default': 'Fertile Window 🌟',
          'gentle': 'You are in your fertile phase 🌱',
          'urgent': 'High Fertility Day! 🎯',
        };
      case 'symptom_reminder':
        return {
          'default': 'Daily Check-in 📝',
          'gentle': 'How are you feeling today? 😊',
          'urgent': 'Track your symptoms now! ⏰',
        };
      case 'wellness_check':
        return {
          'default': 'Weekly Wellness Check 💆‍♀️',
          'gentle': 'Time for your wellness review 🌿',
          'urgent': 'Important: Complete wellness check! 📊',
        };
      default:
        return {'default': 'FlowSense Reminder 🌸'};
    }
  }
  
  Map<String, String> _getMessagesForType(String type) {
    switch (type) {
      case 'period_reminder':
        return {
          'default': 'Your period is expected to start tomorrow. Make sure you have supplies ready!',
          'gentle': 'Tomorrow might be the start of your new cycle. Gentle reminder to prepare! 💕',
          'urgent': 'Period starts tomorrow! Stock up on supplies and prepare your comfort kit now.',
        };
      case 'ovulation_reminder':
        return {
          'default': 'You\'re ovulating today! This is your most fertile day.',
          'gentle': 'Today marks your ovulation day. Your body is doing amazing things! ✨',
          'urgent': 'Ovulation day is here! Peak fertility window - take action if trying to conceive.',
        };
      case 'pms_reminder':
        return {
          'default': 'PMS symptoms may start soon. Consider self-care activities.',
          'gentle': 'Your body might need extra care in the coming days. Be kind to yourself! 🤗',
          'urgent': 'PMS alert! Prepare your coping strategies and comfort measures now.',
        };
      case 'fertile_reminder':
        return {
          'default': 'You\'re in your fertile window. Track any symptoms or changes.',
          'gentle': 'Your fertile phase continues. Listen to your body\'s signals 🌱',
          'urgent': 'High fertility day! Important for conception planning.',
        };
      case 'symptom_reminder':
        return {
          'default': 'Time for your daily symptom check. How are you feeling today?',
          'gentle': 'A gentle reminder to check in with your body today 😊',
          'urgent': 'Don\'t forget to log your symptoms! Consistency helps track patterns.',
        };
      case 'wellness_check':
        return {
          'default': 'Time for your weekly wellness review. Check your progress and goals.',
          'gentle': 'Weekly reflection time! Celebrate your health journey this week 🌿',
          'urgent': 'Complete your wellness check now! Important for tracking your health trends.',
        };
      default:
        return {'default': 'Time to check in with FlowSense!'};
    }
  }
  
  String _getHealthGoalTitle(String type) {
    switch (type) {
      case 'water':
        return 'Hydration Reminder 💧';
      case 'exercise':
        return 'Movement Time 🏃‍♀️';
      case 'sleep':
        return 'Sleep Schedule 😴';
      case 'meditation':
        return 'Mindfulness Moment 🧘‍♀️';
      default:
        return 'Health Goal Reminder 🎯';
    }
  }
  
  String _getHealthGoalMessage(String type, int target) {
    switch (type) {
      case 'water':
        return 'Aim for $target glasses of water today! Stay hydrated 💧';
      case 'exercise':
        return 'Try to get $target minutes of movement today! Your body will thank you 💪';
      case 'sleep':
        return 'Wind down soon to get $target hours of quality sleep tonight 🌙';
      case 'meditation':
        return 'Take $target minutes for mindfulness today. Find your center 🧘‍♀️';
      default:
        return 'Work towards your goal of $target today! You\'ve got this 🌟';
    }
  }
  
  // User behavior learning
  void recordReminderResponse(String reminderType, DateTime responseTime, bool responded) {
    if (responded) {
      _responseHistory.putIfAbsent(reminderType, () => []).add(responseTime);
      _userBehaviorWeights[reminderType] = (_userBehaviorWeights[reminderType] ?? 1.0) * 1.1;
    } else {
      _userBehaviorWeights[reminderType] = (_userBehaviorWeights[reminderType] ?? 1.0) * 0.9;
    }
    
    _saveUserBehaviorData();
  }
  
  Future<void> _loadUserBehaviorData() async {
    // Load from preferences or database
  }
  
  Future<void> _saveUserBehaviorData() async {
    // Save to preferences or database
  }
  
  // Helper methods
  bool _shouldScheduleMedication(String frequency, DateTime date) {
    switch (frequency) {
      case 'daily':
        return true;
      case 'weekly':
        return date.weekday == DateTime.sunday;
      case 'monthly':
        return date.day == 1;
      default:
        return false;
    }
  }
  
  bool _shouldScheduleGoal(String frequency, DateTime date) {
    switch (frequency) {
      case 'daily':
        return true;
      case 'weekly':
        return date.weekday == DateTime.monday;
      case 'monthly':
        return date.day == 1;
      default:
        return false;
    }
  }
  
  Future<List<Map<String, dynamic>>> _getMedicationList() async {
    // Return medications from user preferences or database
    return [
      {
        'name': 'Vitamin D',
        'frequency': 'daily',
        'times': ['08:00'],
      },
      {
        'name': 'Iron Supplement',
        'frequency': 'daily',
        'times': ['12:00'],
      },
    ];
  }
  
  Future<List<Map<String, dynamic>>> _getHealthGoals() async {
    // Return health goals from user preferences
    return [
      {
        'type': 'water',
        'target': 8,
        'frequency': 'daily',
      },
      {
        'type': 'exercise',
        'target': 30,
        'frequency': 'daily',
      },
      {
        'type': 'sleep',
        'target': 8,
        'frequency': 'daily',
      },
    ];
  }
  
  // Smart reminder optimization
  Future<void> optimizeReminders() async {
    // Analyze user behavior and adjust reminder timing and frequency
    for (final reminderType in _userBehaviorWeights.keys) {
      final weight = _userBehaviorWeights[reminderType]!;
      
      if (weight < 0.3) {
        // User rarely responds - reduce frequency or change approach
        await _adjustReminderFrequency(reminderType, 'reduce');
      } else if (weight > 2.0) {
        // User is very responsive - can increase frequency if beneficial
        await _adjustReminderFrequency(reminderType, 'increase');
      }
    }
  }
  
  Future<void> _adjustReminderFrequency(String reminderType, String action) async {
    // Implementation for adjusting reminder frequency based on user behavior
  }
  
  // Clear all reminders
  Future<void> clearAllReminders() async {
    await _notificationService.cancelAllNotifications();
  }
  
  // Reschedule all reminders
  Future<void> rescheduleAllReminders() async {
    await clearAllReminders();
    await _scheduleIntelligentReminders();
  }
}
