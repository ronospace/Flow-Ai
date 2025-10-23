import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../generated/app_localizations.dart';
import '../../../generated/app_localizations_ui_extensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/admob_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/cycle_data.dart';
import '../providers/cycle_provider.dart';
import '../../insights/providers/insights_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/services/cycle_calculation_engine.dart';
import '../../../core/widgets/coming_soon_widget.dart';
import '../../../core/ai/period_prediction_engine.dart';
import '../../ai_predictions/widgets/ai_prediction_card.dart';
import '../../ai_predictions/screens/ai_predictions_screen.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _dashboardController;
  late AnimationController _healthController;
  late AnimationController _predictiveController;
  late Animation<double> _dashboardAnimation;
  late Animation<double> _healthAnimation;
  late Animation<double> _predictiveAnimation;
  
  // AdMob
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  final AdMobService _adMobService = AdMobService();
  
  // AI Prediction
  PeriodPrediction? _currentPrediction;
  bool _isLoadingPrediction = false;
  
  @override
  void initState() {
    super.initState();
    
    // Use slower, less intensive animations to reduce frame drops
    _dashboardController = AnimationController(
      duration: const Duration(seconds: 6), // Slower animation
      vsync: this,
    );
    
    _healthController = AnimationController(
      duration: const Duration(seconds: 4), // Slower animation
      vsync: this,
    );
    
    _predictiveController = AnimationController(
      duration: const Duration(seconds: 8), // Much slower animation
      vsync: this,
    );
    
    // Use easier easing curves
    _dashboardAnimation = CurvedAnimation(
      parent: _dashboardController,
      curve: Curves.easeInOut,
    );
    
    _healthAnimation = CurvedAnimation(
      parent: _healthController,
      curve: Curves.easeInOut,
    );
    
    _predictiveAnimation = CurvedAnimation(
      parent: _predictiveController,
      curve: Curves.easeInOut,
    );
    
    // Start animations with a delay to not block UI
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _dashboardController.repeat();
        _healthController.repeat();
        _predictiveController.repeat();
      }
    });
    
    // Defer heavy operations to not block UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          context.read<CycleProvider>().loadCycles();
          context.read<InsightsProvider>().loadInsights();
        }
      });
      
      // Load ad even later to not impact startup
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _loadBannerAd();
        }
      });
      
      // Load AI prediction
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _loadAIPrediction();
        }
      });
    });
  }
  
  @override
  void dispose() {
    _dashboardController.dispose();
    _healthController.dispose();
    _predictiveController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }
  
  void _loadBannerAd() {
    _bannerAd = _adMobService.createBannerAd();
    _bannerAd!.load().then((_) {
      setState(() {
        _isBannerAdReady = true;
      });
    });
  }
  
  Future<void> _loadAIPrediction() async {
    if (mounted) {
      setState(() {
        _isLoadingPrediction = true;
      });
    }

    try {
      // Get current user ID from auth service
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;
      final userId = currentUser?.uid ?? 'anonymous_user';
      
      final prediction = await PeriodPredictionEngine().predictNextPeriod(userId);
      
      if (mounted) {
        setState(() {
          _currentPrediction = prediction;
          _isLoadingPrediction = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPrediction = false;
        });
      }
    }
  }
  
  Widget _buildBannerAdWidget() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AdWidget(ad: _bannerAd!),
    ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildPremiumInsightsUnlockWidget() {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.warningOrange.withValues(alpha: 0.1),
            AppTheme.primaryRose.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.warningOrange.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.warningOrange, AppTheme.primaryRose],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.star,
                  color: theme.colorScheme.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.unlockPremiumAiInsights,
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    Text(
                      localizations.watchAdToUnlockInsights,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.warningOrange, AppTheme.primaryRose],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  localizations.free,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showRewardedAdForInsights,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.warningOrange, AppTheme.primaryRose],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.warningOrange.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_fill,
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      localizations.watchAdUnlockInsights,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Icon(
                Icons.check_circle,
              color: AppTheme.sweetPeach,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  localizations.getAdditionalPremiumInsights,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.check_circle,
              color: AppTheme.sweetPeach,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  localizations.unlockAdvancedHealthRecommendations,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }
  
  void _showRewardedAdForInsights() {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    _adMobService.showRewardedAdWithFrequency(
      onRewarded: (reward) {
        // User watched the full ad, unlock premium insights
        _unlockPremiumInsights();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.star,
                  color: AppTheme.warningOrange,
                ),
                const SizedBox(width: 8),
                Text(
                  localizations.premiumInsightsUnlocked,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.sweetPeach,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
  }
  
  void _unlockPremiumInsights() {
    // Simulate unlocking premium insights by adding them to the provider
    final insightsProvider = context.read<InsightsProvider>();
    insightsProvider.addPremiumInsights();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return SafeArea(
            child: Consumer3<CycleProvider, InsightsProvider, SettingsProvider>(
              builder: (context, cycleProvider, insightsProvider, settings, child) {
                  if (cycleProvider.isLoading) {
                    return _buildLoadingInterface(localizations);
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // REVOLUTIONARY: AI-Powered Dynamic Header
                        _buildRevolutionaryHeader(settings),
                        const SizedBox(height: 24),
                        
                        // AI Prediction Summary
                        _LazyWidget(
                          builder: () => _buildAIPredictionSummary(),
                        ),
                        const SizedBox(height: 24),
                        
                        // Use lazy loading for heavy widgets to improve performance
                        _LazyWidget(
                          builder: () => _buildHealthDashboardMatrix(cycleProvider),
                        ),
                        const SizedBox(height: 24),
                        
                        _LazyWidget(
                          builder: () => _buildPredictiveAnalyticsCenter(cycleProvider),
                        ),
                        const SizedBox(height: 24),
                        
                        _LazyWidget(
                          builder: () => _buildAIHealthInsightsPortal(insightsProvider),
                        ),
                        const SizedBox(height: 24),
                        
                        _LazyWidget(
                          builder: () => _buildSmartActionCommandCenter(),
                        ),
                        const SizedBox(height: 24),
                        
                        _LazyWidget(
                          builder: () => _buildHealthTrendsVisualization(),
                        ),
                        const SizedBox(height: 24),
                        
                        // Premium Features Coming Soon
                        _LazyWidget(
                          builder: () => _buildPremiumFeaturesPreview(),
                        ),
                        
                        // Banner Ad - load last to not impact UI
                        if (_isBannerAdReady) ...[
                          const SizedBox(height: 24),
                          _LazyWidget(
                            builder: () => _buildBannerAdWidget(),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            );
        },
      ),
    );
  }
  
  Widget _buildLoadingInterface(AppLocalizations localizations) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient(isDark),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulsing ring
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryRose.withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2))
                .fadeIn(duration: 1000.ms)
                .then(delay: 500.ms)
                .fadeOut(duration: 1000.ms),
              
              // Inner loading circle
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRose),
                  strokeWidth: 6,
                ),
              ),
              
              // AI brain icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.secondaryBlue, AppTheme.accentMint],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 20,
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms)
                .then(delay: 500.ms),
            ],
          ),
          
          const SizedBox(height: 32),
          
          Text(
            localizations.loadingAiEngine,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(delay: 500.ms),
          
          const SizedBox(height: 8),
          
          Text(
            localizations.analyzingHealthPatterns,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ).animate().fadeIn(delay: 800.ms),
        ],
      ),
    );
  }
  
  Widget _buildRevolutionaryHeader(SettingsProvider settingsProvider) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final now = DateTime.now();
    final baseGreeting = now.hour < 12 
        ? localizations.goodMorning 
        : now.hour < 17 
            ? localizations.goodAfternoon 
            : localizations.goodEvening;
    
    final displayName = settingsProvider.preferences.displayName;
    final personalizedGreeting = displayName.isNotEmpty
        ? '$baseGreeting, $displayName!'
        : '$baseGreeting!';
    
    // Simulate AI health score based on time and random factors
    final healthScore = 0.75 + (math.sin(now.millisecondsSinceEpoch / 100000) * 0.2);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.cardColor,
            AppTheme.primaryRose.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryRose.withValues(alpha: 0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: theme.colorScheme.surface,
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$personalizedGreeting 👋',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppTheme.darkGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMMM d').format(now),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.mediumGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.secondaryBlue, AppTheme.accentMint],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.psychology,
                                color: theme.colorScheme.onPrimary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                localizations.aiActive,
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ).animate(onPlay: (controller) => controller.repeat())
                          .shimmer(duration: 2000.ms)
                          .then(delay: 1000.ms),
                      ],
                    ),
                  ],
                ),
              ),
              
              // REVOLUTIONARY: Real-time Health Score Indicator
              Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Health score ring
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: AnimatedBuilder(
                          animation: _healthAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: HealthScorePainter(
                                score: healthScore,
                                animation: _healthAnimation.value,
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Score display
                      Column(
                        children: [
                          Text(
                            '${(healthScore * 100).round()}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryRose,
                            ),
                          ),
                          Text(
                            localizations.health,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.mediumGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      localizations.optimal,
                      style: TextStyle(
                        color: AppTheme.successGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.3, end: 0);
  }


  Widget _buildCurrentCycleCard(CycleProvider provider) {
    final theme = Theme.of(context);
    final currentCycle = provider.currentCycle;
    
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'Current Cycle',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (currentCycle != null) ...[
              Text(
                'Day ${DateTime.now().difference(currentCycle.startDate).inDays + 1}',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildCycleInfo('Flow', currentCycle.flowIntensity?.emoji ?? '✨'),
                  const SizedBox(width: 20),
                  if (currentCycle.mood != null)
                    _buildCycleInfo('Mood', '${currentCycle.mood}/5'),
                  const SizedBox(width: 20),
                  if (currentCycle.energy != null)
                    _buildCycleInfo('Energy', '${currentCycle.energy}/5'),
                ],
              ),
            ] else ...[
              Text(
                'No active cycle',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Navigate to tracking
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: AppTheme.primaryRose,
                ),
                child: const Text('Start Tracking'),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildCycleInfo(String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }


  Widget _buildInsightsSection(InsightsProvider provider) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Insights',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        ...provider.insights.map((insight) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  insight.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (insight.recommendations.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: insight.recommendations.map((rec) => Chip(
                      label: Text(rec),
                      backgroundColor: AppTheme.accentMint.withValues(alpha: 0.1),
                      labelStyle: const TextStyle(
                        color: AppTheme.accentMint,
                        fontSize: 12,
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ).animate().fadeIn(delay: (700 + provider.insights.indexOf(insight) * 100).ms)),
      ],
    );
  }

  Widget _buildQuickActions() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.add_circle_rounded,
                title: 'Log Period',
                color: AppTheme.primaryRose,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.insights_rounded,
                title: 'View Insights',
                color: AppTheme.secondaryBlue,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 1000.ms).scale(begin: const Offset(0.8, 0.8));
  }
  
  Widget _buildHealthDashboardMatrix(CycleProvider provider) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.cardColor,
            AppTheme.secondaryBlue.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.secondaryBlue.withValues(alpha: 0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.secondaryBlue, AppTheme.accentMint],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.dashboard_customize,
                  color: theme.colorScheme.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.healthDashboardMatrix,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                    Text(
                      localizations.realTimeBiometricAnalysis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Health Matrix Grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: [
              _buildHealthMetricCard(
                localizations.cycleStatus,
                provider.cycleData?.currentCycle != null 
                    ? localizations.day(provider.cycleData!.currentCycleDay)
                    : localizations.notStarted,
                Icons.favorite,
                AppTheme.primaryRose,
                provider.predictions?.confidence != null 
                    ? '${(provider.predictions!.confidence.score * 100).round()}%'
                    : '0%',
              ),
              
              _buildHealthMetricCard(
                'Phase', // This could be localized in the future
                provider.predictions?.currentPhase.displayName ?? 'Unknown', // This could be localized in the future
                Icons.psychology,
                AppTheme.secondaryBlue,
                provider.predictions?.confidence != null 
                    ? '${(provider.predictions!.confidence.score * 100).round()}%'
                    : '0%',
              ),
              
              _buildHealthMetricCard(
                localizations.nextPeriod,
                provider.predictions?.daysUntilNextPeriod != null 
                    ? '${provider.predictions!.daysUntilNextPeriod} ${localizations.days}'
                    : 'Unknown', // This could be localized in the future
                Icons.calendar_today,
                AppTheme.accentMint,
                provider.predictions?.confidence != null 
                    ? '${(provider.predictions!.confidence.score * 100).round()}%'
                    : '0%',
              ),
              
              _buildHealthMetricCard(
                localizations.cycleLengthLabel,
                provider.predictions?.cycleLength != null 
                    ? '${provider.predictions!.cycleLength} ${localizations.days}'
                    : '28 ${localizations.days}',
                Icons.loop,
                AppTheme.warningOrange,
                provider.insights?.periodPredictionAccuracy != null 
                    ? '${(provider.insights!.periodPredictionAccuracy * 100).round()}%'
                    : '50%',
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.3, end: 0);
  }

  Widget _buildHealthMetricCard(String title, String value, IconData icon, Color color, String accuracy) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.cardColor,
            color.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  accuracy,
                  style: TextStyle(
                    color: AppTheme.successGreen,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.mediumGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.darkGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat())
      .shimmer(duration: 3000.ms, color: color.withValues(alpha: 0.1))
      .then(delay: 2000.ms);
  }
  
  Widget _buildPredictiveAnalyticsCenter(CycleProvider provider) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final prediction = provider.predictions;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppTheme.accentMint.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.accentMint.withValues(alpha: 0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.accentMint, AppTheme.secondaryBlue],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_graph,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.predictiveAnalyticsCenter,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                    Text(
                      localizations.aiPoweredCycleForecast,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Neural network visualization
              SizedBox(
                width: 60,
                height: 60,
                child: AnimatedBuilder(
                  animation: _predictiveAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: NeuralNetworkPainter(
                        animation: _predictiveAnimation.value,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          if (prediction != null) ...
          [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryRose.withValues(alpha: 0.1),
                          AppTheme.primaryPurple.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryRose.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.nextPeriod,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.mediumGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('MMM d').format(prediction.nextPeriodDate),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppTheme.primaryRose,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizations.inDays(prediction.daysUntilNextPeriod),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.successGreen.withValues(alpha: 0.1),
                          AppTheme.accentMint.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.successGreen.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Accuracy',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.mediumGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.verified,
                              color: AppTheme.successGreen,
                              size: 16,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(prediction.confidence.score * 100).round()}%',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppTheme.successGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'High confidence',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ] else ...
          [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.lightGrey.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.mediumGrey.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: AppTheme.mediumGrey,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Gathering Data for Predictions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.mediumGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start tracking your cycles to unlock AI predictions',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.mediumGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.3, end: 0);
  }
  
  Widget _buildAIHealthInsightsPortal(InsightsProvider provider) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            AppTheme.primaryPurple.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryPurple, AppTheme.primaryRose],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Health Insights Portal',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                    Text(
                      'Personalized health intelligence',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (provider.insights.isNotEmpty) ...
          [
            // Premium AI insights unlock widget
            if (provider.insights.length < 2)
              _buildPremiumInsightsUnlockWidget(),
            
            ...provider.insights.take(2).map((insight) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface,
                    AppTheme.primaryPurple.withValues(alpha: 0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primaryPurple, AppTheme.accentMint],
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          insight.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkGrey,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'AI',
                          style: TextStyle(
                            color: AppTheme.primaryPurple,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    insight.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mediumGrey,
                      height: 1.4,
                    ),
                  ),
                  if (insight.recommendations.isNotEmpty) ...
                  [
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: insight.recommendations.take(3).map((rec) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.accentMint.withValues(alpha: 0.1), AppTheme.primaryPurple.withValues(alpha: 0.1)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.accentMint.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          rec,
                          style: TextStyle(
                            color: AppTheme.primaryPurple,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: (600 + provider.insights.indexOf(insight) * 200).ms)
             .slideX(begin: 0.2, end: 0)),
          ] else ...
          [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.lightGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.mediumGrey.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.psychology_outlined,
                    color: AppTheme.mediumGrey,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'AI Learning Your Patterns',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.mediumGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your cycles to unlock personalized AI insights',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.mediumGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildSmartActionCommandCenter() {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppTheme.warningOrange.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.warningOrange.withValues(alpha: 0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.warningOrange, AppTheme.primaryRose],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.control_camera,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.smartActionCommandCenter,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                    Text(
                      localizations.quickAccessToEssentialFeatures,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
            GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.8,
            children: [
              _buildSmartActionCard(
                'Log Symptoms',
                'Track your health',
                Icons.healing,
                AppTheme.primaryRose,
                () => _navigateToTracking(1), // Navigate to symptoms tab
              ),
              
              _buildSmartActionCard(
                'Period Tracker',
                'Start logging',
                Icons.favorite,
                AppTheme.secondaryBlue,
                () => _navigateToTracking(0), // Navigate to flow tab
              ),
              
              _buildSmartActionCard(
                localizations.faqAndHelp,
                localizations.getAnswers,
                Icons.help_center,
                AppTheme.accentMint,
                () => _navigateToFAQ(),
              ),
              
              _buildSmartActionCard(
                'AI Insights',
                'View analysis',
                Icons.auto_awesome,
                AppTheme.warningOrange,
                () => _navigateToInsights(),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.9, 0.9));
  }
  
  Widget _buildSmartActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            color.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 14,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.mediumGrey,
                      size: 9,
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGrey,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.mediumGrey,
                        fontSize: 8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
      .shimmer(duration: 4000.ms, color: color.withValues(alpha: 0.05))
      .then(delay: 3000.ms);
  }
  
  Widget _buildHealthTrendsVisualization() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppTheme.successGreen.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.successGreen.withValues(alpha: 0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.successGreen, AppTheme.accentMint],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Trends Visualization',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                    Text(
                      'Long-term health patterns',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Trend visualization placeholder
          Container(
            height: 100,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.successGreen.withValues(alpha: 0.05),
                  AppTheme.accentMint.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.successGreen.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Cycle Regularity',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkGrey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '87%',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successGreen,
                        ),
                      ),
                      Text(
                        '+5% this month',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.successGreen,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Trend graph visualization
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 50,
                    child: AnimatedBuilder(
                      animation: _dashboardAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: TrendGraphPainter(
                            animation: _dashboardAnimation.value,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRose.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryRose.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: AppTheme.primaryRose,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Avg Cycle',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.mediumGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '28.5 days',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryRose,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBlue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.secondaryBlue.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.psychology,
                            color: AppTheme.secondaryBlue,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Avg Mood',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.mediumGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '4.2/5',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3, end: 0);
  }
}

// REVOLUTIONARY: Custom Painters for Advanced Visualizations
class HealthScorePainter extends CustomPainter {
  final double score;
  final double animation;
  
  HealthScorePainter({required this.score, required this.animation});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    
    // Background ring
    final backgroundPaint = Paint()
      ..color = AppTheme.lightGrey.withValues(alpha: 0.3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Animated score ring
    final scorePaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final sweepAngle = (score * 2 * math.pi * animation);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      scorePaint,
    );
    
    // Pulsing effect
    if (animation > 0.7) {
      final pulsePaint = Paint()
        ..color = AppTheme.primaryRose.withValues(alpha: 0.3 - (animation - 0.7) * 0.3)
        ..strokeWidth = 12
        ..style = PaintingStyle.stroke;
      
      canvas.drawCircle(center, radius + (animation - 0.7) * 10, pulsePaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension _PremiumFeaturesMethods on _HomeScreenState {
  Widget _buildPremiumFeaturesPreview() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.cardColor,
            AppTheme.primaryPurple.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryPurple, AppTheme.primaryRose],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Features Coming Soon',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                    Text(
                      'Advanced health intelligence features',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryPurple, AppTheme.primaryRose],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PREVIEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Premium feature cards grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.85,
            children: [
              _buildPremiumFeatureCard(
                'AI Health Coach',
                'Personal health guidance powered by advanced AI',
                Icons.psychology_rounded,
                AppTheme.primaryPurple,
                'Q2 2024',
                () => _showComingSoonDialog('AI Health Coach'),
              ),
              
              _buildPremiumFeatureCard(
                'Partner Sharing',
                'Securely share cycle data with trusted partners',
                Icons.favorite_rounded,
                AppTheme.primaryRose,
                'Q3 2024',
                () => _showComingSoonDialog('Partner Integration'),
              ),
              
              _buildPremiumFeatureCard(
                'Healthcare Portal',
                'Export data for medical appointments',
                Icons.medical_services_rounded,
                AppTheme.secondaryBlue,
                'Q4 2024',
                () => _showComingSoonDialog('Healthcare Provider Portal'),
              ),
              
              _buildPremiumFeatureCard(
                'Advanced Analytics',
                'Deep insights with predictive modeling',
                Icons.analytics_rounded,
                AppTheme.accentMint,
                'Q1 2024',
                () => _showComingSoonDialog('Premium Analytics'),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.3, end: 0);
  }
  
  Widget _buildPremiumFeatureCard(
    String title,
    String description,
    IconData icon,
    Color color,
    String estimatedDate,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            color.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 18,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.warningOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        estimatedDate,
                        style: TextStyle(
                          color: AppTheme.warningOrange,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGrey,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  flex: 2,
                  child: Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.mediumGrey,
                      height: 1.2,
                      fontSize: 10,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: color,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Coming Soon',
                        style: TextStyle(
                          color: color,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.mediumGrey,
                      size: 10,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
      .shimmer(duration: 4000.ms, color: color.withValues(alpha: 0.03))
      .then(delay: 3000.ms);
  }
  
  void _showComingSoonDialog(String featureName) {
    Widget comingSoonWidget;
    
    switch (featureName) {
      case 'AI Health Coach':
        comingSoonWidget = ComingSoonWidgets.aiCoach(
          context,
          onNotifyMe: () => _handleNotifyMe(featureName),
        );
        break;
      case 'Partner Integration':
        comingSoonWidget = ComingSoonWidgets.partnerFeatures(
          context,
          onNotifyMe: () => _handleNotifyMe(featureName),
        );
        break;
      case 'Healthcare Provider Portal':
        comingSoonWidget = ComingSoonWidgets.healthcareProvider(
          context,
          onNotifyMe: () => _handleNotifyMe(featureName),
        );
        break;
      case 'Premium Analytics':
        comingSoonWidget = ComingSoonWidgets.premiumAnalytics(
          context,
          onNotifyMe: () => _handleNotifyMe(featureName),
        );
        break;
      default:
        // Fallback generic coming soon widget
        comingSoonWidget = ComingSoonWidget(
          title: featureName,
          description: 'This advanced feature is currently under development and will be available soon.',
          icon: Icons.auto_awesome,
          estimatedDate: 'Q2 2024',
          onNotifyMe: () => _handleNotifyMe(featureName),
        );
    }
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: comingSoonWidget,
            ),
          ),
        );
      },
    );
  }
  
  void _handleNotifyMe(String featureName) {
    // Safely close the dialog
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
    
    // Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'You\'ll be notified when $featureName is ready!',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Here you could also save the notification preference to local storage
    // or send it to your backend for future notifications
  }
}

// Lazy loading widget to improve performance
class _LazyWidget extends StatefulWidget {
  final Widget Function() builder;
  
  const _LazyWidget({required this.builder});
  
  @override
  State<_LazyWidget> createState() => _LazyWidgetState();
}

class _LazyWidgetState extends State<_LazyWidget> {
  Widget? _cachedWidget;
  bool _isBuilt = false;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Only build widget when it's needed (when scrolled into view)
    if (!_isBuilt) {
      // Use a post-frame callback to defer building until the frame is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isBuilt) {
          setState(() {
            _cachedWidget = widget.builder();
            _isBuilt = true;
          });
        }
      });
      
      // Show a placeholder while building
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: theme.cardColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: SizedBox(width: 20,
            height: 20,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primaryRose.withValues(alpha: 0.5)
              ),
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }
    
    return _cachedWidget ?? const SizedBox.shrink();
  }
}

