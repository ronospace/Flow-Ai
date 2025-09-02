import 'package:flutter/foundation.dart';
import '../../../core/models/ai_insights.dart';

class InsightsProvider extends ChangeNotifier {
  final List<AIInsight> _insights = [];
  bool _isLoading = false;

  List<AIInsight> get insights => List.unmodifiable(_insights);
  bool get isLoading => _isLoading;

  Future<void> loadInsights() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    
    _insights.addAll([
      AIInsight(
        type: InsightType.cycleRegularity,
        title: 'Your cycles are very regular! 🎯',
        description: 'Your cycles are consistently regular, which is a great sign of reproductive health.',
        confidence: 0.87,
        actionable: false,
        recommendations: const ['Keep up your healthy routine!'],
      ),
      AIInsight(
        type: InsightType.symptomPattern,
        title: 'Most common symptom: cramps',
        description: 'You experience cramps in 80% of your cycles.',
        confidence: 0.8,
        actionable: true,
        recommendations: const ['Track timing of cramps', 'Note severity levels'],
      ),
    ]);

    _isLoading = false;
    notifyListeners();
  }
  
  void addPremiumInsights() {
    // Add premium AI insights when user watches rewarded ad
    _insights.addAll([
      AIInsight(
        type: InsightType.healthRecommendation,
        title: '🌟 Premium Insight: Optimal Exercise Timing',
        description: 'Based on your cycle patterns, the best time for high-intensity workouts is days 7-14 of your cycle when energy levels peak.',
        confidence: 0.92,
        actionable: true,
        recommendations: const ['Schedule HIIT workouts days 7-14', 'Try gentle yoga during PMS phase', 'Listen to your body\'s energy cues'],
      ),
      AIInsight(
        type: InsightType.nutritionGuidance,
        title: '🥗 Premium Insight: Cycle-Synced Nutrition',
        description: 'Your data shows improved mood when iron-rich foods are consumed during menstruation. Magnesium intake correlates with reduced cramping.',
        confidence: 0.89,
        actionable: true,
        recommendations: const ['Increase iron intake days 1-5', 'Add magnesium supplements', 'Focus on leafy greens'],
      ),
      AIInsight(
        type: InsightType.sleepOptimization,
        title: '😴 Premium Insight: Sleep Pattern Analysis',
        description: 'Your sleep quality directly impacts cycle regularity. Going to bed 30 minutes earlier during luteal phase improves overall wellness scores.',
        confidence: 0.85,
        actionable: true,
        recommendations: const ['Earlier bedtime days 15-28', 'Create calming bedtime routine', 'Avoid screens 1 hour before bed'],
      ),
    ]);
    
    notifyListeners();
  }
  
  /// Clear all user insights data (used during sign out)
  void clearUserData() {
    _insights.clear();
    _isLoading = false;
    notifyListeners();
    debugPrint('✅ InsightsProvider: All user data cleared');
  }
}
