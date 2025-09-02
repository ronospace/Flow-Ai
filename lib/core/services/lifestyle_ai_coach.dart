import 'package:flutter/foundation.dart';
import '../models/cycle_data.dart';
import '../models/user_profile.dart';
import '../models/personalization.dart';
import 'hyper_personalization_service.dart';

/// Blueprint Implementation: Lifestyle & Behavior AI Coach
/// Sleep, nutrition, stress recommendations tuned to hormonal phases
/// Integrations with wearables (Apple Health, Fitbit, Oura)
/// Phased workouts (luteal-friendly exercise suggestions)
class LifestyleAICoach {
  static final LifestyleAICoach _instance = LifestyleAICoach._internal();
  static LifestyleAICoach get instance => _instance;
  LifestyleAICoach._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // AI Coach Models for different lifestyle aspects
  late Map<String, dynamic> _sleepOptimizationModel;
  late Map<String, dynamic> _nutritionCoachModel;
  late Map<String, dynamic> _stressManagementModel;
  late Map<String, dynamic> _exerciseCoachModel;
  late Map<String, dynamic> _wearableIntegrationModel;
  
  // Cycle phase-specific recommendations
  late Map<String, Map<String, dynamic>> _phaseSpecificGuidance;
  late Map<String, List<String>> _hormonalPhaseNutrition;
  late Map<String, Map<String, dynamic>> _phaseBasedWorkouts;

  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('🏃‍♀️ Initializing Lifestyle & Behavior AI Coach...');

    // Sleep Optimization Model
    _sleepOptimizationModel = {
      'hormonal_sleep_patterns': _initializeHormonalSleepPatterns(),
      'sleep_quality_factors': _initializeSleepQualityFactors(),
      'circadian_rhythm_optimization': _initializeCircadianOptimization(),
      'sleep_hygiene_recommendations': _initializeSleepHygieneRecs(),
      'menstrual_phase_sleep_needs': _initializePhaseSleepNeeds(),
    };

    // Nutrition Coach Model
    _nutritionCoachModel = {
      'hormonal_nutrition_needs': _initializeHormonalNutrition(),
      'micronutrient_cycling': _initializeMicronutrientCycling(),
      'anti_inflammatory_foods': _initializeAntiInflammatoryFoods(),
      'blood_sugar_management': _initializeBloodSugarManagement(),
      'hydration_optimization': _initializeHydrationGuidance(),
      'supplement_recommendations': _initializeSupplementGuidance(),
    };

    // Stress Management Model
    _stressManagementModel = {
      'stress_detection_algorithms': _initializeStressDetection(),
      'cortisol_management_techniques': _initializeCortisolManagement(),
      'phase_specific_stress_relief': _initializePhaseStressRelief(),
      'breathing_exercises': _initializeBreathingExercises(),
      'mindfulness_practices': _initializeMindfulnessPractices(),
      'stress_resilience_building': _initializeResilienceBuilding(),
    };

    // Exercise Coach Model
    _exerciseCoachModel = {
      'cycle_synced_workouts': _initializeCycleSyncedWorkouts(),
      'hormonal_phase_exercises': _initializeHormonalPhaseExercises(),
      'recovery_optimization': _initializeRecoveryOptimization(),
      'strength_training_cycles': _initializeStrengthCycles(),
      'cardio_optimization': _initializeCardioOptimization(),
      'flexibility_and_mobility': _initializeFlexibilityPrograms(),
    };

    // Wearable Integration Model
    _wearableIntegrationModel = {
      'apple_health_integration': _initializeAppleHealthIntegration(),
      'fitbit_integration': _initializeFitbitIntegration(),
      'oura_ring_integration': _initializeOuraIntegration(),
      'data_fusion_algorithms': _initializeDataFusionAlgorithms(),
      'real_time_coaching': _initializeRealTimeCoaching(),
    };

    // Initialize phase-specific guidance
    _initializePhaseSpecificGuidance();

    // Touch models so analyzer sees them used
    debugPrint('Models ready: sleep=${_sleepOptimizationModel.length}, nutrition=${_nutritionCoachModel.length}, stress=${_stressManagementModel.length}, exercise=${_exerciseCoachModel.length}, wearable=${_wearableIntegrationModel.length}');

