import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for progressive disclosure of app features
/// Gradually reveals features as users become more familiar with the app
class ProgressiveDisclosureService extends ChangeNotifier {
  static const String _featurePrefix = 'feature_unlocked_';
  static const String _actionCountPrefix = 'action_count_';
  
  // Feature IDs
  static const String featureBasicTracking = 'basic_tracking';
  static const String featureCycleCalendar = 'cycle_calendar';
  static const String featureSymptomTracking = 'symptom_tracking';
  static const String featureMoodTracking = 'mood_tracking';
  static const String featureAiInsights = 'ai_insights';
  static const String featureAdvancedAnalytics = 'advanced_analytics';
  static const String featureBiometricIntegration = 'biometric_integration';
  static const String featureHealthDashboard = 'health_dashboard';
  static const String featureAiCoach = 'ai_coach';
  static const String featureDataExport = 'data_export';
  static const String featurePredictiveInsights = 'predictive_insights';
  static const String featureMlPredictions = 'ml_predictions';
  
  // Action types for tracking user engagement
  static const String actionLogPeriod = 'log_period';
  static const String actionLogSymptom = 'log_symptom';
  static const String actionLogMood = 'log_mood';
  static const String actionViewCalendar = 'view_calendar';
  static const String actionViewInsights = 'view_insights';
  static const String actionUseApp = 'use_app';
  
  final Map<String, bool> _featureStates = {};
  final Map<String, int> _actionCounts = {};
  bool _isInitialized = false;

  /// Initialize the service and load feature states
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    
    // Load all feature states
    for (final feature in _allFeatures) {
      _featureStates[feature] = prefs.getBool('$_featurePrefix$feature') ?? _isFeatureUnlockedByDefault(feature);
    }
    
    // Load all action counts
    for (final action in _allActions) {
      _actionCounts[action] = prefs.getInt('$_actionCountPrefix$action') ?? 0;
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  /// Check if a feature is unlocked
  bool isFeatureUnlocked(String featureId) {
    return _featureStates[featureId] ?? false;
  }

  /// Manually unlock a feature
  Future<void> unlockFeature(String featureId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_featurePrefix$featureId', true);
    _featureStates[featureId] = true;
    notifyListeners();
  }

  /// Lock a feature (for testing)
  Future<void> lockFeature(String featureId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_featurePrefix$featureId', false);
    _featureStates[featureId] = false;
    notifyListeners();
  }

  /// Record a user action and check for feature unlocks
  Future<void> recordAction(String actionType) async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = _actionCounts[actionType] ?? 0;
    final newCount = currentCount + 1;
    
    await prefs.setInt('$_actionCountPrefix$actionType', newCount);
    _actionCounts[actionType] = newCount;
    
    // Check if any features should be unlocked based on this action
    await _checkAndUnlockFeatures();
  }

  /// Get action count for a specific action type
  int getActionCount(String actionType) {
    return _actionCounts[actionType] ?? 0;
  }

  /// Check and unlock features based on user progress
  Future<void> _checkAndUnlockFeatures() async {
    bool unlocked = false;
    
    // Unlock cycle calendar after first period log
    if (!isFeatureUnlocked(featureCycleCalendar) && getActionCount(actionLogPeriod) >= 1) {
      await unlockFeature(featureCycleCalendar);
      unlocked = true;
    }
    
    // Unlock symptom tracking after 2 app uses
    if (!isFeatureUnlocked(featureSymptomTracking) && getActionCount(actionUseApp) >= 2) {
      await unlockFeature(featureSymptomTracking);
      unlocked = true;
    }
    
    // Unlock mood tracking after 3 app uses
    if (!isFeatureUnlocked(featureMoodTracking) && getActionCount(actionUseApp) >= 3) {
      await unlockFeature(featureMoodTracking);
      unlocked = true;
    }
    
    // Unlock AI insights after 5 data entries
    final totalEntries = getActionCount(actionLogPeriod) + 
                         getActionCount(actionLogSymptom) + 
                         getActionCount(actionLogMood);
    if (!isFeatureUnlocked(featureAiInsights) && totalEntries >= 5) {
      await unlockFeature(featureAiInsights);
      unlocked = true;
    }
    
    // Unlock advanced analytics after viewing insights 3 times
    if (!isFeatureUnlocked(featureAdvancedAnalytics) && getActionCount(actionViewInsights) >= 3) {
      await unlockFeature(featureAdvancedAnalytics);
      unlocked = true;
    }
    
    // Unlock AI Coach after 10 total actions
    final totalActions = _actionCounts.values.fold(0, (sum, count) => sum + count);
    if (!isFeatureUnlocked(featureAiCoach) && totalActions >= 10) {
      await unlockFeature(featureAiCoach);
      unlocked = true;
    }
    
    // Unlock health dashboard after 2 weeks of use (14 app uses)
    if (!isFeatureUnlocked(featureHealthDashboard) && getActionCount(actionUseApp) >= 14) {
      await unlockFeature(featureHealthDashboard);
      unlocked = true;
    }
    
    // Unlock ML predictions after 3 complete cycles (90 days / 3 period logs)
    if (!isFeatureUnlocked(featureMlPredictions) && getActionCount(actionLogPeriod) >= 3) {
      await unlockFeature(featureMlPredictions);
      unlocked = true;
    }
    
    // Unlock biometric integration after health dashboard is unlocked
    if (!isFeatureUnlocked(featureBiometricIntegration) && isFeatureUnlocked(featureHealthDashboard)) {
      await unlockFeature(featureBiometricIntegration);
      unlocked = true;
    }
    
    // Unlock data export after 30 app uses
    if (!isFeatureUnlocked(featureDataExport) && getActionCount(actionUseApp) >= 30) {
      await unlockFeature(featureDataExport);
      unlocked = true;
    }
    
    if (unlocked) {
      notifyListeners();
    }
  }

