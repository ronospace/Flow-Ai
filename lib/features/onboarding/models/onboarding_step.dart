class OnboardingStep {
  final String title;
  final String description;
  final String imagePath;
  final List<String> highlights;
  final OnboardingStepType type;
  final Map<String, dynamic>? data;

  const OnboardingStep({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.highlights,
    required this.type,
    this.data,
  });
}

enum OnboardingStepType {
  welcome,
  features,
  privacy,
  permissions,
  setup,
  complete
}

class OnboardingData {
  static List<OnboardingStep> get steps => [
    const OnboardingStep(
      title: 'Welcome to Flow Ai',
      description: 'Your intelligent period and health tracking companion',
      imagePath: 'assets/images/onboarding/welcome.png',
      highlights: [
        'Track your cycle with AI-powered insights',
        'Monitor symptoms and mood patterns',
        'Get personalized health recommendations'
      ],
      type: OnboardingStepType.welcome,
    ),
    const OnboardingStep(
      title: 'Powerful Features',
      description: 'Everything you need for comprehensive health tracking',
      imagePath: 'assets/images/onboarding/features.png',
      highlights: [
        'Smart cycle predictions',
        'Symptom tracking & analysis',
        'Health insights dashboard',
        'Secure data encryption'
      ],
      type: OnboardingStepType.features,
    ),
    const OnboardingStep(
      title: 'Your Privacy Matters',
      description: 'Your health data stays private and secure',
      imagePath: 'assets/images/onboarding/privacy.png',
      highlights: [
        'End-to-end encryption',
        'Data stored locally on your device',
        'No sharing without your permission',
        'GDPR & HIPAA compliant'
      ],
      type: OnboardingStepType.privacy,
    ),
    const OnboardingStep(
      title: 'Enable Notifications',
      description: 'Stay on track with gentle reminders',
      imagePath: 'assets/images/onboarding/notifications.png',
      highlights: [
        'Period & ovulation reminders',
        'Medication tracking alerts',
        'Health goal notifications',
        'Customize frequency & timing'
      ],
      type: OnboardingStepType.permissions,
      data: {'permission': 'notifications'},
    ),
    const OnboardingStep(
      title: 'Setup Your Profile',
      description: 'Personalize your experience',
      imagePath: 'assets/images/onboarding/setup.png',
      highlights: [
        'Set your cycle preferences',
        'Choose tracking goals',
        'Configure reminder schedule',
        'Select language & theme'
      ],
      type: OnboardingStepType.setup,
    ),
    const OnboardingStep(
      title: 'All Set!',
      description: 'You\'re ready to start your health journey',
      imagePath: 'assets/images/onboarding/complete.png',
      highlights: [
        'Start tracking today',
        'Explore AI insights',
        'Join our community',
        'Contact support anytime'
      ],
      type: OnboardingStepType.complete,
    ),
  ];
}