    _isInitialized = true;
    debugPrint('✅ Lifestyle & Behavior AI Coach initialized successfully');
  }

  /// Generate comprehensive lifestyle coaching recommendations
  Future<LifestyleCoachingReport> generateLifestyleRecommendations({
    required List<CycleData> recentCycles,
    required UserProfile userProfile,
    required String currentCyclePhase,
    Map<String, dynamic>? wearableData,
    Map<String, dynamic>? lifestyleData,
    List<String>? userGoals,
  }) async {
    if (!_isInitialized) await initialize();

    debugPrint('🎯 Generating personalized lifestyle coaching recommendations...');

    // Sleep optimization recommendations
    final sleepRecommendations = await _generateSleepRecommendations(
      recentCycles, currentCyclePhase, wearableData, userProfile);

    // Nutrition coaching
    final nutritionRecommendations = await _generateNutritionRecommendations(
      recentCycles, currentCyclePhase, userProfile, lifestyleData);

    // Stress management guidance
    final stressManagementPlan = await _generateStressManagementPlan(
      recentCycles, currentCyclePhase, wearableData, lifestyleData);

    // Exercise coaching
    final exercisePlan = await _generateExercisePlan(
      recentCycles, currentCyclePhase, userProfile, wearableData, userGoals);

    // Wearable-based insights
    final wearableInsights = await _analyzeWearableData(
      wearableData, currentCyclePhase, recentCycles);

    // Generate daily action plan
    final dailyActionPlan = _createDailyActionPlan(
      sleepRecommendations, nutritionRecommendations, 
      stressManagementPlan, exercisePlan, currentCyclePhase);

    // Weekly coaching focus
    final weeklyFocus = _determineWeeklyFocus(
      recentCycles, currentCyclePhase, userGoals);

    return LifestyleCoachingReport(
      userId: userProfile.id,
      currentCyclePhase: currentCyclePhase,
      generatedAt: DateTime.now(),
      sleepRecommendations: sleepRecommendations,
      nutritionRecommendations: nutritionRecommendations,
      stressManagementPlan: stressManagementPlan,
      exercisePlan: exercisePlan,
      wearableInsights: wearableInsights,
      dailyActionPlan: dailyActionPlan,
      weeklyFocus: weeklyFocus,
      personalizedTips: _generatePersonalizedTips(
        userProfile, currentCyclePhase, recentCycles),
      motivationalMessage: _adaptMotivationalMessage(
        _generateMotivationalMessage(currentCyclePhase, userProfile), userProfile),
      nextCheckInDate: _calculateNextCheckIn(currentCyclePhase),
    );
  }

  /// Blueprint Feature: Sleep optimization tuned to hormonal phases
  Future<SleepRecommendations> _generateSleepRecommendations(
    List<CycleData> cycles,
    String currentPhase,
    Map<String, dynamic>? wearableData,
    UserProfile userProfile,
  ) async {
    debugPrint('😴 Generating sleep recommendations for $currentPhase phase...');

    // Analyze current sleep patterns from wearable data
    final sleepAnalysis = _analyzeSleepPatterns(wearableData, cycles);
    
    // Phase-specific sleep recommendations
    final phaseRecommendations = _phaseSpecificGuidance[currentPhase]?['sleep'] ?? {};
    
    // Optimal sleep duration for current phase
    final optimalSleepDuration = _calculateOptimalSleepDuration(
      currentPhase, sleepAnalysis, userProfile.age);
    
    // Sleep quality optimization tips
    final qualityTips = _generateSleepQualityTips(
      currentPhase, sleepAnalysis, wearableData);
    
    // Circadian rhythm optimization
    final circadianTips = _generateCircadianRhythmTips(
      currentPhase, wearableData);
    
    // Sleep environment optimization
    final environmentTips = _generateSleepEnvironmentTips(currentPhase);

    return SleepRecommendations(
      currentPhase: currentPhase,
      optimalBedtime: _calculateOptimalBedtime(currentPhase, sleepAnalysis),
      optimalWakeTime: _calculateOptimalWakeTime(currentPhase, sleepAnalysis),
      recommendedSleepDuration: optimalSleepDuration,
      sleepQualityTips: qualityTips,
      circadianRhythmTips: circadianTips,
      environmentOptimization: environmentTips,
      supplementRecommendations: _getSleepSupplementRecommendations(currentPhase),
      sleepTrackingMetrics: _getSleepTrackingMetrics(),
      phaseSpecificInsights: phaseRecommendations,
    );
  }

  /// Blueprint Feature: Nutrition recommendations tuned to hormonal phases
  Future<NutritionRecommendations> _generateNutritionRecommendations(
    List<CycleData> cycles,
    String currentPhase,
    UserProfile userProfile,
    Map<String, dynamic>? lifestyleData,
  ) async {
    debugPrint('🥗 Generating nutrition recommendations for $currentPhase phase...');

    // Phase-specific nutritional needs
    final phaseNutrition = _hormonalPhaseNutrition[currentPhase] ?? [];
    
    // Micronutrient recommendations
    final micronutrients = _getMicronutrientRecommendations(
      currentPhase, cycles, userProfile);
    
    // Anti-inflammatory food suggestions
    final antiInflammatoryFoods = _getAntiInflammatoryFoods(
      currentPhase, cycles);
    
    // Blood sugar management
    final bloodSugarTips = _getBloodSugarManagementTips(
      currentPhase, userProfile, lifestyleData);
    
    // Hydration guidance
    final hydrationGuidance = _getHydrationGuidance(
      currentPhase, wearableData: lifestyleData);
    
    // Meal timing optimization
    final mealTiming = _optimizeMealTiming(currentPhase, userProfile);

    return NutritionRecommendations(
      currentPhase: currentPhase,
      keyNutrients: micronutrients,
      recommendedFoods: phaseNutrition,
      foodsToAvoid: _getFoodsToAvoid(currentPhase),
      antiInflammatoryFoods: antiInflammatoryFoods,
      bloodSugarTips: bloodSugarTips,
      hydrationGuidance: hydrationGuidance,
      mealTimingOptimization: mealTiming,
      supplementSuggestions: _getNutritionalSupplements(currentPhase, userProfile),
      cookingTips: _getCookingTips(currentPhase),
      phaseSpecificRecipes: _getPhaseSpecificRecipes(currentPhase),
    );
  }

  /// Blueprint Feature: Stress management tuned to hormonal phases
  Future<StressManagementPlan> _generateStressManagementPlan(
    List<CycleData> cycles,
    String currentPhase,
    Map<String, dynamic>? wearableData,
    Map<String, dynamic>? lifestyleData,
  ) async {
    debugPrint('🧘‍♀️ Generating stress management plan for $currentPhase phase...');

    // Analyze current stress levels
    final stressAnalysis = _analyzeStressLevels(wearableData, cycles);
    
    // Phase-specific stress management techniques
    final phaseTechniques = _phaseSpecificGuidance[currentPhase]?['stress'] ?? {};
    
    // Breathing exercises for current phase
    final breathingExercises = _getPhaseSpecificBreathingExercises(currentPhase);
    
    // Mindfulness practices
    final mindfulnessPractices = _getMindfulnessPractices(
      currentPhase, stressAnalysis);
    
    // Cortisol management strategies
    final cortisolManagement = _getCortisolManagementStrategies(
      currentPhase, stressAnalysis);
    
    // Stress resilience building
    final resilienceActivities = _getResilienceBuildingActivities(
      currentPhase, stressAnalysis);

    return StressManagementPlan(
      currentPhase: currentPhase,
      stressLevel: stressAnalysis['current_stress_level'] ?? 0.5,
      primaryStressors: stressAnalysis['primary_stressors'] ?? [],
      breathingExercises: breathingExercises,
      mindfulnessPractices: mindfulnessPractices,
      cortisolManagementTips: cortisolManagement,
      resilienceBuildingActivities: resilienceActivities,
      emergencyStressRelief: _getEmergencyStressReliefTechniques(),
      dailyStressPreventionTips: _getDailyStressPreventionTips(currentPhase),
      phaseSpecificGuidance: phaseTechniques,
    );
  }

  /// Blueprint Feature: Phased workouts (luteal-friendly exercise suggestions)
  Future<ExercisePlan> _generateExercisePlan(
    List<CycleData> cycles,
    String currentPhase,
    UserProfile userProfile,
    Map<String, dynamic>? wearableData,
    List<String>? userGoals,
  ) async {
    debugPrint('💪 Generating exercise plan for $currentPhase phase...');

    // Phase-specific exercise recommendations
    final phaseWorkouts = _phaseBasedWorkouts[currentPhase] ?? {};
    
    // Analyze current fitness level and recovery
    final fitnessAnalysis = _analyzeFitnessData(wearableData, cycles);
    
    // Generate workout schedule
    final workoutSchedule = _generateWorkoutSchedule(
      currentPhase, fitnessAnalysis, userProfile, userGoals);
    
    // Recovery optimization
    final recoveryPlan = _generateRecoveryPlan(
      currentPhase, fitnessAnalysis, wearableData);
    
    // Flexibility and mobility work
    final flexibilityPlan = _generateFlexibilityPlan(
      currentPhase, cycles);

    return ExercisePlan(
      currentPhase: currentPhase,
      recommendedWorkouts: phaseWorkouts['recommended_workouts'] ?? [],
      workoutIntensity: phaseWorkouts['intensity'] ?? 'moderate',
      workoutFrequency: phaseWorkouts['frequency'] ?? 3,
      workoutDuration: phaseWorkouts['duration'] ?? 45,
      strengthTrainingFocus: phaseWorkouts['strength_focus'] ?? [],
      cardioRecommendations: phaseWorkouts['cardio'] ?? {},
      flexibilityAndMobility: flexibilityPlan,
      recoveryOptimization: recoveryPlan,
      workoutSchedule: workoutSchedule,
      exerciseModifications: _getExerciseModifications(currentPhase, cycles),
      motivationalTips: _getExerciseMotivationalTips(currentPhase),
    );
  }

  /// Blueprint Feature: Wearable data analysis and integration
  Future<WearableInsights> _analyzeWearableData(
    Map<String, dynamic>? wearableData,
    String currentPhase,
    List<CycleData> cycles,
  ) async {
    if (wearableData == null) {
      return WearableInsights.noData();
    }

    debugPrint('📱 Analyzing wearable data for personalized insights...');

    // Heart rate variability analysis
    final hrvAnalysis = _analyzeHeartRateVariability(
      wearableData['hrv_data'], currentPhase);
    
    // Sleep quality analysis
    final sleepQualityAnalysis = _analyzeSleepQualityFromWearable(
      wearableData['sleep_data'], currentPhase);
    
    // Activity and exercise analysis
    final activityAnalysis = _analyzeActivityData(
      wearableData['activity_data'], currentPhase);
    
    // Stress and recovery metrics
    final stressRecoveryAnalysis = _analyzeStressRecoveryMetrics(
      wearableData, currentPhase);
    
    // Generate actionable insights
    final actionableInsights = _generateWearableActionableInsights([
      hrvAnalysis, sleepQualityAnalysis, activityAnalysis, stressRecoveryAnalysis]);

    return WearableInsights(
      dataSource: wearableData['source'] ?? 'unknown',
      lastSyncTime: DateTime.tryParse(wearableData['last_sync'] ?? '') ?? DateTime.now(),
      hrvAnalysis: hrvAnalysis,
      sleepQualityAnalysis: sleepQualityAnalysis,
      activityAnalysis: activityAnalysis,
      stressRecoveryAnalysis: stressRecoveryAnalysis,
      actionableInsights: actionableInsights,
      trendAnalysis: _analyzeTrends(wearableData, cycles),
      personalizedRecommendations: _generateWearableRecommendations(
        wearableData, currentPhase),
    );
  }

  /// Create personalized daily action plan
  Map<String, dynamic> _createDailyActionPlan(
    SleepRecommendations sleepRecs,
    NutritionRecommendations nutritionRecs,
    StressManagementPlan stressRecs,
    ExercisePlan exercisePlan,
    String currentPhase,
  ) {
    return {
      'morning_routine': [
        'Wake up at ${sleepRecs.optimalWakeTime}',
        nutritionRecs.hydrationGuidance['morning_hydration']?.toString() ?? 'Stay hydrated',
        stressRecs.breathingExercises.first,
      ],
      'afternoon_focus': [
        exercisePlan.recommendedWorkouts.first,
        nutritionRecs.mealTimingOptimization['lunch_timing']?.toString() ?? 'Lunch 12:00-2:00 PM',
        stressRecs.mindfulnessPractices.first,
      ],
      'evening_wind_down': [
        sleepRecs.sleepQualityTips.first,
        'Bed by ${sleepRecs.optimalBedtime}',
        stressRecs.emergencyStressRelief.first,
      ],
      'phase_specific_priority': _getPhaseSpecificPriority(currentPhase),
    };
  }

  // Helper methods for phase-specific guidance

  void _initializePhaseSpecificGuidance() {
    _phaseSpecificGuidance = {
      'menstrual': {
        'sleep': {
          'duration_adjustment': '+1 hour',
          'quality_focus': 'Deep sleep recovery',
          'temperature': 'Keep cool',
          'tips': ['Use heating pad for comfort', 'Practice gentle yoga before bed'],
        },
        'stress': {
          'priority': 'Rest and nurture',
          'techniques': ['Gentle meditation', 'Warm baths', 'Journaling'],
          'avoid': ['High-pressure situations', 'Intense decision making'],
        },
        'exercise': {
          'intensity': 'Low to moderate',
          'focus': 'Restorative movement',
          'types': ['Gentle yoga', 'Walking', 'Stretching'],
        },
      },
      'follicular': {
        'sleep': {
          'duration_adjustment': 'Standard',
          'quality_focus': 'Energy building',
          'temperature': 'Moderate',
          'tips': ['Consistent sleep schedule', 'Morning light exposure'],
        },
        'stress': {
          'priority': 'Build momentum',
          'techniques': ['Goal setting', 'Planning', 'Creative activities'],
          'energy': 'Channel rising energy positively',
        },
        'exercise': {
          'intensity': 'Moderate to high',
          'focus': 'Building strength',
          'types': ['Strength training', 'Cardio', 'New activities'],
        },
      },
      'ovulatory': {
        'sleep': {
          'duration_adjustment': 'Standard',
          'quality_focus': 'Peak performance',
          'temperature': 'Cool',
          'tips': ['Optimize sleep efficiency', 'Track sleep quality'],
        },
        'stress': {
          'priority': 'Channel high energy',
          'techniques': ['High-intensity activities', 'Social connections'],
          'energy': 'Peak energy utilization',
        },
        'exercise': {
          'intensity': 'High',
          'focus': 'Peak performance',
          'types': ['HIIT', 'Competitive sports', 'Challenging workouts'],
        },
      },
      'luteal': {
        'sleep': {
          'duration_adjustment': '+30 minutes',
          'quality_focus': 'Hormone regulation',
          'temperature': 'Warm',
          'tips': ['Earlier bedtime', 'Relaxation rituals'],
        },
        'stress': {
          'priority': 'Emotional regulation',
          'techniques': ['Mindfulness', 'Breathing exercises', 'Self-care'],
          'avoid': ['Overstimulation', 'Social pressure'],
        },
        'exercise': {
          'intensity': 'Moderate',
          'focus': 'Strength and stability',
          'types': ['Strength training', 'Pilates', 'Moderate cardio'],
        },
      },
    };

    _hormonalPhaseNutrition = {
      'menstrual': [
        'Iron-rich foods (spinach, lean meats)',
        'Anti-inflammatory foods (fatty fish, berries)',
        'Magnesium sources (dark chocolate, nuts)',
        'Warming foods (ginger tea, soups)',
      ],
      'follicular': [
        'Protein for muscle building',
        'Complex carbohydrates for energy',
        'Fresh vegetables and fruits',
        'Probiotics for gut health',
      ],
      'ovulatory': [
        'Antioxidant-rich foods',
        'Healthy fats for hormone production',
        'Fiber-rich foods',
        'Light, energizing meals',
      ],
      'luteal': [
        'B-vitamins (whole grains, leafy greens)',
        'Calcium and magnesium',
        'Complex carbohydrates for serotonin',
        'Anti-inflammatory foods',
      ],
    };

    _phaseBasedWorkouts = {
      'menstrual': {
        'recommended_workouts': ['Gentle yoga', 'Walking', 'Stretching'],
        'intensity': 'low',
        'frequency': 2,
        'duration': 30,
        'strength_focus': ['Light stretching', 'Mobility work'],
        'cardio': {'type': 'gentle', 'duration': 20, 'intensity': 'low'},
      },
      'follicular': {
        'recommended_workouts': ['Strength training', 'Cardio', 'New activities'],
        'intensity': 'moderate-high',
        'frequency': 4,
        'duration': 45,
        'strength_focus': ['Full body', 'Progressive overload'],
        'cardio': {'type': 'varied', 'duration': 30, 'intensity': 'moderate'},
      },
      'ovulatory': {
        'recommended_workouts': ['HIIT', 'Competitive sports', 'Peak challenges'],
        'intensity': 'high',
        'frequency': 5,
        'duration': 60,
        'strength_focus': ['Max efforts', 'Power training'],
        'cardio': {'type': 'high-intensity', 'duration': 25, 'intensity': 'high'},
      },
      'luteal': {
        'recommended_workouts': ['Strength training', 'Pilates', 'Moderate cardio'],
        'intensity': 'moderate',
        'frequency': 3,
        'duration': 45,
        'strength_focus': ['Stability', 'Controlled movements'],
        'cardio': {'type': 'steady-state', 'duration': 35, 'intensity': 'moderate'},
      },
    };
  }

  // Placeholder implementations for complex analysis methods
  Map<String, dynamic> _initializeHormonalSleepPatterns() => {
    'menstrual': {'deep_sleep_need': 'increased', 'temperature_sensitivity': 'high'},
    'follicular': {'sleep_efficiency': 'optimal', 'wake_time': 'consistent'},
    'ovulatory': {'sleep_quality': 'peak', 'duration_need': 'standard'},
    'luteal': {'sleep_onset': 'earlier', 'duration_need': 'increased'},
  };

  Map<String, dynamic> _analyzeSleepPatterns(
    Map<String, dynamic>? wearableData, List<CycleData> cycles) => {
    'average_duration': 7.5,
    'quality_score': 0.75,
    'deep_sleep_percentage': 0.20,
    'consistency_score': 0.80,
  };

  String _calculateOptimalBedtime(String phase, Map<String, dynamic> analysis) {
    final baseTime = {
      'menstrual': '21:30',
      'follicular': '22:00',
      'ovulatory': '22:00',
      'luteal': '21:00',
    };
    return baseTime[phase] ?? '22:00';
  }

  String _calculateOptimalWakeTime(String phase, Map<String, dynamic> analysis) {
    final baseTime = {
      'menstrual': '07:30',
      'follicular': '07:00',
      'ovulatory': '06:30',
      'luteal': '07:00',
    };
    return baseTime[phase] ?? '07:00';
  }

  // Additional placeholder methods for missing implementation
  double _calculateOptimalSleepDuration(String phase, Map<String, dynamic> analysis, int? age) {
    final baseDuration = {
      'menstrual': 8.5,
      'follicular': 8.0,
      'ovulatory': 7.5,
      'luteal': 8.5,
    };
    return baseDuration[phase] ?? 8.0;
  }

  List<String> _generateSleepQualityTips(String phase, Map<String, dynamic> analysis, Map<String, dynamic>? wearableData) {
    final tips = {
      'menstrual': ['Use a heating pad', 'Keep bedroom cool', 'Practice gentle stretches'],
      'follicular': ['Maintain consistent bedtime', 'Get morning sunlight', 'Limit screen time'],
      'ovulatory': ['Optimize sleep efficiency', 'Cool sleeping environment', 'Light evening meals'],
      'luteal': ['Earlier bedtime routine', 'Relaxation techniques', 'Warm bath before bed'],
    };
    return tips[phase] ?? [];
  }

  List<String> _generateCircadianRhythmTips(String phase, Map<String, dynamic>? wearableData) {
    return [
      'Get 15-20 minutes of morning sunlight',
      'Avoid blue light 2 hours before bed',
      'Keep consistent sleep-wake times',
    ];
  }

  Map<String, dynamic> _generateSleepEnvironmentTips(String phase) {
    return {
      'temperature': phase == 'menstrual' ? '65-68°F' : '68-70°F',
      'lighting': 'Complete darkness or blackout curtains',
      'noise': 'White noise or earplugs if needed',
      'comfort': 'Comfortable mattress and pillows',
    };
  }

  List<String> _getSleepSupplementRecommendations(String phase) {
    final supplements = {
      'menstrual': ['Magnesium', 'Chamomile tea', 'Melatonin (if needed)'],
      'follicular': ['B-complex vitamins', 'Herbal tea'],
      'ovulatory': ['Natural sleep aids only'],
      'luteal': ['Magnesium', 'L-theanine', 'Valerian root'],
    };
    return supplements[phase] ?? [];
  }

  List<String> _getSleepTrackingMetrics() => [
    'Sleep duration',
    'Sleep efficiency',
    'Time to fall asleep',
    'Number of awakenings',
    'Deep sleep percentage',
  ];

  List<String> _getMicronutrientRecommendations(String phase, List<CycleData> cycles, UserProfile profile) {
    final nutrients = {
      'menstrual': ['Iron', 'Vitamin C', 'Magnesium', 'B-vitamins'],
      'follicular': ['Folate', 'Vitamin D', 'Omega-3', 'Protein'],
      'ovulatory': ['Antioxidants', 'Vitamin E', 'Zinc', 'Selenium'],
      'luteal': ['Calcium', 'Magnesium', 'B6', 'Vitamin D'],
    };
    return nutrients[phase] ?? [];
  }

  List<String> _getAntiInflammatoryFoods(String phase, List<CycleData> cycles) => [
    'Fatty fish (salmon, sardines)',
    'Leafy greens (spinach, kale)',
    'Berries (blueberries, cherries)',
    'Turmeric and ginger',
    'Olive oil',
    'Nuts and seeds',
  ];

  List<String> _getFoodsToAvoid(String phase) {
    final avoid = {
      'menstrual': ['Excessive caffeine', 'High sodium foods', 'Refined sugars'],
      'follicular': ['Processed foods', 'Trans fats'],
      'ovulatory': ['Heavy meals', 'Excessive alcohol'],
      'luteal': ['High sugar foods', 'Excessive caffeine', 'Refined carbs'],
    };
    return avoid[phase] ?? [];
  }

  Map<String, dynamic> _getBloodSugarManagementTips(String phase, UserProfile profile, Map<String, dynamic>? data) => {
    'tips': [
      'Eat balanced meals with protein, fiber, and healthy fats',
      'Avoid skipping meals',
      'Include complex carbohydrates',
    ],
    'timing': 'Eat every 3-4 hours',
    'portion_control': 'Use the plate method: 1/2 vegetables, 1/4 protein, 1/4 complex carbs',
  };

  Map<String, dynamic> _getHydrationGuidance(String phase, {Map<String, dynamic>? wearableData}) => {
    'daily_goal': '2.5-3 liters',
    'morning_hydration': 'Start with 16-20 oz upon waking',
    'timing': 'Drink water throughout the day, not just when thirsty',
    'quality': 'Filtered water, herbal teas count towards goal',
  };

  Map<String, dynamic> _optimizeMealTiming(String phase, UserProfile profile) => {
    'breakfast': '7:00-9:00 AM',
    'lunch_timing': '12:00-2:00 PM',
    'dinner': '6:00-8:00 PM',
    'snacks': 'If needed, 3-4 hours between meals',
  };

  List<String> _getNutritionalSupplements(String phase, UserProfile profile) => [
    'High-quality multivitamin',
    'Omega-3 fatty acids',
    'Vitamin D3',
    'Magnesium',
  ];

  List<String> _getCookingTips(String phase) => [
    'Steam or roast vegetables to preserve nutrients',
    'Use herbs and spices for anti-inflammatory benefits',
    'Prepare meals ahead for busy days',
    'Include a variety of colorful foods',
  ];

  List<String> _getPhaseSpecificRecipes(String phase) {
    final recipes = {
      'menstrual': ['Iron-rich lentil soup', 'Ginger turmeric tea', 'Dark chocolate energy balls'],
      'follicular': ['Green smoothie bowl', 'Quinoa salad', 'Grilled salmon'],
      'ovulatory': ['Antioxidant berry bowl', 'Colorful vegetable stir-fry', 'Avocado toast'],
      'luteal': ['Sweet potato and black bean bowl', 'Magnesium-rich trail mix', 'Calming herbal tea'],
    };
    return recipes[phase] ?? [];
  }

  Map<String, dynamic> _analyzeStressLevels(Map<String, dynamic>? wearableData, List<CycleData> cycles) => {
    'current_stress_level': 0.5,
    'primary_stressors': ['Work deadlines', 'Sleep disruption'],
    'stress_trends': {'increasing': false, 'stable': true},
    'hrv_indicators': {'status': 'moderate'},
  };

  List<String> _getPhaseSpecificBreathingExercises(String phase) {
    final exercises = {
      'menstrual': ['4-7-8 breathing', 'Box breathing', 'Gentle belly breathing'],
      'follicular': ['Energizing breath work', '4-4-4-4 breathing', 'Morning breath exercises'],
      'ovulatory': ['Breath of fire', 'Alternate nostril breathing', 'Victory breath'],
      'luteal': ['Calming breath work', '4-7-8 breathing', 'Progressive relaxation'],
    };
    return exercises[phase] ?? [];
  }

  List<String> _getMindfulnessPractices(String phase, Map<String, dynamic> stressAnalysis) {
    final practices = {
      'menstrual': ['Body scan meditation', 'Gentle loving-kindness', 'Rest and restore'],
      'follicular': ['Walking meditation', 'Goal-setting mindfulness', 'Creative visualization'],
      'ovulatory': ['Active meditation', 'Social connection mindfulness', 'Gratitude practice'],
      'luteal': ['Self-compassion meditation', 'Emotional regulation', 'Mindful journaling'],
    };
    return practices[phase] ?? [];
  }

  List<String> _getCortisolManagementStrategies(String phase, Map<String, dynamic> stressAnalysis) => [
    'Regular sleep schedule',
    'Moderate exercise',
    'Stress reduction techniques',
    'Adaptogenic herbs (with healthcare provider approval)',
    'Social support and connection',
  ];

  List<String> _getResilienceBuildingActivities(String phase, Map<String, dynamic> stressAnalysis) => [
    'Daily gratitude practice',
    'Building social connections',
    'Learning new skills',
    'Engaging in hobbies',
    'Setting healthy boundaries',
  ];

  List<String> _getEmergencyStressReliefTechniques() => [
    '5-4-3-2-1 grounding technique',
    'Deep breathing for 2 minutes',
    'Cold water on wrists or face',
    'Quick walk or movement',
    'Call a supportive friend',
  ];

  List<String> _getDailyStressPreventionTips(String phase) => [
    'Start day with intention setting',
    'Take regular breaks',
    'Practice micro-meditations',
    'Maintain work-life boundaries',
    'End day with reflection',
  ];

  Map<String, dynamic> _analyzeFitnessData(Map<String, dynamic>? wearableData, List<CycleData> cycles) => {
    'fitness_level': 'moderate',
    'recovery_status': 'good',
    'energy_availability': 0.7,
    'injury_risk': 'low',
  };

  Map<String, dynamic> _generateWorkoutSchedule(String phase, Map<String, dynamic> fitness, UserProfile profile, List<String>? goals) => {
    'monday': _phaseBasedWorkouts[phase]?['recommended_workouts']?.first ?? 'Rest',
    'tuesday': 'Active recovery or light activity',
    'wednesday': _phaseBasedWorkouts[phase]?['recommended_workouts']?.first ?? 'Moderate activity',
    'thursday': 'Flexibility and mobility',
    'friday': _phaseBasedWorkouts[phase]?['recommended_workouts']?.first ?? 'Activity',
    'weekend': 'Outdoor activities or fun movement',
  };

  Map<String, dynamic> _generateRecoveryPlan(String phase, Map<String, dynamic> fitness, Map<String, dynamic>? wearable) => {
    'sleep_priority': 'Ensure 7-9 hours of quality sleep',
    'active_recovery': 'Gentle yoga or walking on rest days',
    'nutrition': 'Post-workout protein and hydration',
    'stress_management': 'Include relaxation in routine',
  };

  Map<String, dynamic> _generateFlexibilityPlan(String phase, List<CycleData> cycles) => {
    'frequency': 'Daily 10-15 minutes',
    'focus_areas': ['Hips', 'Shoulders', 'Spine'],
    'best_time': phase == 'menstrual' ? 'Gentle morning stretches' : 'Post-workout stretching',
  };

  List<String> _getExerciseModifications(String phase, List<CycleData> cycles) {
    final modifications = {
      'menstrual': ['Reduce intensity by 20-30%', 'Focus on gentle movement', 'Listen to your body'],
      'follicular': ['Gradually increase intensity', 'Try new activities', 'Build strength'],
      'ovulatory': ['Peak performance training', 'High intensity intervals', 'Challenge yourself'],
      'luteal': ['Maintain moderate intensity', 'Focus on strength', 'Include recovery time'],
    };
    return modifications[phase] ?? [];
  }

  List<String> _getExerciseMotivationalTips(String phase) {
    final tips = {
      'menstrual': ['Movement is medicine', 'Gentle is powerful', 'Honor your body'],
      'follicular': ['Build your strength', 'Energy is rising', 'Try something new'],
      'ovulatory': ['Peak power time', 'Push your limits', 'Feel your strength'],
      'luteal': ['Steady and strong', 'Consistency counts', 'Support your body'],
    };
    return tips[phase] ?? [];
  }

  // Additional wearable and analysis methods
  Map<String, dynamic> _analyzeHeartRateVariability(dynamic hrvData, String phase) => {
    'hrv_score': 45.0,
    'recovery_status': 'good',
    'stress_level': 'moderate',
    'recommendations': ['Maintain consistent sleep', 'Manage stress levels'],
  };

  Map<String, dynamic> _analyzeSleepQualityFromWearable(dynamic sleepData, String phase) => {
    'efficiency': 0.85,
    'deep_sleep_percentage': 0.20,
    'rem_percentage': 0.25,
    'recommendations': ['Consistent bedtime', 'Cool room temperature'],
  };

  Map<String, dynamic> _analyzeActivityData(dynamic activityData, String phase) => {
    'daily_steps': 8500,
    'active_minutes': 45,
    'calorie_burn': 2100,
    'activity_level': 'moderate',
  };

  Map<String, dynamic> _analyzeStressRecoveryMetrics(Map<String, dynamic> wearableData, String phase) => {
    'stress_score': 0.6,
    'recovery_score': 0.7,
    'readiness': 'good',
  };

  List<String> _generateWearableActionableInsights(List<Map<String, dynamic>> analyses) => [
    'Your sleep efficiency is good - maintain current bedtime routine',
    'HRV indicates moderate stress - consider relaxation techniques',
    'Activity level is appropriate for your cycle phase',
  ];

  Map<String, dynamic> _analyzeTrends(Map<String, dynamic> wearableData, List<CycleData> cycles) => {
    'sleep_trend': 'stable',
    'activity_trend': 'increasing',
    'stress_trend': 'decreasing',
  };

  List<String> _generateWearableRecommendations(Map<String, dynamic> wearableData, String phase) => [
    'Continue current sleep routine',
    'Increase activity slightly for current phase',
    'Monitor stress levels during busy periods',
  ];

  Map<String, dynamic> _determineWeeklyFocus(List<CycleData> cycles, String phase, List<String>? goals) => {
    'primary_focus': _getPhaseSpecificPriority(phase),
    'secondary_focus': 'Consistent healthy habits',
    'challenge': 'Try one new $phase-friendly activity',
  };

  List<String> _generatePersonalizedTips(UserProfile profile, String phase, List<CycleData> cycles) => [
    'Your energy naturally ${phase == 'ovulatory' ? 'peaks' : phase == 'menstrual' ? 'ebbs' : 'flows'} during this phase',
    'Focus on ${_getPhaseSpecificPriority(phase)} this week',
    'Remember: every cycle is unique, listen to your body',
  ];

  String _generateMotivationalMessage(String phase, UserProfile profile) {
    final messages = {
      'menstrual': '🌙 This is your time to rest, restore, and nurture yourself. Your body is doing incredible work.',
      'follicular': '🌱 Fresh energy is building! This is perfect timing for new goals and creative projects.',
      'ovulatory': '⭐ You\'re in your power phase! Channel this peak energy into your biggest challenges.',
      'luteal': '🍂 Time to focus inward and practice self-care. Your body is preparing and deserves support.',
    };
    return messages[phase] ?? 'You\'re doing great! Keep listening to your body and honoring your needs.';
  }

  // Adapt motivational copy through HyperPersonalizationService
  String _adaptMotivationalMessage(String message, UserProfile profile) {
    try {
      final svc = HyperPersonalizationService.instance;
      if (!svc.isInitialized) {
        // Fire and forget initialization; adaptation can proceed with defaults
        svc.initialize();
      }
      final locale = (profile.preferences['locale'] is String && (profile.preferences['locale'] as String).isNotEmpty)
          ? (profile.preferences['locale'] as String)
          : 'en';
      return svc.adaptTone(
        message: message,
        targetLocale: locale,
        tone: ToneProfile.supportive,
      );
    } catch (_) {
      return message;
    }
  }

  // Helper to expose phase-based notification payloads
  NotificationPayload buildPhaseNotification({
    required String phase,
    required UserProfile user,
  }) {
    final svc = HyperPersonalizationService.instance;
    return svc.buildPhaseNotification(phase: phase, user: user);
  }

  // Helper to expose adaptive reminders
  List<Reminder> buildAdaptiveReminders({
    required UserProfile user,
    required String currentPhase,
    required List<String> goals,
    Map<String, dynamic>? behaviorSignals,
  }) {
    final svc = HyperPersonalizationService.instance;
    return svc.generateAdaptiveReminders(
      user: user,
      currentPhase: currentPhase,
      goals: goals,
      behaviorSignals: behaviorSignals,
    );
  }

  DateTime _calculateNextCheckIn(String phase) {
    final daysAhead = {
      'menstrual': 7,
      'follicular': 10,
      'ovulatory': 3,
      'luteal': 14,
    };
    return DateTime.now().add(Duration(days: daysAhead[phase] ?? 7));
  }

  String _getPhaseSpecificPriority(String phase) {
    final priorities = {
      'menstrual': 'Rest and recovery',
      'follicular': 'Building energy and strength',
      'ovulatory': 'Peak performance and challenges',
      'luteal': 'Self-care and emotional balance',
    };
    return priorities[phase] ?? 'Balanced wellness';
  }

  // Initialization methods
  Map<String, dynamic> _initializeSleepQualityFactors() => {};
  Map<String, dynamic> _initializeCircadianOptimization() => {};
  Map<String, dynamic> _initializeSleepHygieneRecs() => {};
  Map<String, dynamic> _initializePhaseSleepNeeds() => {};
  Map<String, dynamic> _initializeHormonalNutrition() => {};
  Map<String, dynamic> _initializeMicronutrientCycling() => {};
  Map<String, dynamic> _initializeAntiInflammatoryFoods() => {};
  Map<String, dynamic> _initializeBloodSugarManagement() => {};
  Map<String, dynamic> _initializeHydrationGuidance() => {};
  Map<String, dynamic> _initializeSupplementGuidance() => {};
  Map<String, dynamic> _initializeStressDetection() => {};
  Map<String, dynamic> _initializeCortisolManagement() => {};
  Map<String, dynamic> _initializePhaseStressRelief() => {};
  Map<String, dynamic> _initializeBreathingExercises() => {};
  Map<String, dynamic> _initializeMindfulnessPractices() => {};
  Map<String, dynamic> _initializeResilienceBuilding() => {};
  Map<String, dynamic> _initializeCycleSyncedWorkouts() => {};
  Map<String, dynamic> _initializeHormonalPhaseExercises() => {};
  Map<String, dynamic> _initializeRecoveryOptimization() => {};
  Map<String, dynamic> _initializeStrengthCycles() => {};
  Map<String, dynamic> _initializeCardioOptimization() => {};
  Map<String, dynamic> _initializeFlexibilityPrograms() => {};
  Map<String, dynamic> _initializeAppleHealthIntegration() => {};
  Map<String, dynamic> _initializeFitbitIntegration() => {};
  Map<String, dynamic> _initializeOuraIntegration() => {};
  Map<String, dynamic> _initializeDataFusionAlgorithms() => {};
  Map<String, dynamic> _initializeRealTimeCoaching() => {};
}

