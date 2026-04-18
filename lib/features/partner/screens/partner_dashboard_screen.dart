import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/app_localizations.dart';
import '../services/partner_service.dart'
    show
        PartnerService;
import '../services/partner_service.dart'
    as service_types
    show PartnerMessageType;
import '../widgets/partner_cycle_insight_widget.dart';
import '../widgets/partner_communication_widget.dart';
import '../widgets/partner_care_actions_widget.dart';
import '../widgets/partner_insights_widget.dart';
import '../widgets/partner_invitation_dialog.dart';
import '../widgets/partner_dashboard_header.dart';
import '../widgets/partner_empty_state.dart';
import '../widgets/partner_quick_action_card.dart';
import '../mappers/partner_dashboard_mapper.dart';
import '../dialogs/join_partner_dialog.dart';

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
    final localizations = AppLocalizations.of(context);

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
                      PartnerDashboardHeader(
                        animation: _contentAnimation,
                        primaryUserName: partnerService.currentPartnership!.primaryUserName,
                        partnerUserName: partnerService.currentPartnership!.partnerUserName,
                        createdAt: partnerService.currentPartnership!.createdAt,
                        messageCount: partnerService.messages.length,
                        careActionCount: partnerService.careActions.length,
                      ),
                      const SizedBox(height: 24),

                      _buildCycleInsightCard(
                        theme,
                        localizations,
                        partnerService,
                      ),
                      const SizedBox(height: 20),

                      _buildQuickActionsGrid(
                        theme,
                        localizations,
                        partnerService,
                      ),
                      const SizedBox(height: 20),

                      _buildCommunicationCard(
                        theme,
                        localizations,
                        partnerService,
                      ),
                      const SizedBox(height: 20),

                      _buildPartnerInsightsCard(
                        theme,
                        localizations,
                        partnerService,
                      ),
                      const SizedBox(height: 20),

                      _buildCareHistoryCard(
                        theme,
                        localizations,
                        partnerService,
                      ),
                    ] else ...[
                      PartnerEmptyState(
                        theme: theme,
                        onInvite: () => _showPartnerInvitationDialog(context, partnerService),
                        onJoin: () => _showJoinPartnerDialog(context, partnerService),
                      ),
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

  Widget _buildAnimatedAppBar(
    ThemeData theme,
    AppLocalizations localizations,
    PartnerService partnerService,
  ) {
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
                  partnerService.hasPartner
                      ? 'Partner Connection'
                      : 'Connect with Partner',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
      ],
    );
  }

  Widget _buildCycleInsightCard(
    ThemeData theme,
    AppLocalizations localizations,
    PartnerService partnerService,
  ) {
    final ps = partnerService.currentPartnership!;
    final partnership = PartnerDashboardMapper.toPartnership(ps);

    return PartnerCycleInsightWidget(
      partnership: partnership,
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildQuickActionsGrid(
    ThemeData theme,
    AppLocalizations localizations,
    PartnerService partnerService,
  ) {
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
              child: PartnerQuickActionCard(
                title: action.title,
                subtitle: action.subtitle,
                icon: action.icon,
                color: action.color,
                onTap: action.onTap,
              ),
            );
          },
        ).animate(delay: (300 + index * 100).ms).fadeIn();
      },
    );
  }

  Widget _buildCommunicationCard(
    ThemeData theme,
    AppLocalizations localizations,
    PartnerService partnerService,
  ) {
    final messages = partnerService.messages
        .map(PartnerDashboardMapper.toPartnerMessage)
        .toList();

    return PartnerCommunicationWidget(
      messages: messages.take(3).toList(),
      onSendMessage: (message) => partnerService.sendMessage(
        content: message,
        type: service_types.PartnerMessageType.text,
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildPartnerInsightsCard(
    ThemeData theme,
    AppLocalizations localizations,
    PartnerService partnerService,
  ) {
    final insights = partnerService.insights
        .map(PartnerDashboardMapper.toPartnerInsight)
        .toList();

    return PartnerInsightsWidget(
      insights: insights,
    ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildCareHistoryCard(
    ThemeData theme,
    AppLocalizations localizations,
    PartnerService partnerService,
  ) {
    // Get current user ID from partnership
    final partnership = partnerService.currentPartnership;
    if (partnership == null) {
      return const SizedBox.shrink();
    }

    // Try to determine current user ID from LocalUserService synchronously via stored value
    // For now, use a placeholder - will be set correctly by the service
    // Service Partnership uses primaryUserId/partnerUserId, not userId1/userId2
    final currentUserId = partnership
        .primaryUserId; // Service will handle determining the correct user

    final careActions = partnerService.careActions
        .map(PartnerDashboardMapper.toCareAction)
        .toList();

    return PartnerCareActionsWidget(
      careActions: careActions.take(5).toList(),
      onSendCareAction: (careAction) async {
        await partnerService.sendCareAction(
          type: PartnerDashboardMapper.toPartnerCareActionType(
            careAction.type,
          ),
          title: careAction.title,
          description: careAction.description,
        );
      },
      currentUserId: currentUserId,
      partnershipId: partnerService.currentPartnership?.id ?? '',
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0);
  }

  // Dialog methods

  // Dialog methods
  void _showPartnerInvitationDialog(
    BuildContext context,
    PartnerService partnerService,
  ) {
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierColor: Colors.black.withValues(alpha: 0.06),
      builder: (context) =>
          PartnerInvitationDialog(partnerService: partnerService),
    );
  }

  void _showJoinPartnerDialog(
    BuildContext context,
    PartnerService partnerService,
  ) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => JoinPartnerDialog(
        onJoinWithCode: (code) async {
          final partnership = await partnerService.acceptPartnerInvitation(
            code,
          );
          if (partnership != null && context.mounted) {
            Navigator.of(context, rootNavigator: true).pop(); 
            Future.microtask(() {
              if (context.mounted) context.go('/partner-dashboard');
            });
          }
        },
      ),
    );
  }

  void _showMessageDialog(BuildContext context, PartnerService partnerService) {
    // Implementation for message dialog - can be enhanced later
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        title: const Text('Send Message'),
        content: const Text('Message feature coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCareActionsDialog(
    BuildContext context,
    PartnerService partnerService,
  ) {
    // Implementation for care actions dialog
  }

  void _showPartnerSettings(
    BuildContext context,
    PartnerService partnerService,
  ) {
    // Implementation for partner settings
  }

  void _sendMoodCheckIn(PartnerService partnerService) {
    partnerService.sendMessage(
      content: "How are you feeling today? 💕",
      type: service_types.PartnerMessageType.text,
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