class NeuralNetworkPainter extends CustomPainter {
  final double animation;
  
  NeuralNetworkPainter({required this.animation});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentMint.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final nodePaint = Paint()
      ..color = AppTheme.secondaryBlue
      ..style = PaintingStyle.fill;
    
    // Create neural network nodes
    final nodes = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.2, size.height * 0.7),
      Offset(size.width * 0.5, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.5, size.height * 0.8),
      Offset(size.width * 0.8, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.6),
    ];
    
    // Draw connections with animation
    final connections = [
      [0, 2], [0, 3], [1, 3], [1, 4],
      [2, 5], [3, 5], [3, 6], [4, 6]
    ];
    
    for (var connection in connections) {
      final start = nodes[connection[0]];
      final end = nodes[connection[1]];
      
      final animatedEnd = Offset(
        start.dx + (end.dx - start.dx) * animation,
        start.dy + (end.dy - start.dy) * animation,
      );
      
      canvas.drawLine(start, animatedEnd, paint);
    }
    
    // Draw nodes
    for (var node in nodes) {
      canvas.drawCircle(node, 3, nodePaint);
      
      // Add pulsing effect
      if (animation > 0.5) {
        final pulsePaint = Paint()
          ..color = AppTheme.accentMint.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(node, 3 + (animation - 0.5) * 4, pulsePaint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension _NavigationMethods on _HomeScreenState {
  void _navigateToTracking([int? tabIndex]) {
    // Show interstitial ad before navigation
    _adMobService.showInterstitialAdWithFrequency();
    
    // Navigate to tracking screen with GoRouter
    Future.delayed(const Duration(milliseconds: 500), () {
      context.go('/tracking');
    });
  }
  
  void _navigateToInsights() {
    // Show interstitial ad before navigation
    _adMobService.showInterstitialAdWithFrequency();

    // Navigate to insights screen with GoRouter
    // Use immediate navigation to prevent state issues
    if (mounted) {
      context.go('/insights');
    }
  }
  
  void _navigateToFAQ() {
    // Show interstitial ad before navigation
    _adMobService.showInterstitialAdWithFrequency();
    
    // Navigate to FAQ screen with GoRouter
    if (mounted) {
      context.go('/faq');
    }
  }
  
  void _navigateToAIPredictions() {
    // Show interstitial ad before navigation
    _adMobService.showInterstitialAdWithFrequency();
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AIPredictionsScreen(),
      ),
    );
  }
  
  Widget _buildAIPredictionSummary() {
    if (_isLoadingPrediction) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryRose.withValues(alpha: 0.1),
              AppTheme.primaryPurple.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryRose.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 20,
              ),
            ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1200.ms),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generating AI Prediction',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'AI is analyzing your cycle patterns...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRose),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 600.ms);
    }
    
    if (_currentPrediction == null) {
      return const SizedBox.shrink();
    }
    
    return AIPredictionSummary(
      prediction: _currentPrediction!,
      onTap: _navigateToAIPredictions,
    );
  }
}

class TrendGraphPainter extends CustomPainter {
  final double animation;
  
  TrendGraphPainter({required this.animation});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.successGreen
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    
    // Create trending upward line
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.7),
      Offset(size.width * 0.4, size.height * 0.5),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width, size.height * 0.1),
    ];
    
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      
      for (int i = 1; i < points.length; i++) {
        final currentPoint = points[i];
        final animatedX = points[0].dx + (currentPoint.dx - points[0].dx) * animation;
        final animatedY = points[0].dy + (currentPoint.dy - points[0].dy) * animation;
        
        if (animatedX <= currentPoint.dx) {
          path.lineTo(animatedX, animatedY);
        }
      }
    }
    
    canvas.drawPath(path, paint);
    
    // Add data points
    for (var point in points) {
      if (animation > 0.5) {
        final dotPaint = Paint()
          ..color = AppTheme.successGreen
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(point, 2, dotPaint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
