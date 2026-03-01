import 'package:flutter/material.dart';

/// Comprehensive onboarding data model for new users
class OnboardingData {
  // Personal Information
  String? fullName;
  String? preferredName;
  DateTime? dateOfBirth;
  int? age;
  
  // Health & Cycle Information
  DateTime? lastPeriodDate;
  int? averageCycleLength;
  int? averagePeriodLength;
  List<String> symptoms;
  List<String> cycleIrregularities;
  
  // Lifestyle Information
  LifestylePreferences? lifestyle;
  HealthGoals? healthGoals;
  NotificationPreferences? notificationPrefs;
  
  // Experience & Background
  bool isFirstTimeTracking;
  String? previousTrackingMethod;
  List<String> healthConcerns;
  
  // Privacy & Preferences
  bool shareDataForResearch;
  bool enableAIInsights;
  String? preferredLanguage;
  String? timeZone;

  OnboardingData({
    this.fullName,
    this.preferredName,
    this.dateOfBirth,
    this.age,
    this.lastPeriodDate,
    this.averageCycleLength,
    this.averagePeriodLength,
    this.symptoms = const [],
    this.cycleIrregularities = const [],
    this.lifestyle,
    this.healthGoals,
    this.notificationPrefs,
    this.isFirstTimeTracking = true,
    this.previousTrackingMethod,
    this.healthConcerns = const [],
    this.shareDataForResearch = false,
    this.enableAIInsights = true,
    this.preferredLanguage,
    this.timeZone,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'preferredName': preferredName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'age': age,
      'lastPeriodDate': lastPeriodDate?.toIso8601String(),
      'averageCycleLength': averageCycleLength,
      'averagePeriodLength': averagePeriodLength,
      'symptoms': symptoms,
      'cycleIrregularities': cycleIrregularities,
      'lifestyle': lifestyle?.toJson(),
      'healthGoals': healthGoals?.toJson(),
      'notificationPrefs': notificationPrefs?.toJson(),
      'isFirstTimeTracking': isFirstTimeTracking,
      'previousTrackingMethod': previousTrackingMethod,
      'healthConcerns': healthConcerns,
      'shareDataForResearch': shareDataForResearch,
      'enableAIInsights': enableAIInsights,
      'preferredLanguage': preferredLanguage,
      'timeZone': timeZone,
    };
  }

  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData(
      fullName: json['fullName'],
      preferredName: json['preferredName'],
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null,
      age: json['age'],
      lastPeriodDate: json['lastPeriodDate'] != null 
          ? DateTime.parse(json['lastPeriodDate']) 
          : null,
      averageCycleLength: json['averageCycleLength'],
      averagePeriodLength: json['averagePeriodLength'],
      symptoms: List<String>.from(json['symptoms'] ?? []),
      cycleIrregularities: List<String>.from(json['cycleIrregularities'] ?? []),
      lifestyle: json['lifestyle'] != null 
          ? LifestylePreferences.fromJson(json['lifestyle']) 
          : null,
      healthGoals: json['healthGoals'] != null 
          ? HealthGoals.fromJson(json['healthGoals']) 
          : null,
      notificationPrefs: json['notificationPrefs'] != null 
          ? NotificationPreferences.fromJson(json['notificationPrefs']) 
          : null,
      isFirstTimeTracking: json['isFirstTimeTracking'] ?? true,
      previousTrackingMethod: json['previousTrackingMethod'],
      healthConcerns: List<String>.from(json['healthConcerns'] ?? []),
      shareDataForResearch: json['shareDataForResearch'] ?? false,
      enableAIInsights: json['enableAIInsights'] ?? true,
      preferredLanguage: json['preferredLanguage'],
      timeZone: json['timeZone'],
    );
  }

  OnboardingData copyWith({
    String? fullName,
    String? preferredName,
    DateTime? dateOfBirth,
    int? age,
    DateTime? lastPeriodDate,
    int? averageCycleLength,
    int? averagePeriodLength,
    List<String>? symptoms,
    List<String>? cycleIrregularities,
    LifestylePreferences? lifestyle,
    HealthGoals? healthGoals,
    NotificationPreferences? notificationPrefs,
    bool? isFirstTimeTracking,
    String? previousTrackingMethod,
    List<String>? healthConcerns,
    bool? shareDataForResearch,
    bool? enableAIInsights,
    String? preferredLanguage,
    String? timeZone,
  }) {
    return OnboardingData(
      fullName: fullName ?? this.fullName,
      preferredName: preferredName ?? this.preferredName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      averagePeriodLength: averagePeriodLength ?? this.averagePeriodLength,
      symptoms: symptoms ?? this.symptoms,
      cycleIrregularities: cycleIrregularities ?? this.cycleIrregularities,
      lifestyle: lifestyle ?? this.lifestyle,
      healthGoals: healthGoals ?? this.healthGoals,
      notificationPrefs: notificationPrefs ?? this.notificationPrefs,
      isFirstTimeTracking: isFirstTimeTracking ?? this.isFirstTimeTracking,
      previousTrackingMethod: previousTrackingMethod ?? this.previousTrackingMethod,
      healthConcerns: healthConcerns ?? this.healthConcerns,
      shareDataForResearch: shareDataForResearch ?? this.shareDataForResearch,
      enableAIInsights: enableAIInsights ?? this.enableAIInsights,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      timeZone: timeZone ?? this.timeZone,
    );
  }
}