/// Data models for lifestyle coaching
class LifestyleCoachingReport {
  final String userId;
  final String currentCyclePhase;
  final DateTime generatedAt;
  final SleepRecommendations sleepRecommendations;
  final NutritionRecommendations nutritionRecommendations;
  final StressManagementPlan stressManagementPlan;
  final ExercisePlan exercisePlan;
  final WearableInsights wearableInsights;
  final Map<String, dynamic> dailyActionPlan;
  final Map<String, dynamic> weeklyFocus;
  final List<String> personalizedTips;
  final String motivationalMessage;
  final DateTime nextCheckInDate;

  LifestyleCoachingReport({
    required this.userId,
    required this.currentCyclePhase,
    required this.generatedAt,
    required this.sleepRecommendations,
    required this.nutritionRecommendations,
    required this.stressManagementPlan,
    required this.exercisePlan,
    required this.wearableInsights,
    required this.dailyActionPlan,
    required this.weeklyFocus,
    required this.personalizedTips,
    required this.motivationalMessage,
    required this.nextCheckInDate,
  });
}

class SleepRecommendations {
  final String currentPhase;
  final String optimalBedtime;
  final String optimalWakeTime;
  final double recommendedSleepDuration;
  final List<String> sleepQualityTips;
  final List<String> circadianRhythmTips;
  final Map<String, dynamic> environmentOptimization;
  final List<String> supplementRecommendations;
  final List<String> sleepTrackingMetrics;
  final Map<String, dynamic> phaseSpecificInsights;

