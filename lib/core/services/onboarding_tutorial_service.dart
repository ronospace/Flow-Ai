import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Interactive tutorial service for feature-specific walkthroughs
class OnboardingTutorialService {
  static const String _tutorialPrefix = 'tutorial_completed_';
  
  // Tutorial IDs
  static const String tutorialHome = 'home';
  static const String tutorialCalendar = 'calendar';
  static const String tutorialTracking = 'tracking';
  static const String tutorialInsights = 'insights';
  static const String tutorialHealth = 'health';
  static const String tutorialSettings = 'settings';
  static const String tutorialAiCoach = 'ai_coach';

  /// Check if a specific tutorial has been completed
  Future<bool> isTutorialCompleted(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_tutorialPrefix$tutorialId') ?? false;
  }

  /// Mark a tutorial as completed
  Future<void> completeTutorial(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_tutorialPrefix$tutorialId', true);
  }

  /// Reset a specific tutorial
  Future<void> resetTutorial(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_tutorialPrefix$tutorialId');
  }

  /// Reset all tutorials
  Future<void> resetAllTutorials() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_tutorialPrefix)) {
        await prefs.remove(key);
      }
    }
  }

  /// Get tutorial steps for a specific feature
  List<TutorialStep> getTutorialSteps(String tutorialId) {
    switch (tutorialId) {
      case tutorialHome:
        return _homeTutorialSteps;
      case tutorialCalendar:
        return _calendarTutorialSteps;
      case tutorialTracking:
        return _trackingTutorialSteps;
      case tutorialInsights:
        return _insightsTutorialSteps;
      case tutorialHealth:
        return _healthTutorialSteps;
      case tutorialSettings:
        return _settingsTutorialSteps;
      case tutorialAiCoach:
        return _aiCoachTutorialSteps;
      default:
        return [];
    }
  }

  // Home Tutorial Steps
  static final List<TutorialStep> _homeTutorialSteps = [
    TutorialStep(
      title: 'Welcome to Your Dashboard',
      description: 'This is your home screen where you can see your current cycle status, upcoming predictions, and quick actions.',
      icon: Icons.home_rounded,
      highlightKey: 'cycle_card',
    ),
    TutorialStep(
      title: 'Cycle Status',
      description: 'View your current cycle day, phase, and days until your next period. The AI updates these predictions based on your tracking data.',
      icon: Icons.calendar_today_rounded,
      highlightKey: 'cycle_status',
    ),
    TutorialStep(
      title: 'Quick Actions',
      description: 'Log your period, symptoms, mood, and more with a single tap. Quick actions adapt to your tracking habits.',
      icon: Icons.touch_app_rounded,
      highlightKey: 'quick_actions',
    ),
    TutorialStep(
      title: 'AI Insights',
      description: 'Get personalized insights and predictions powered by advanced machine learning. The more you track, the smarter it gets!',
      icon: Icons.psychology_rounded,
      highlightKey: 'ai_insights_card',
    ),
  ];

  // Calendar Tutorial Steps
  static final List<TutorialStep> _calendarTutorialSteps = [
    TutorialStep(
      title: 'Your Cycle Calendar',
      description: 'Visualize your cycle history and predictions at a glance. Color-coded days make it easy to understand your patterns.',
      icon: Icons.calendar_month_rounded,
      highlightKey: 'calendar_view',
    ),
    TutorialStep(
      title: 'Period Days',
      description: 'Red indicates period days. Darker red shows heavy flow days, while lighter red indicates lighter days.',
      icon: Icons.water_drop_rounded,
      highlightKey: 'period_indicator',
    ),
    TutorialStep(
      title: 'Fertile Window',
      description: 'Green days show your predicted fertile window. The AI calculates this based on your cycle patterns and biometric data.',
      icon: Icons.egg_rounded,
      highlightKey: 'fertile_indicator',
    ),
    TutorialStep(
      title: 'Tap to Track',
      description: 'Tap any day to log symptoms, mood, flow, and more. Past days show your logged data, future days show predictions.',
      icon: Icons.edit_calendar_rounded,
      highlightKey: 'day_cell',
    ),
  ];

  // Tracking Tutorial Steps
  static final List<TutorialStep> _trackingTutorialSteps = [
    TutorialStep(
      title: 'Track Your Health',
      description: 'Log your daily symptoms, mood, flow intensity, and other health metrics. The more you track, the better your AI predictions.',
      icon: Icons.track_changes_rounded,
      highlightKey: 'tracking_form',
    ),
    TutorialStep(
      title: 'Symptom Logging',
      description: 'Select from a comprehensive list of symptoms. The AI learns which symptoms are most relevant to your cycle phases.',
      icon: Icons.health_and_safety_rounded,
      highlightKey: 'symptom_selector',
    ),
    TutorialStep(
      title: 'Mood Tracking',
      description: 'Track your emotional well-being. The AI correlates your mood patterns with cycle phases to predict future emotional states.',
      icon: Icons.mood_rounded,
      highlightKey: 'mood_selector',
    ),
    TutorialStep(
      title: 'Notes & Context',
      description: 'Add personal notes about lifestyle, diet, exercise, or anything that might affect your cycle. This enriches AI predictions.',
      icon: Icons.note_add_rounded,
      highlightKey: 'notes_field',
    ),
  ];

  // Insights Tutorial Steps
  static final List<TutorialStep> _insightsTutorialSteps = [
    TutorialStep(
      title: 'AI-Powered Insights',
      description: 'Discover patterns in your cycle, symptoms, and health data using advanced machine learning algorithms.',
      icon: Icons.insights_rounded,
      highlightKey: 'insights_dashboard',
    ),
    TutorialStep(
      title: 'Cycle Predictions',
      description: 'See AI predictions for your next period, ovulation, and cycle length. Confidence scores show prediction accuracy.',
      icon: Icons.timeline_rounded,
      highlightKey: 'cycle_predictions',
    ),
    TutorialStep(
      title: 'Symptom Patterns',
      description: 'Visualize when symptoms typically occur in your cycle. The AI identifies patterns you might not notice yourself.',
      icon: Icons.show_chart_rounded,
      highlightKey: 'symptom_chart',
    ),
    TutorialStep(
      title: 'Health Recommendations',
      description: 'Get personalized recommendations based on your cycle phase, symptoms, and health goals. Updated daily by the AI.',
      icon: Icons.recommend_rounded,
      highlightKey: 'recommendations',
    ),
  ];

  // Health Tutorial Steps
  static final List<TutorialStep> _healthTutorialSteps = [
    TutorialStep(
      title: 'Health Dashboard',
      description: 'Monitor your overall reproductive health with comprehensive metrics and biometric data integration.',
      icon: Icons.favorite_rounded,
      highlightKey: 'health_dashboard',
    ),
    TutorialStep(
      title: 'Biometric Integration',
      description: 'Connect Apple Health or Google Fit to track heart rate, temperature, sleep, and other metrics that affect your cycle.',
      icon: Icons.monitor_heart_rounded,
      highlightKey: 'biometric_card',
    ),
    TutorialStep(
      title: 'Health Alerts',
      description: 'Receive alerts for potential health concerns like irregular cycles, PCOS indicators, or endometriosis patterns.',
      icon: Icons.warning_rounded,
      highlightKey: 'health_alerts',
    ),
    TutorialStep(
      title: 'Export Health Data',
      description: 'Export your health data as PDF reports to share with healthcare providers. Includes AI insights and pattern analysis.',
      icon: Icons.file_download_rounded,
      highlightKey: 'export_button',
    ),
  ];

  // Settings Tutorial Steps
  static final List<TutorialStep> _settingsTutorialSteps = [
    TutorialStep(
      title: 'Customize Your Experience',
      description: 'Personalize Flow Ai to match your preferences, from appearance to notifications and privacy settings.',
      icon: Icons.settings_rounded,
      highlightKey: 'settings_list',
    ),
    TutorialStep(
      title: 'Notification Settings',
      description: 'Configure reminders for period, ovulation, medication, and tracking. Set quiet hours and notification frequency.',
      icon: Icons.notifications_rounded,
      highlightKey: 'notification_settings',
    ),
    TutorialStep(
      title: 'Data & Privacy',
      description: 'Manage your data exports, backups, and privacy settings. Your data is encrypted and stored locally by default.',
      icon: Icons.privacy_tip_rounded,
      highlightKey: 'privacy_settings',
    ),
    TutorialStep(
      title: 'Reset Tutorials',
      description: 'Want to see the tutorials again? You can reset them individually or all at once from the help section.',
      icon: Icons.refresh_rounded,
      highlightKey: 'tutorial_reset',
    ),
  ];

  // AI Coach Tutorial Steps
  static final List<TutorialStep> _aiCoachTutorialSteps = [
    TutorialStep(
      title: 'Your AI Health Coach',
      description: 'Chat with your personal AI coach for cycle insights, symptom analysis, and health recommendations.',
      icon: Icons.smart_toy_rounded,
      highlightKey: 'ai_coach_chat',
    ),
    TutorialStep(
      title: 'Ask Questions',
      description: 'Ask about your cycle patterns, symptom predictions, fertility window, or any health-related questions.',
      icon: Icons.question_answer_rounded,
      highlightKey: 'chat_input',
    ),
    TutorialStep(
      title: 'Personalized Advice',
      description: 'Get advice tailored to your unique cycle data and health profile. The AI learns from your tracking history.',
      icon: Icons.lightbulb_rounded,
      highlightKey: 'ai_response',
    ),
    TutorialStep(
      title: 'Medical Disclaimer',
      description: 'Remember: AI Coach provides general guidance, not medical advice. Always consult healthcare professionals for medical concerns.',
      icon: Icons.medical_information_rounded,
      highlightKey: 'disclaimer',
    ),
  ];
}

