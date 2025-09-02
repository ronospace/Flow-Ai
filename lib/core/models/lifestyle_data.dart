/// Lifestyle data models for the AI Coach system
class LifestyleData {
  final String userId;
  final DateTime recordDate;
  final SleepData? sleepData;
  final NutritionData? nutritionData;
  final ExerciseData? exerciseData;
  final StressData? stressData;
  final Map<String, dynamic>? wearableData;

  LifestyleData({
    required this.userId,
    required this.recordDate,
    this.sleepData,
    this.nutritionData,
    this.exerciseData,
    this.stressData,
    this.wearableData,
  });
}

class SleepData {
  final DateTime bedtime;
  final DateTime wakeTime;
  final double hoursSlept;
  final double sleepQuality; // 1-10 scale
  final Map<String, double>? sleepStages; // deep, light, REM percentages
  final List<String>? sleepDisruptions;

  SleepData({
    required this.bedtime,
    required this.wakeTime,
    required this.hoursSlept,
    required this.sleepQuality,
    this.sleepStages,
    this.sleepDisruptions,
  });
}

class NutritionData {
  final List<MealEntry> meals;
  final double waterIntake; // in liters
  final Map<String, double>? macronutrients; // carbs, protein, fat
  final Map<String, double>? micronutrients; // vitamins, minerals
  final List<String>? supplements;
  final double energyLevel; // 1-10 scale

  NutritionData({
    required this.meals,
    required this.waterIntake,
    this.macronutrients,
    this.micronutrients,
    this.supplements,
    required this.energyLevel,
  });
}

class MealEntry {
  final String mealType; // breakfast, lunch, dinner, snack
  final DateTime timestamp;
  final List<String> foods;
  final double portionSize;
  final Map<String, dynamic>? nutritionalInfo;

  MealEntry({
    required this.mealType,
    required this.timestamp,
    required this.foods,
    required this.portionSize,
    this.nutritionalInfo,
  });
}

class ExerciseData {
  final List<WorkoutSession> workouts;
  final double dailySteps;
  final double activeMinutes;
  final double restingHeartRate;
  final Map<String, double>? heartRateZones;
  final double recoveryScore; // 1-10 scale

  ExerciseData({
    required this.workouts,
    required this.dailySteps,
    required this.activeMinutes,
    required this.restingHeartRate,
    this.heartRateZones,
    required this.recoveryScore,
  });
}

class WorkoutSession {
  final String workoutType;
  final DateTime startTime;
  final Duration duration;
  final String intensity; // low, moderate, high
  final double caloriesBurned;
  final Map<String, dynamic>? workoutDetails;

  WorkoutSession({
    required this.workoutType,
    required this.startTime,
    required this.duration,
    required this.intensity,
    required this.caloriesBurned,
    this.workoutDetails,
  });
}

class StressData {
  final double stressLevel; // 1-10 scale
  final List<String> stressors;
  final List<String> copingMethods;
  final double moodRating; // 1-10 scale
  final Map<String, double>? heartRateVariability;
  final List<String>? stressSymptoms;

  StressData({
    required this.stressLevel,
    required this.stressors,
    required this.copingMethods,
    required this.moodRating,
    this.heartRateVariability,
    this.stressSymptoms,
  });
}