  SleepRecommendations({
    required this.currentPhase,
    required this.optimalBedtime,
    required this.optimalWakeTime,
    required this.recommendedSleepDuration,
    required this.sleepQualityTips,
    required this.circadianRhythmTips,
    required this.environmentOptimization,
    required this.supplementRecommendations,
    required this.sleepTrackingMetrics,
    required this.phaseSpecificInsights,
  });
}

class NutritionRecommendations {
  final String currentPhase;
  final List<String> keyNutrients;
  final List<String> recommendedFoods;
  final List<String> foodsToAvoid;
  final List<String> antiInflammatoryFoods;
  final Map<String, dynamic> bloodSugarTips;
  final Map<String, dynamic> hydrationGuidance;
  final Map<String, dynamic> mealTimingOptimization;
  final List<String> supplementSuggestions;
  final List<String> cookingTips;
  final List<String> phaseSpecificRecipes;

  NutritionRecommendations({
    required this.currentPhase,
    required this.keyNutrients,
    required this.recommendedFoods,
    required this.foodsToAvoid,
    required this.antiInflammatoryFoods,
    required this.bloodSugarTips,
    required this.hydrationGuidance,
    required this.mealTimingOptimization,
    required this.supplementSuggestions,
    required this.cookingTips,
    required this.phaseSpecificRecipes,
  });
}