/// Represents a single step in an interactive tutorial
class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final String? highlightKey; // Key to highlight specific UI element
  final Duration? duration; // Optional auto-advance duration

  const TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    this.highlightKey,
    this.duration,
  });
}

/// Tutorial overlay controller for displaying interactive tutorials
class TutorialOverlayController {
  final BuildContext context;
  final String tutorialId;
  final OnboardingTutorialService service;
  
  int _currentStep = 0;
  List<TutorialStep>? _steps;
  OverlayEntry? _overlayEntry;

  TutorialOverlayController({
    required this.context,
    required this.tutorialId,
    required this.service,
  });

  /// Start the tutorial
  Future<void> start() async {
    final completed = await service.isTutorialCompleted(tutorialId);
    if (completed) return;

    _steps = service.getTutorialSteps(tutorialId);
    if (_steps == null || _steps!.isEmpty) return;

    _currentStep = 0;
    _showOverlay();
  }

  /// Show the tutorial overlay
  void _showOverlay() {
    if (_steps == null || _currentStep >= _steps!.length) {
      _complete();
      return;
    }

    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) => TutorialOverlayWidget(
        step: _steps![_currentStep],
        currentStep: _currentStep,
        totalSteps: _steps!.length,
        onNext: _nextStep,
        onSkip: _complete,
        onPrevious: _currentStep > 0 ? _previousStep : null,
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Move to next step
  void _nextStep() {
    _currentStep++;
    _showOverlay();
  }

  /// Move to previous step
  void _previousStep() {
    _currentStep--;
    _showOverlay();
  }

  /// Complete the tutorial
  void _complete() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    service.completeTutorial(tutorialId);
  }

