import 'package:flutter/material.dart';

/// 🔐 Privacy Preferences Widget - Comprehensive Privacy Control System
/// Features: Granular privacy settings, data sharing preferences, AI consent,
/// anonymization options, and transparent data usage explanations
class PrivacyPreferencesWidget extends StatefulWidget {
  final Function(bool shareForResearch, bool enableAI) onPrivacyChanged;
  final bool initialShareForResearch;
  final bool initialEnableAI;

  const PrivacyPreferencesWidget({
    super.key,
    required this.onPrivacyChanged,
    required this.initialShareForResearch,
    required this.initialEnableAI,
  });

  @override
  State<PrivacyPreferencesWidget> createState() => _PrivacyPreferencesWidgetState();
}

class _PrivacyPreferencesWidgetState extends State<PrivacyPreferencesWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _shareDataForResearch = false;
  bool _enableAIInsights = true;
  bool _allowAnonymousAnalytics = true;
  bool _enableCloudBackup = true;
  bool _shareWithPartners = false;
  bool _marketingCommunications = false;

  final List<Map<String, dynamic>> _privacyOptions = [
    {
      'id': 'ai_insights',
      'title': 'AI-Powered Insights',
      'subtitle': 'Enable personalized AI recommendations and predictions',
      'description': 'Uses your data locally and securely to provide smart insights about your cycle, symptoms, and health patterns. No personal data leaves your device.',
      'icon': Icons.psychology,
      'color': Colors.purple,
      'recommended': true,
      'defaultValue': true,
    },
    {
      'id': 'anonymous_research',
      'title': 'Anonymous Research Participation',
      'subtitle': 'Help improve women\'s health research',
      'description': 'Contribute anonymized, aggregated data to scientific research that helps advance understanding of women\'s health. Your identity remains completely protected.',
      'icon': Icons.science,
      'color': Colors.blue,
      'recommended': true,
      'defaultValue': false,
    },
    {
      'id': 'analytics',
      'title': 'Anonymous App Analytics',
      'subtitle': 'Help us improve the app experience',
      'description': 'Shares anonymized usage patterns to help us understand how to make the app better. No personal health data is included.',
      'icon': Icons.analytics,
      'color': Colors.green,
      'recommended': true,
      'defaultValue': true,
    },
    {
      'id': 'cloud_backup',
      'title': 'Secure Cloud Backup',
      'subtitle': 'Keep your data safe and synced across devices',
      'description': 'Encrypts and backs up your data to secure cloud storage. You can always disable this and keep data local only.',
      'icon': Icons.cloud_queue,
      'color': Colors.cyan,
      'recommended': true,
      'defaultValue': true,
    },
    {
      'id': 'partner_sharing',
      'title': 'Trusted Partner Data Sharing',
      'subtitle': 'Share anonymized insights with healthcare partners',
      'description': 'Allows sharing of anonymized health trends with trusted healthcare organizations and researchers to improve women\'s health outcomes.',
      'icon': Icons.handshake,
      'color': Colors.orange,
      'recommended': false,
      'defaultValue': false,
    },
    {
      'id': 'marketing',
      'title': 'Personalized Communications',
      'subtitle': 'Receive health tips and app updates',
      'description': 'Get personalized health content, tips, and important app updates via email or notifications. You can unsubscribe anytime.',
      'icon': Icons.email,
      'color': Colors.pink,
      'recommended': false,
      'defaultValue': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInitialData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  void _loadInitialData() {
    setState(() {
      _shareDataForResearch = widget.initialShareForResearch;
      _enableAIInsights = widget.initialEnableAI;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _notifyPrivacyChanged() {
    widget.onPrivacyChanged(_shareDataForResearch, _enableAIInsights);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildPrivacyPromise(context),
              const SizedBox(height: 32),
              _buildPrivacyOptions(context),
              const SizedBox(height: 32),
              _buildDataRightsSection(context),
              const SizedBox(height: 32),
              _buildSecurityFeatures(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.security,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: Text(
                'Your Privacy, Your Choice 🔐',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'You have complete control over your data. Choose what you\'re comfortable sharing to help us provide the best possible experience while keeping your privacy protected.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyPromise(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.05),
            theme.colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.shield,
            color: theme.colorScheme.primary,
            size: 48,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Our Privacy Promise',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            '• Your health data never leaves your device without your explicit consent\n'
            '• All data is encrypted using industry-leading security standards\n'
            '• You can delete your data completely at any time\n'
            '• We never sell your personal information to third parties\n'
            '• Anonymous research contributions help improve women\'s health globally',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        ...(_privacyOptions.map((option) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildPrivacyOptionCard(context, option),
        ))),
      ],
    );
  }

  Widget _buildPrivacyOptionCard(BuildContext context, Map<String, dynamic> option) {
    final theme = Theme.of(context);
    bool currentValue;
    
    switch (option['id']) {
      case 'ai_insights':
        currentValue = _enableAIInsights;
        break;
      case 'anonymous_research':
        currentValue = _shareDataForResearch;
        break;
      case 'analytics':
        currentValue = _allowAnonymousAnalytics;
        break;
      case 'cloud_backup':
        currentValue = _enableCloudBackup;
        break;
      case 'partner_sharing':
        currentValue = _shareWithPartners;
        break;
      case 'marketing':
        currentValue = _marketingCommunications;
        break;
      default:
        currentValue = false;
    }
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleOption(option['id']),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (option['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        option['icon'],
                        color: option['color'],
                        size: 24,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option['title'],
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              
                              if (option['recommended'] == true) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Recommended',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          
                          const SizedBox(height: 4),
                          
                          Text(
                            option['subtitle'],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Switch.adaptive(
                      value: currentValue,
                      onChanged: (_) => _toggleOption(option['id']),
                      activeColor: theme.colorScheme.primary,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    option['description'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataRightsSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.gavel,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              
              const SizedBox(width: 12),
              
              Text(
                'Your Data Rights',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildDataRightItem(
            context,
            icon: Icons.download,
            title: 'Data Export',
            description: 'Download all your data in a portable format anytime',
          ),
          
          const SizedBox(height: 12),
          
          _buildDataRightItem(
            context,
            icon: Icons.edit,
            title: 'Data Correction',
            description: 'Request corrections to any inaccurate data',
          ),
          
          const SizedBox(height: 12),
          
          _buildDataRightItem(
            context,
            icon: Icons.delete_forever,
            title: 'Data Deletion',
            description: 'Permanently delete all your data from our systems',
          ),
          
          const SizedBox(height: 12),
          
          _buildDataRightItem(
            context,
            icon: Icons.visibility,
            title: 'Data Transparency',
            description: 'See exactly what data we collect and how it\'s used',
          ),
        ],
      ),
    );
  }

  Widget _buildDataRightItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary.withValues(alpha: 0.7),
          size: 18,
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityFeatures(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                color: Colors.green,
                size: 24,
              ),
              
              const SizedBox(width: 12),
              
              Text(
                'Security Features',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildSecurityFeature(
                  context,
                  icon: Icons.lock,
                  title: 'End-to-End Encryption',
                  subtitle: 'Military-grade security',
                ),
              ),
              
              Expanded(
                child: _buildSecurityFeature(
                  context,
                  icon: Icons.fingerprint,
                  title: 'Biometric Lock',
                  subtitle: 'Face ID / Touch ID',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildSecurityFeature(
                  context,
                  icon: Icons.shield,
                  title: 'Zero-Knowledge',
                  subtitle: 'We can\'t see your data',
                ),
              ),
              
              Expanded(
                child: _buildSecurityFeature(
                  context,
                  icon: Icons.verified_user,
                  title: 'HIPAA Compliant',
                  subtitle: 'Healthcare standards',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFeature(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.green,
          size: 32,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 4),
        
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _toggleOption(String optionId) {
    setState(() {
      switch (optionId) {
        case 'ai_insights':
          _enableAIInsights = !_enableAIInsights;
          break;
        case 'anonymous_research':
          _shareDataForResearch = !_shareDataForResearch;
          break;
        case 'analytics':
          _allowAnonymousAnalytics = !_allowAnonymousAnalytics;
          break;
        case 'cloud_backup':
          _enableCloudBackup = !_enableCloudBackup;
          break;
        case 'partner_sharing':
          _shareWithPartners = !_shareWithPartners;
          break;
        case 'marketing':
          _marketingCommunications = !_marketingCommunications;
          break;
      }
    });
    
    _notifyPrivacyChanged();
  }
}
