import 'package:flutter/foundation.dart';
import '../../../core/models/ai_insights.dart';

class InsightsProvider extends ChangeNotifier {
  final List<AIInsight> _insights = [];
  bool _isLoading = false;
  bool _premiumUnlocked = false;

  List<AIInsight> get insights => List.unmodifiable(_insights);
  bool get isLoading => _isLoading;
  bool get premiumUnlocked => _premiumUnlocked;

  Future<void> loadInsights() async {
    _isLoading = true;
    notifyListeners();

    _insights.clear();

    _isLoading = false;
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
