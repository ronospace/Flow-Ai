import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_button.dart';

/// Beautiful "Coming Soon" placeholder widget for advanced features
class ComingSoonWidget extends StatelessWidget {
  const ComingSoonWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.featureList,
    this.estimatedDate,
    this.onNotifyMe,
    this.backgroundColor,
    this.gradientColors,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<String>? featureList;
  final String? estimatedDate;
  final VoidCallback? onNotifyMe;
  final Color? backgroundColor;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Container(
      decoration: BoxDecoration(
        gradient: gradientColors != null 
            ? LinearGradient(
                colors: gradientColors!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : AppTheme.backgroundGradient(theme.brightness == Brightness.dark),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Main illustration
            _buildMainIllustration(context),
            
            const SizedBox(height: 40),
            
            // Title and description
            _buildTitleSection(context),
            
            const SizedBox(height: 32),
            
            // Feature list
            if (featureList != null && featureList!.isNotEmpty)
              _buildFeatureList(context),
            
            const SizedBox(height: 32),
            
            // Estimated date
            if (estimatedDate != null)
              _buildEstimatedDate(context),
            
            const SizedBox(height: 24),
            
            // Notify me button
            if (onNotifyMe != null)
              _buildNotifyButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMainIllustration(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPurple.withValues(alpha: 0.2),
            AppTheme.primaryRose.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background pattern
          ...List.generate(3, (index) {
            return Container(
              width: 140 - (index * 20),
              height: 140 - (index * 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.1 - index * 0.02),
                  width: 1,
                ),
              ),
            ).animate(delay: Duration(milliseconds: index * 200))
                .scale(begin: const Offset(0.8, 0.8))
                .fadeIn();
          }),
          
          // Main icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppTheme.primaryPurple, AppTheme.primaryRose],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
          ).animate()
              .scale(delay: 500.ms, duration: 800.ms)
              .shimmer(delay: 1000.ms, duration: 2000.ms),
        ],
      ),
    ).animate()
        .fadeIn(duration: 800.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildTitleSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.brightness == Brightness.dark 
                ? Colors.white 
                : AppTheme.darkGrey,
          ),
          textAlign: TextAlign.center,
        ).animate(delay: 200.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryPurple.withValues(alpha: 0.1),
                AppTheme.primaryRose.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryPurple.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            'COMING SOON',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryPurple,
              letterSpacing: 1.2,
            ),
          ),
        ).animate(delay: 400.ms)
            .fadeIn()
            .scale(begin: const Offset(0.8, 0.8)),
        
        const SizedBox(height: 20),
        
        Text(
          description,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.brightness == Brightness.dark 
                ? Colors.white70 
                : AppTheme.mediumGrey,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ).animate(delay: 600.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.1 : 0.8,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: AppTheme.primaryPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Upcoming Features',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.brightness == Brightness.dark 
                      ? Colors.white 
                      : AppTheme.darkGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...featureList!.asMap().entries.map((entry) {
            final index = entry.key;
            final feature = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryPurple, AppTheme.primaryRose],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.brightness == Brightness.dark 
                            ? Colors.white70 
                            : AppTheme.mediumGrey,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ).animate(delay: Duration(milliseconds: 800 + (index * 100)))
                  .fadeIn()
                  .slideX(begin: 0.3, end: 0),
            );
          }),
        ],
      ),
    ).animate(delay: 700.ms)
        .fadeIn()
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildEstimatedDate(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentMint.withValues(alpha: 0.1),
            AppTheme.accentMint.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppTheme.accentMint.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            color: AppTheme.accentMint,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Expected: $estimatedDate',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.accentMint,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate(delay: 1000.ms)
        .fadeIn()
        .scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildNotifyButton(BuildContext context) {
    return ModernButton(
      text: 'Notify Me When Ready',
      onPressed: onNotifyMe,
      type: ModernButtonType.secondary,
      size: ModernButtonSize.large,
      isExpanded: true,
      icon: Icons.notifications_outlined,
      borderRadius: BorderRadius.circular(25),
    ).animate(delay: 1200.ms)
        .fadeIn()
        .slideY(begin: 0.3, end: 0);
  }
}

/// Specialized Coming Soon widgets for different feature categories
class ComingSoonWidgets {
  
  /// AI Coach Coming Soon
  static Widget aiCoach(BuildContext context, {VoidCallback? onNotifyMe}) {
    return ComingSoonWidget(
      title: 'AI Health Coach',
      description: 'Get personalized insights and recommendations powered by advanced AI algorithms that learn from your cycle patterns, symptoms, and lifestyle data.',
      icon: Icons.psychology_rounded,
      featureList: [
        'Personalized health insights based on your unique patterns',
        'Smart recommendations for nutrition and exercise',
        'Predictive analytics for symptom management',
        'Integration with wearable devices and health apps',
        'Real-time coaching and support throughout your cycle',
      ],
      estimatedDate: 'Q2 2024',
      onNotifyMe: onNotifyMe,
      gradientColors: [
        AppTheme.primaryPurple.withValues(alpha: 0.1),
        AppTheme.primaryRose.withValues(alpha: 0.1),
      ],
    );
  }

  /// Partner Features Coming Soon
  static Widget partnerFeatures(BuildContext context, {VoidCallback? onNotifyMe}) {
    return ComingSoonWidget(
      title: 'Partner Integration',
      description: 'Connect with your partner to share important cycle information and get support when you need it most.',
      icon: Icons.favorite_rounded,
      featureList: [
        'Secure cycle sharing with trusted partners',
        'Partner notifications for important cycle events',
        'Mood and symptom insights for better understanding',
        'Shared calendar and reminders',
        'Partner education and resources',
      ],
      estimatedDate: 'Q3 2024',
      onNotifyMe: onNotifyMe,
    );
  }

  /// Healthcare Provider Features Coming Soon
  static Widget healthcareProvider(BuildContext context, {VoidCallback? onNotifyMe}) {
    return ComingSoonWidget(
      title: 'Healthcare Provider Portal',
      description: 'Seamlessly share your cycle data with healthcare providers for better diagnosis and treatment.',
      icon: Icons.medical_services_rounded,
      featureList: [
        'Secure data export for medical appointments',
        'Provider dashboard for tracking patient progress',
        'Integration with electronic health records',
        'Customizable reports for different conditions',
        'Telehealth consultation scheduling',
      ],
      estimatedDate: 'Q4 2024',
      onNotifyMe: onNotifyMe,
    );
  }

  /// Premium Analytics Coming Soon
  static Widget premiumAnalytics(BuildContext context, {VoidCallback? onNotifyMe}) {
    return ComingSoonWidget(
      title: 'Advanced Analytics',
      description: 'Unlock deeper insights with advanced data visualization and predictive modeling for your reproductive health.',
      icon: Icons.analytics_rounded,
      featureList: [
        'Advanced cycle pattern recognition',
        'Correlation analysis between symptoms and lifestyle',
        'Predictive modeling for cycle irregularities',
        'Fertility window optimization',
        'Long-term health trend analysis',
      ],
      estimatedDate: 'Q1 2024',
      onNotifyMe: onNotifyMe,
    );
  }
}