  /// Dispose resources
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

/// Tutorial overlay widget
class TutorialOverlayWidget extends StatelessWidget {
  final TutorialStep step;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback? onPrevious;

  const TutorialOverlayWidget({
    super.key,
    required this.step,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onSkip,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastStep = currentStep == totalSteps - 1;

    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: Stack(
          children: [
            // Tap anywhere to dismiss overlay
            GestureDetector(
              onTap: onSkip,
              child: Container(color: Colors.transparent),
            ),
            
            // Tutorial content card
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon and progress
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              step.icon,
                              color: theme.primaryColor,
                              size: 28,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${currentStep + 1}/$totalSteps',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Title
                      Text(
                        step.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Description
                      Text(
                        step.description,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      
                      // Progress indicator
                      LinearProgressIndicator(
                        value: (currentStep + 1) / totalSteps,
                        backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 20),
                      
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Previous button
                          if (onPrevious != null)
                            TextButton(
                              onPressed: onPrevious,
                              child: const Text('Previous'),
                            )
                          else
                            const SizedBox.shrink(),
                          
                          // Skip button
                          TextButton(
                            onPressed: onSkip,
                            child: const Text('Skip'),
                          ),
                          
                          // Next/Done button
                          FilledButton(
                            onPressed: onNext,
                            child: Text(isLastStep ? 'Done' : 'Next'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