/// Lifestyle preferences model
class LifestylePreferences {
  int? exerciseFrequency; // 0-7 days per week
  int? stressLevel; // 1-5 scale
  int? sleepHours; // Average hours per night
  String? diet; // e.g., 'vegetarian', 'vegan', 'keto', 'regular'
  bool? drinks_alcohol;
  bool? smokes;
  bool? takesSupplements;
  List<String> supplements;
  List<String> medications;

  LifestylePreferences({
    this.exerciseFrequency,
    this.stressLevel,
    this.sleepHours,
    this.diet,
    this.drinks_alcohol,
    this.smokes,
    this.takesSupplements,
    this.supplements = const [],
    this.medications = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseFrequency': exerciseFrequency,
      'stressLevel': stressLevel,
      'sleepHours': sleepHours,
      'diet': diet,
      'drinks_alcohol': drinks_alcohol,
      'smokes': smokes,
      'takesSupplements': takesSupplements,
      'supplements': supplements,
      'medications': medications,
    };
  }

  factory LifestylePreferences.fromJson(Map<String, dynamic> json) {
    return LifestylePreferences(
      exerciseFrequency: json['exerciseFrequency'],
      stressLevel: json['stressLevel'],
      sleepHours: json['sleepHours'],
      diet: json['diet'],
      drinks_alcohol: json['drinks_alcohol'],
      smokes: json['smokes'],
      takesSupplements: json['takesSupplements'],
      supplements: List<String>.from(json['supplements'] ?? []),
      medications: List<String>.from(json['medications'] ?? []),
    );
  }
}

/// Health goals model
class HealthGoals {
  bool trackCycleRegularity;
  bool predictPeriods;
  bool manageSymptoms;
  bool improveFertility;
  bool trackMoodPatterns;
  bool monitorHealth;
  bool shareWithPartner;
  bool shareWithDoctor;
  List<String> customGoals;

  HealthGoals({
    this.trackCycleRegularity = true,
    this.predictPeriods = true,
    this.manageSymptoms = true,
    this.improveFertility = false,
    this.trackMoodPatterns = true,
    this.monitorHealth = true,
    this.shareWithPartner = false,
    this.shareWithDoctor = false,
    this.customGoals = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'trackCycleRegularity': trackCycleRegularity,
      'predictPeriods': predictPeriods,
      'manageSymptoms': manageSymptoms,
      'improveFertility': improveFertility,
      'trackMoodPatterns': trackMoodPatterns,
      'monitorHealth': monitorHealth,
      'shareWithPartner': shareWithPartner,
      'shareWithDoctor': shareWithDoctor,
      'customGoals': customGoals,
    };
  }

  factory HealthGoals.fromJson(Map<String, dynamic> json) {
    return HealthGoals(
      trackCycleRegularity: json['trackCycleRegularity'] ?? true,
      predictPeriods: json['predictPeriods'] ?? true,
      manageSymptoms: json['manageSymptoms'] ?? true,
      improveFertility: json['improveFertility'] ?? false,
      trackMoodPatterns: json['trackMoodPatterns'] ?? true,
      monitorHealth: json['monitorHealth'] ?? true,
      shareWithPartner: json['shareWithPartner'] ?? false,
      shareWithDoctor: json['shareWithDoctor'] ?? false,
      customGoals: List<String>.from(json['customGoals'] ?? []),
    );
  }
}

/// Notification preferences model
class NotificationPreferences {
  bool enableNotifications;
  bool periodReminders;
  bool ovulationReminders;
  bool symptomReminders;
  bool moodCheckIns;
  bool healthTips;
  TimeOfDay? reminderTime;
  int? daysBeforePeriod; // How many days before to notify
  List<int> weeklyReminderDays; // 1-7 (Monday = 1)

  NotificationPreferences({
    this.enableNotifications = true,
    this.periodReminders = true,
    this.ovulationReminders = true,
    this.symptomReminders = true,
    this.moodCheckIns = true,
    this.healthTips = true,
    this.reminderTime,
    this.daysBeforePeriod = 3,
    this.weeklyReminderDays = const [1, 3, 5], // Mon, Wed, Fri
  });

