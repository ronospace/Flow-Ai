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
  complete,
}

class OnboardingData {
  static List<OnboardingStep> get steps => [
    const OnboardingStep(
      title: 'Your Privacy Matters',
      description: 'Your health data stays private and secure',
      imagePath: 'assets/images/onboarding/privacy.png',
      highlights: [
        'Permissions stay under your control',
        'Security safeguards help protect your data',
        'Manage your data and preferences in Settings',
        'Review our Privacy Policy for full details',
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
        'Customize frequency & timing',
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
        'Select language & theme',
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
        'Contact support anytime',
      ],
      type: OnboardingStepType.complete,
    ),
  ];
}
