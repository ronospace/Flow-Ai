import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/coming_soon_card.dart';
import '../../../core/widgets/modern_button.dart';

class ComingSoonScreen extends StatefulWidget {
  const ComingSoonScreen({super.key});

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardsController;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardsController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient(theme.brightness == Brightness.dark),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(theme),
              
              // Coming Soon Cards
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  children: [
                    _buildComingSoonList(),
                    _buildPremiumFeatures(),
                    _buildBetaFeatures(),
                  ],
                ),
              ),
              
              // Page Indicator
              _buildPageIndicator(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRose.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 40,
            ),
          ).animate(controller: _headerController)
            .scale(begin: const Offset(0.5, 0.5))
            .fadeIn(),

          const SizedBox(height: 24),

          // Title
          Text(
            'Exciting Features Coming Soon',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGrey,
            ),
            textAlign: TextAlign.center,
          ).animate(controller: _headerController)
            .slideY(begin: 0.3, end: 0)
            .fadeIn(delay: 200.ms),

          const SizedBox(height: 12),

          // Subtitle
          Text(
            'We\'re working hard to bring you the most advanced period and health tracking experience. Here\'s what\'s coming next!',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.mediumGrey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate(controller: _headerController)
            .slideY(begin: 0.3, end: 0)
            .fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildComingSoonList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          ComingSoonCards.feature(
            title: 'Advanced AI Cycle Predictions',
            description: 'Get hyper-accurate cycle predictions powered by machine learning algorithms that learn from your unique patterns and health data.',
            icon: Icons.psychology_rounded,
            releaseEstimate: 'Next Month',
            features: [
              'Personalized prediction accuracy up to 99%',
              'Integration with wearable devices',
              'Mood and energy level forecasting',
              'Fertility window optimization',
            ],
            onNotifyMeTapped: () => _handleNotifyMe('AI Predictions'),
          ),
          
          ComingSoonCards.feature(
            title: 'Smart Health Insights Dashboard',
            description: 'Comprehensive health analytics with beautiful visualizations and actionable insights based on your tracking data.',
            icon: Icons.dashboard_rounded,
            releaseEstimate: '6-8 Weeks',
            features: [
              'Interactive health trend charts',
              'Symptom correlation analysis',
              'Personalized health recommendations',
              'Export reports for healthcare providers',
            ],
            onNotifyMeTapped: () => _handleNotifyMe('Health Dashboard'),
          ),
          
          ComingSoonCards.enhancement(
            title: 'Wearable Device Integration',
            description: 'Seamlessly connect your smartwatch and fitness trackers to automatically sync health data and enhance predictions.',
            icon: Icons.watch_rounded,
            releaseEstimate: '2-3 Months',
            features: [
              'Apple Watch & Fitbit integration',
              'Heart rate variability tracking',
              'Sleep quality correlation',
              'Automatic activity logging',
            ],
            onNotifyMeTapped: () => _handleNotifyMe('Wearable Integration'),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPremiumFeatures() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          ComingSoonCards.premium(
            title: 'FlowSense Pro',
            description: 'Unlock the full potential of FlowSense with premium features designed for power users who want the ultimate tracking experience.',
            icon: Icons.workspace_premium_rounded,
            releaseEstimate: 'Q2 2025',
            features: [
              'Unlimited data history and backups',
              'Advanced AI coaching and recommendations',
              'Priority customer support',
              'Export to 20+ health apps',
              'Custom reminder schedules',
              'Detailed medication tracking',
            ],
            onNotifyMeTapped: () => _handleNotifyMe('FlowSense Pro'),
          ),
          
          ComingSoonCards.premium(
            title: 'Telehealth Integration',
            description: 'Connect directly with healthcare providers and share your data securely for better reproductive health care.',
            icon: Icons.video_call_rounded,
            releaseEstimate: 'Q3 2025',
            features: [
              'In-app video consultations',
              'Secure health data sharing',
              'Prescription tracking',
              'Lab result integration',
              'Insurance provider network',
            ],
            onNotifyMeTapped: () => _handleNotifyMe('Telehealth'),
          ),
          
          ComingSoonCards.premium(
            title: 'Couple\'s Sync',
            description: 'Share important cycle information with your partner while maintaining privacy and improving communication.',
            icon: Icons.favorite_rounded,
            releaseEstimate: 'Q4 2025',
            features: [
              'Partner notification preferences',
              'Shared calendar view',
              'Communication insights',
              'Relationship health tracking',
              'Privacy-first data sharing',
            ],
            onNotifyMeTapped: () => _handleNotifyMe('Couple\'s Sync'),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildBetaFeatures() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          ComingSoonCards.beta(
            title: 'Voice Assistant Integration',
            description: 'Log your daily symptoms and ask questions about your cycle using natural voice commands with our AI assistant.',
            icon: Icons.mic_rounded,
            releaseEstimate: 'Beta Testing',
            features: [
              'Hands-free symptom logging',
              'Voice-activated reminders',
              'Natural language queries',
              'Multi-language support',
            ],
            onNotifyMeTapped: () => _handleJoinBeta('Voice Assistant'),
          ),
          
          ComingSoonCards.beta(
            title: 'Augmented Reality Body Map',
            description: 'Use your camera to visualize and track symptoms on a 3D body map using cutting-edge AR technology.',
            icon: Icons.view_in_ar_rounded,
            releaseEstimate: 'Beta Testing',
            features: [
              'AR-powered symptom mapping',
              '3D body visualization',
              'Pain intensity heat maps',
              'Photo-realistic tracking',
            ],
            onNotifyMeTapped: () => _handleJoinBeta('AR Body Map'),
          ),
          
          ComingSoonCards.beta(
            title: 'Community Support Groups',
            description: 'Connect with other FlowSense users in anonymous, supportive communities focused on reproductive health.',
            icon: Icons.groups_rounded,
            releaseEstimate: 'Beta Testing',
            features: [
              'Anonymous community forums',
              'Expert-moderated discussions',
              'Peer support matching',
              'Educational workshops',
              'Achievement sharing',
            ],
            onNotifyMeTapped: () => _handleJoinBeta('Community'),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index 
                ? AppTheme.primaryRose 
                : AppTheme.mediumGrey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  void _handleNotifyMe(String feature) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('You\'ll be notified when $feature is ready!'),
            ),
          ],
        ),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleJoinBeta(String feature) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).cardColor,
                AppTheme.accentMint.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.accentMint, AppTheme.secondaryBlue],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.science_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Join Beta Testing',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Be among the first to test $feature and help us make FlowSense even better!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mediumGrey,
                ),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: ModernButtons.secondary(
                      text: 'Maybe Later',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ModernButtons.primary(
                      text: 'Join Beta',
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.rocket_launch, color: Colors.white),
                                const SizedBox(width: 8),
                                Text('Welcome to the $feature beta program!'),
                              ],
                            ),
                            backgroundColor: AppTheme.accentMint,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