  Map<String, dynamic> toJson() {
    return {
      'enableNotifications': enableNotifications,
      'periodReminders': periodReminders,
      'ovulationReminders': ovulationReminders,
      'symptomReminders': symptomReminders,
      'moodCheckIns': moodCheckIns,
      'healthTips': healthTips,
      'reminderTime': reminderTime != null 
          ? {'hour': reminderTime!.hour, 'minute': reminderTime!.minute}
          : null,
      'daysBeforePeriod': daysBeforePeriod,
      'weeklyReminderDays': weeklyReminderDays,
    };
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      enableNotifications: json['enableNotifications'] ?? true,
      periodReminders: json['periodReminders'] ?? true,
      ovulationReminders: json['ovulationReminders'] ?? true,
      symptomReminders: json['symptomReminders'] ?? true,
      moodCheckIns: json['moodCheckIns'] ?? true,
      healthTips: json['healthTips'] ?? true,
      reminderTime: json['reminderTime'] != null 
          ? TimeOfDay(
              hour: json['reminderTime']['hour'],
              minute: json['reminderTime']['minute'],
            )
          : null,
      daysBeforePeriod: json['daysBeforePeriod'] ?? 3,
      weeklyReminderDays: List<int>.from(json['weeklyReminderDays'] ?? [1, 3, 5]),
    );
  }
}

/// Onboarding step definitions
enum OnboardingStep {
  welcome,
  personalInfo,
  healthBasics,
  cycleHistory,
  lifestyle,
  goals,
  notifications,
  privacy,
  complete,
}

extension OnboardingStepExtension on OnboardingStep {
  String get title {
    switch (this) {
      case OnboardingStep.welcome:
        return 'Welcome to FlowSense';
      case OnboardingStep.personalInfo:
        return 'Personal Information';
      case OnboardingStep.healthBasics:
        return 'Health Basics';
      case OnboardingStep.cycleHistory:
        return 'Cycle History';
      case OnboardingStep.lifestyle:
        return 'Lifestyle';
      case OnboardingStep.goals:
        return 'Health Goals';
      case OnboardingStep.notifications:
        return 'Notifications';
      case OnboardingStep.privacy:
        return 'Privacy Settings';
      case OnboardingStep.complete:
        return 'Setup Complete';
    }
  }

  String get description {
    switch (this) {
      case OnboardingStep.welcome:
        return 'Let\'s get you set up for personalized cycle tracking';
      case OnboardingStep.personalInfo:
        return 'Tell us a bit about yourself';
      case OnboardingStep.healthBasics:
        return 'Basic health information';
      case OnboardingStep.cycleHistory:
        return 'Information about your menstrual cycle';
      case OnboardingStep.lifestyle:
        return 'Your daily habits and preferences';
      case OnboardingStep.goals:
        return 'What would you like to achieve?';
      case OnboardingStep.notifications:
        return 'How would you like to be reminded?';
      case OnboardingStep.privacy:
        return 'Your data, your choice';
      case OnboardingStep.complete:
        return 'You\'re all set to start tracking!';
    }
  }

  IconData get icon {
    switch (this) {
      case OnboardingStep.welcome:
        return Icons.waving_hand;
      case OnboardingStep.personalInfo:
        return Icons.person_outline;
      case OnboardingStep.healthBasics:
        return Icons.favorite_outline;
      case OnboardingStep.cycleHistory:
        return Icons.calendar_today;
      case OnboardingStep.lifestyle:
        return Icons.fitness_center;
      case OnboardingStep.goals:
        return Icons.flag_outlined;
      case OnboardingStep.notifications:
        return Icons.notifications_outlined;
      case OnboardingStep.privacy:
        return Icons.privacy_tip_outlined;
      case OnboardingStep.complete:
        return Icons.check_circle_outline;
    }
  }

  double get progress {
    switch (this) {
      case OnboardingStep.welcome:
        return 0.0;
      case OnboardingStep.personalInfo:
        return 0.125;
      case OnboardingStep.healthBasics:
        return 0.25;
      case OnboardingStep.cycleHistory:
        return 0.375;
      case OnboardingStep.lifestyle:
        return 0.5;
      case OnboardingStep.goals:
        return 0.625;
      case OnboardingStep.notifications:
        return 0.75;
      case OnboardingStep.privacy:
        return 0.875;
      case OnboardingStep.complete:
        return 1.0;
    }
  }
}

/// Common symptoms for selection
class CommonSymptoms {
  static const List<String> physical = [
    'Cramping',
    'Bloating',
    'Breast tenderness',
    'Headache',
    'Back pain',
    'Acne',
    'Fatigue',
    'Food cravings',
    'Hot flashes',
    'Nausea',
  ];

  static const List<String> emotional = [
    'Mood swings',
    'Irritability',
    'Anxiety',
    'Depression',
    'Stress',
    'Sadness',
    'Anger',
    'Euphoria',
    'Confusion',
    'Sensitivity',
  ];

  static const List<String> all = [...physical, ...emotional];
}

/// Common cycle irregularities
class CycleIrregularities {
  static const List<String> types = [
    'Irregular periods',
    'Heavy bleeding',
    'Light bleeding',
    'Missed periods',
    'Spotting between periods',
    'Long cycles (35+ days)',
    'Short cycles (less than 21 days)',
    'Painful periods',
    'No periods for 3+ months',
    'Very long periods (7+ days)',
  ];
}