  /// Get feature unlock requirements
  FeatureUnlockRequirement getUnlockRequirement(String featureId) {
    switch (featureId) {
      case featureBasicTracking:
        return FeatureUnlockRequirement(
          featureId: featureId,
          description: 'Available from the start',
          currentProgress: 1,
          requiredProgress: 1,
          isUnlocked: true,
        );
      
      case featureCycleCalendar:
        return FeatureUnlockRequirement(
          featureId: featureId,
          description: 'Log your first period',
          currentProgress: getActionCount(actionLogPeriod),
          requiredProgress: 1,
          isUnlocked: isFeatureUnlocked(featureId),
        );
      
      case featureSymptomTracking:
        return FeatureUnlockRequirement(
          featureId: featureId,
          description: 'Use the app 2 times',
          currentProgress: getActionCount(actionUseApp),
          requiredProgress: 2,
          isUnlocked: isFeatureUnlocked(featureId),
        );
      
      case featureMoodTracking:
        return FeatureUnlockRequirement(
          featureId: featureId,
          description: 'Use the app 3 times',
          currentProgress: getActionCount(actionUseApp),
          requiredProgress: 3,
          isUnlocked: isFeatureUnlocked(featureId),
        );
      
      case featureAiInsights:
        final totalEntries = getActionCount(actionLogPeriod) + 
                            getActionCount(actionLogSymptom) + 
                            getActionCount(actionLogMood);
        return FeatureUnlockRequirement(
          featureId: featureId,
          description: 'Log 5 data entries',
          currentProgress: totalEntries,
          requiredProgress: 5,
          isUnlocked: isFeatureUnlocked(featureId),
        );
      
      case featureAiCoach:
        final totalActions = _actionCounts.values.fold(0, (sum, count) => sum + count);
        return FeatureUnlockRequirement(
          featureId: featureId,
          description: 'Complete 10 actions',
          currentProgress: totalActions,
          requiredProgress: 10,
          isUnlocked: isFeatureUnlocked(featureId),
        );
      
      case featureHealthDashboard:
        return FeatureUnlockRequirement(
          featureId: featureId,
          description: 'Use the app for 2 weeks',
          currentProgress: getActionCount(actionUseApp),
          requiredProgress: 14,
          isUnlocked: isFeatureUnlocked(featureId),
        );
      
      case featureMlPredictions:
        return FeatureUnlockRequirement(
          featureId: featureId,
          description: 'Track 3 complete cycles',
          currentProgress: getActionCount(actionLogPeriod),
          requiredProgress: 3,
          isUnlocked: isFeatureUnlocked(featureId),
        );
      
      default:
        return FeatureUnlockRequirement(
          featureId: featureId,
          description: 'Unknown feature',
          currentProgress: 0,
          requiredProgress: 1,
          isUnlocked: false,
        );
    }
  }

  /// Get all features with their unlock status
  List<FeatureUnlockRequirement> getAllFeatureRequirements() {
    return _allFeatures.map((feature) => getUnlockRequirement(feature)).toList();
  }

  /// Reset all feature locks (for testing)
  Future<void> resetAllFeatures() async {
    final prefs = await SharedPreferences.getInstance();
    
    for (final feature in _allFeatures) {
      await prefs.remove('$_featurePrefix$feature');
      _featureStates[feature] = _isFeatureUnlockedByDefault(feature);
    }
    
    for (final action in _allActions) {
      await prefs.remove('$_actionCountPrefix$action');
      _actionCounts[action] = 0;
    }
    
    notifyListeners();
  }

  /// Check if feature is unlocked by default
  bool _isFeatureUnlockedByDefault(String featureId) {
    // Only basic tracking is unlocked by default
    return featureId == featureBasicTracking;
  }

  /// All available features
  static const List<String> _allFeatures = [
    featureBasicTracking,
    featureCycleCalendar,
    featureSymptomTracking,
    featureMoodTracking,
    featureAiInsights,
    featureAdvancedAnalytics,
    featureBiometricIntegration,
    featureHealthDashboard,
    featureAiCoach,
    featureDataExport,
    featurePredictiveInsights,
    featureMlPredictions,
  ];

  /// All trackable actions
  static const List<String> _allActions = [
    actionLogPeriod,
    actionLogSymptom,
    actionLogMood,
    actionViewCalendar,
    actionViewInsights,
    actionUseApp,
  ];
}

/// Represents a feature unlock requirement
class FeatureUnlockRequirement {
  final String featureId;
  final String description;
  final int currentProgress;
  final int requiredProgress;
  final bool isUnlocked;

  const FeatureUnlockRequirement({
    required this.featureId,
    required this.description,
    required this.currentProgress,
    required this.requiredProgress,
    required this.isUnlocked,
  });

  /// Progress as a percentage (0.0 to 1.0)
  double get progressPercentage => 
      isUnlocked ? 1.0 : (currentProgress / requiredProgress).clamp(0.0, 1.0);

  /// Remaining progress needed
  int get remainingProgress => 
      isUnlocked ? 0 : (requiredProgress - currentProgress).clamp(0, requiredProgress);
}