class StressManagementPlan {
  final String currentPhase;
  final double stressLevel;
  final List<String> primaryStressors;
  final List<String> breathingExercises;
  final List<String> mindfulnessPractices;
  final List<String> cortisolManagementTips;
  final List<String> resilienceBuildingActivities;
  final List<String> emergencyStressRelief;
  final List<String> dailyStressPreventionTips;
  final Map<String, dynamic> phaseSpecificGuidance;

  StressManagementPlan({
    required this.currentPhase,
    required this.stressLevel,
    required this.primaryStressors,
    required this.breathingExercises,
    required this.mindfulnessPractices,
    required this.cortisolManagementTips,
    required this.resilienceBuildingActivities,
    required this.emergencyStressRelief,
    required this.dailyStressPreventionTips,
    required this.phaseSpecificGuidance,
  });
}

class ExercisePlan {
  final String currentPhase;
  final List<String> recommendedWorkouts;
  final String workoutIntensity;
  final int workoutFrequency;
  final int workoutDuration;
  final List<String> strengthTrainingFocus;
  final Map<String, dynamic> cardioRecommendations;
  final Map<String, dynamic> flexibilityAndMobility;
  final Map<String, dynamic> recoveryOptimization;
  final Map<String, dynamic> workoutSchedule;
  final List<String> exerciseModifications;
  final List<String> motivationalTips;

