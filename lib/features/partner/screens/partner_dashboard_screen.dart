import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/app_localizations.dart';
import '../services/partner_service.dart';
import '../models/partner_models.dart';
import '../widgets/partner_cycle_insight_widget.dart';
import '../widgets/partner_communication_widget.dart';
import '../widgets/partner_care_actions_widget.dart';
import '../widgets/partner_insights_widget.dart';
import 'package:shimmer/shimmer.dart';

class PartnerDashboardScreen extends StatefulWidget {
  const PartnerDashboardScreen({super.key});

  @override
  State<PartnerDashboardScreen> createState() => _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends State<PartnerDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    );
    
    _contentAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeInOut,
    );

    // Start animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _contentController.forward();
    });
    
    // Initialize partner service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PartnerService>().initialize();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Consumer<PartnerService>(
        builder: (context, partnerService, child) {
          return CustomScrollView(
            slivers: [
              _buildAnimatedAppBar(theme, localizations, partnerService),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (partnerService.hasPartner) ...[
                      _buildPartnershipHeader(theme, localizations, partnerService),
                      const SizedBox(height: 24),
                      
                      _buildCycleInsightCard(theme, localizations, partnerService),
                      const SizedBox(height: 20),
                      
                      _buildQuickActionsGrid(theme, localizations, partnerService),
                      const SizedBox(height: 20),
                      
                      _buildCommunicationCard(theme, localizations, partnerService),
                      const SizedBox(height: 20),
                      
                      _buildPartnerInsightsCard(theme, localizations, partnerService),
                      const SizedBox(height: 20),
                      
                      _buildCareHistoryCard(theme, localizations, partnerService),
                    ] else ...[
                      _buildNoPartnerState(theme, localizations, partnerService),
                    ],
                    
                    const SizedBox(height: 100), // Space for bottom navigation
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedAppBar(ThemeData theme, AppLocalizations localizations, PartnerService partnerService) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: AnimatedBuilder(
        animation: _headerAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, (1 - _headerAnimation.value) * -50),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryRose.withValues(alpha: 0.1),
                    AppTheme.primaryPurple.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                title: Text(
                  partnerService.hasPartner ? 'Partner Connection' : 'Connect with Partner',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  ),
                ),
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 16),
              ),
            ),
          );
        },
      ),
      actions: [
        if (partnerService.hasPartner)
          IconButton(
            onPressed: () => _showPartnerSettings(context, partnerService),
            icon: Icon(
              Icons.settings,
              color: AppTheme.mediumGrey,
            ),
          ),
      ],
    );
  }

  Widget _buildPartnershipHeader(ThemeData theme, AppLocalizations localizations, PartnerService partnerService) {
    final partnership = partnerService.currentPartnership!;
    final isConnected = partnership.status == PartnershipStatus.active;
    
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_contentAnimation.value * 0.2),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryRose.withValues(alpha: 0.1),
                  AppTheme.primaryPurple.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.primaryRose.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildPartnerAvatar(partnership.primaryUserName, true),
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ).animate(onPlay: (controller) => controller.repeat())
                            .shimmer(duration: 2000.ms)
                            .then(delay: 1000.ms),
                          
                          const SizedBox(height: 8),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isConnected ? AppTheme.successGreen.withValues(alpha: 0.1) : AppTheme.warningOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isConnected ? AppTheme.successGreen : AppTheme.warningOrange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isConnected ? 'Connected' : 'Reconnecting',
                                  style: TextStyle(
                                    color: isConnected ? AppTheme.successGreen : AppTheme.warningOrange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    _buildPartnerAvatar(partnership.partnerUserName, false),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildConnectionStat(
                      'Days Connected', 
                      '${DateTime.now().difference(partnership.createdAt).inDays}',
                      Icons.favorite,
                      AppTheme.primaryRose,
                    ),
                    _buildConnectionStat(
                      'Messages', 
                      '${partnerService.messages.length}',
                      Icons.chat,
                      AppTheme.secondaryBlue,
                    ),
                    _buildConnectionStat(
                      'Care Actions', 
                      '${partnerService.careActions.length}',
                      Icons.healing,
                      AppTheme.accentMint,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPartnerAvatar(String name, bool isPrimary) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPrimary 
            ? [AppTheme.primaryRose, AppTheme.primaryPurple]
            : [AppTheme.secondaryBlue, AppTheme.accentMint],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.mediumGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildCycleInsightCard(ThemeData theme, AppLocalizations localizations, PartnerService partnerService) {
    return PartnerCycleInsightWidget(
      partnership: partnerService.currentPartnership!,
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildQuickActionsGrid(ThemeData theme, AppLocalizations localizations, PartnerService partnerService) {
    final actions = [
      _ActionButton(
        title: 'Send Message',
        subtitle: 'Chat with partner',
        icon: Icons.chat_bubble,
        color: AppTheme.primaryRose,
        onTap: () => _showMessageDialog(context, partnerService),
      ),
      _ActionButton(
        title: 'Care Actions',
        subtitle: 'Show support',
        icon: Icons.favorite,
        color: AppTheme.secondaryBlue,
        onTap: () => _showCareActionsDialog(context, partnerService),
      ),
      _ActionButton(
        title: 'Mood Check',
        subtitle: 'Check their mood',
        icon: Icons.psychology,
        color: AppTheme.accentMint,
        onTap: () => _sendMoodCheckIn(partnerService),
      ),
      _ActionButton(
        title: 'Settings',
        subtitle: 'Privacy & sharing',
        icon: Icons.settings,
        color: AppTheme.warningOrange,
        onTap: () => _showPartnerSettings(context, partnerService),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return AnimatedBuilder(
          animation: _contentAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, (1 - _contentAnimation.value) * 50),
              child: _buildActionCard(action),
            );
          },
        ).animate(delay: (300 + index * 100).ms).fadeIn();
      },
    );
  }

  Widget _buildActionCard(_ActionButton action) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            action.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: action.color.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: action.color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: action.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [action.color, action.color.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    action.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Text(
                  action.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  action.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
      .shimmer(duration: 3000.ms, color: action.color.withValues(alpha: 0.1))
      .then(delay: 2000.ms);
  }

  Widget _buildCommunicationCard(ThemeData theme, AppLocalizations localizations, PartnerService partnerService) {
    return PartnerCommunicationWidget(
      messages: partnerService.messages.take(3).toList(),
      onSendMessage: (message) => partnerService.sendMessage(content: message),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildPartnerInsightsCard(ThemeData theme, AppLocalizations localizations, PartnerService partnerService) {
    return PartnerInsightsWidget(
      insights: partnerService.insights,
    ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildCareHistoryCard(ThemeData theme, AppLocalizations localizations, PartnerService partnerService) {
    return PartnerCareActionsWidget(
      careActions: partnerService.careActions.take(5).toList(),
      onCareAction: (type, title, description) => partnerService.sendCareAction(
        type: type,
        title: title,
        description: description,
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildNoPartnerState(ThemeData theme, AppLocalizations localizations, PartnerService partnerService) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryRose.withValues(alpha: 0.1), AppTheme.primaryPurple.withValues(alpha: 0.1)],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.favorite_border,
              size: 60,
              color: AppTheme.primaryRose,
            ),
          ).animate().scale(begin: const Offset(0.5, 0.5)).fadeIn(duration: 800.ms),
          
          const SizedBox(height: 32),
          
          Text(
            'Connect with Your Partner',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGrey,
            ),
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 16),
          
          Text(
            'Share your cycle journey together.\nGet support, insights, and stay connected.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.mediumGrey,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 400.ms),
          
          const SizedBox(height: 40),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showInvitePartnerDialog(context, partnerService),
                  icon: const Icon(Icons.send),
                  label: const Text('Invite Partner'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRose,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showJoinPartnerDialog(context, partnerService),
                  icon: const Icon(Icons.link),
                  label: const Text('Join Partner'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryRose,
                    side: BorderSide(color: AppTheme.primaryRose),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  // Dialog methods
  void _showInvitePartnerDialog(BuildContext context, PartnerService partnerService) {
    // Implementation for invite partner dialog
  }

  void _showJoinPartnerDialog(BuildContext context, PartnerService partnerService) {
    // Implementation for join partner dialog
  }

  void _showMessageDialog(BuildContext context, PartnerService partnerService) {
    // Implementation for message dialog
  }

  void _showCareActionsDialog(BuildContext context, PartnerService partnerService) {
    // Implementation for care actions dialog
  }

  void _showPartnerSettings(BuildContext context, PartnerService partnerService) {
    // Implementation for partner settings
  }

  void _sendMoodCheckIn(PartnerService partnerService) {
    partnerService.sendMessage(
      content: "How are you feeling today? 💕",
      type: PartnerMessageType.moodCheckIn,
    );
  }
}

class _ActionButton {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _ActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
