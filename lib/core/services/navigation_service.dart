import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Enhanced Navigation Service with state persistence and proper back navigation
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  late SharedPreferences _prefs;
  final List<NavigationState> _navigationHistory = [];
  final Map<String, dynamic> _pageStates = {};
  
  static const String _historyKey = 'navigation_history';
  static const String _statesKey = 'page_states';

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadNavigationHistory();
    await _loadPageStates();
  }

  /// Save current page state (scroll position, form data, etc.)
  void savePageState(String route, Map<String, dynamic> state) {
    _pageStates[route] = state;
    _savePageStates();
  }

  /// Get saved page state
  Map<String, dynamic>? getPageState(String route) {
    return _pageStates[route];
  }

  /// Record navigation to track back navigation properly
  void recordNavigation(String route, {Map<String, dynamic>? context}) {
    final navigationState = NavigationState(
      route: route,
      timestamp: DateTime.now(),
      context: context ?? {},
    );
    
    _navigationHistory.add(navigationState);
    
    // Keep only last 20 navigation entries to avoid memory bloat
    if (_navigationHistory.length > 20) {
      _navigationHistory.removeAt(0);
    }
    
    _saveNavigationHistory();
  }

  /// Get the proper back navigation route based on context
  String? getBackRoute(BuildContext? context) {
    if (_navigationHistory.length < 2) return null;
    
    // Remove current route
    final currentRoute = _navigationHistory.last.route;
    
    // Find the previous different route
    for (int i = _navigationHistory.length - 2; i >= 0; i--) {
      final previousRoute = _navigationHistory[i];
      if (previousRoute.route != currentRoute) {
        return previousRoute.route;
      }
    }
    
    return null;
  }

  /// Enhanced back navigation that goes to the actual previous screen
  bool navigateBack(BuildContext context) {
    final backRoute = getBackRoute(context);
    
    if (backRoute != null) {
      // Remove current route from history to prevent loops
      if (_navigationHistory.isNotEmpty) {
        _navigationHistory.removeLast();
      }
      
      context.go(backRoute);
      return true;
    }
    
    // Fallback to system back if no custom route found
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return true;
    }
    
    return false;
  }

  /// Clear navigation history (useful for logout)
  void clearHistory() {
    _navigationHistory.clear();
    _pageStates.clear();
    _saveNavigationHistory();
    _savePageStates();
  }

  /// Get navigation context for current route
  Map<String, dynamic>? getCurrentContext() {
    return _navigationHistory.isNotEmpty ? _navigationHistory.last.context : null;
  }

  /// Check if we can navigate back
  bool canNavigateBack() {
    return getBackRoute(null) != null;
  }

  Future<void> _saveNavigationHistory() async {
    final historyJson = _navigationHistory
        .map((state) => state.toJson())
        .toList();
    await _prefs.setString(_historyKey, json.encode(historyJson));
  }

  Future<void> _loadNavigationHistory() async {
    final historyString = _prefs.getString(_historyKey);
    if (historyString != null) {
      final List<dynamic> historyJson = json.decode(historyString);
      _navigationHistory.clear();
      _navigationHistory.addAll(
        historyJson.map((json) => NavigationState.fromJson(json))
      );
    }
  }

  Future<void> _savePageStates() async {
    await _prefs.setString(_statesKey, json.encode(_pageStates));
  }

  Future<void> _loadPageStates() async {
    final statesString = _prefs.getString(_statesKey);
    if (statesString != null) {
      final Map<String, dynamic> states = json.decode(statesString);
      _pageStates.clear();
      _pageStates.addAll(states);
    }
  }
}

/// Navigation state model
class NavigationState {
  final String route;
  final DateTime timestamp;
  final Map<String, dynamic> context;

  NavigationState({
    required this.route,
    required this.timestamp,
    required this.context,
  });

  Map<String, dynamic> toJson() {
    return {
      'route': route,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
    };
  }

  factory NavigationState.fromJson(Map<String, dynamic> json) {
    return NavigationState(
      route: json['route'],
      timestamp: DateTime.parse(json['timestamp']),
      context: Map<String, dynamic>.from(json['context'] ?? {}),
    );
  }
}

/// Enhanced back navigation widget
class SmartBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  
  const SmartBackButton({
    super.key,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: color,
      ),
      onPressed: onPressed ?? () {
        final navigationService = NavigationService();
        if (!navigationService.navigateBack(context)) {
          // If smart navigation fails, try system back
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
      },
    );
  }
}

/// Mixin for pages that want to save/restore state
mixin StatePersistenceMixin<T extends StatefulWidget> on State<T> {
  String get routeName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreState();
    });
  }

  @override
  void dispose() {
    _saveState();
    super.dispose();
  }

  /// Override this to save custom state
  Map<String, dynamic> getStateToSave() {
    return {};
  }

  /// Override this to restore custom state
  void restoreState(Map<String, dynamic> state) {
    // Override in child classes
  }

  void _saveState() {
    final state = getStateToSave();
    if (state.isNotEmpty) {
      NavigationService().savePageState(routeName, state);
    }
  }

  void _restoreState() {
    final state = NavigationService().getPageState(routeName);
    if (state != null) {
      restoreState(state);
    }
  }
}