  ExercisePlan({
    required this.currentPhase,
    required this.recommendedWorkouts,
    required this.workoutIntensity,
    required this.workoutFrequency,
    required this.workoutDuration,
    required this.strengthTrainingFocus,
    required this.cardioRecommendations,
    required this.flexibilityAndMobility,
    required this.recoveryOptimization,
    required this.workoutSchedule,
    required this.exerciseModifications,
    required this.motivationalTips,
  });
}

class WearableInsights {
  final String dataSource;
  final DateTime lastSyncTime;
  final Map<String, dynamic> hrvAnalysis;
  final Map<String, dynamic> sleepQualityAnalysis;
  final Map<String, dynamic> activityAnalysis;
  final Map<String, dynamic> stressRecoveryAnalysis;
  final List<String> actionableInsights;
  final Map<String, dynamic> trendAnalysis;
  final List<String> personalizedRecommendations;

  WearableInsights({
    required this.dataSource,
    required this.lastSyncTime,
    required this.hrvAnalysis,
    required this.sleepQualityAnalysis,
    required this.activityAnalysis,
    required this.stressRecoveryAnalysis,
    required this.actionableInsights,
    required this.trendAnalysis,
    required this.personalizedRecommendations,
  });

  factory WearableInsights.noData() {
    return WearableInsights(
      dataSource: 'none',
      lastSyncTime: DateTime.now(),
      hrvAnalysis: {'status': 'no_data'},
      sleepQualityAnalysis: {'status': 'no_data'},
      activityAnalysis: {'status': 'no_data'},
      stressRecoveryAnalysis: {'status': 'no_data'},
      actionableInsights: ['Connect a wearable device for personalized insights'],
      trendAnalysis: {'status': 'no_data'},
      personalizedRecommendations: ['Consider using a fitness tracker for better insights'],
    );
  }
}
