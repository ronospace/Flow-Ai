import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/app_localizations.dart';
import '../services/partner_service.dart'
    show
        PartnerService,
        PartnerCareActionType;
import '../services/partner_service.dart'
    as service_types
    show PartnerMessageType;
import '../models/partner_models.dart'
    show
        Partnership,
        PartnershipStatus,
        PartnerMessage,
        PartnerMessageType,
        PartnerPrivacySettings,
        CareAction,
        CareActionType;
import '../models/partner_insight.dart';
import '../widgets/partner_cycle_insight_widget.dart';
import '../widgets/partner_communication_widget.dart';
import '../widgets/partner_care_actions_widget.dart';
import '../widgets/partner_insights_widget.dart';
import '../widgets/partner_invitation_dialog.dart';
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
                      _buildPartnershipHeader(
                        theme,
                        localizations,
                        partnerService,
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
                      _buildNoPartnerState(
                        theme,
                        localizations,
                        partnerService,
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

  Widget _buildPartnershipHeader(
    ThemeData theme,
    AppLocalizations localizations,
    PartnerService partnerService,
  ) {
    final partnership = partnerService.currentPartnership!;
    // Service Partnership doesn't have status field, so assume active if partnership exists

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
                                    colors: [
                                      AppTheme.primaryRose,
                                      AppTheme.primaryPurple,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              )
                              .animate(
                                onPlay: (controller) => controller.repeat(),
                              )
                              .shimmer(duration: 2000.ms)
                              .then(delay: 1000.ms),

                          const SizedBox(height: 8),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.warningOrange.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppTheme.warningOrange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Partner sync disabled',
                                  style: TextStyle(
                                    color: AppTheme.warningOrange,
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
        border: Border.all(color: Theme.of(context).cardColor, width: 3),
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

  Widget _buildConnectionStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
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
    // Convert service Partnership to model Partnership
    final ps = partnerService.currentPartnership!;
    final partnership = Partnership(
      id: ps.id,
      userId1: ps.primaryUserId,
      userId2: ps.partnerUserId,
      customName1: ps.primaryUserName,
      customName2: ps.partnerUserName,
      establishedAt: ps.createdAt,
      status: PartnershipStatus.active, // Assume active if partnership exists
      privacySettings: PartnerPrivacySettings(
        shareBasicCycleInfo: ps.sharingSettings.shareSymptoms,
        shareDetailedSymptoms: ps.sharingSettings.sharePhysicalSymptoms,
        shareMoodData: ps.sharingSettings.shareMoodData,
        shareEnergyLevels: true,
        sharePainData: ps.sharingSettings.sharePhysicalSymptoms,
        shareAIInsights: ps.sharingSettings.allowInsights,
        sharePredictions: ps.sharingSettings.sharePredictions,
        allowNotifications: ps.sharingSettings.sendNotifications,
        allowCareActions: true,
      ),
      lastActiveAt: ps.lastActiveAt,
    );

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
              child: _buildActionCard(action),
            );
          },
        ).animate(delay: (300 + index * 100).ms).fadeIn();
      },
    );
  }

  Widget _buildActionCard(_ActionButton action) {
    final theme = Theme.of(context);
    return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.cardColor, action.color.withValues(alpha: 0.05)],
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
                          colors: [
                            action.color,
                            action.color.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(action.icon, color: Colors.white, size: 24),
                    ),
                    const Spacer(),
                    Text(
                      action.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 3000.ms, color: action.color.withValues(alpha: 0.1))
        .then(delay: 2000.ms);
  }

  Widget _buildCommunicationCard(
    ThemeData theme,
    AppLocalizations localizations,
    PartnerService partnerService,
  ) {
    // Convert PartnerMessage from service to PartnerMessage from models
    final messages = partnerService.messages.map((pm) {
      // Map PartnerMessageType from service to PartnerMessageType from models
      PartnerMessageType type;
      switch (pm.type.name) {
        case 'text':
          type = PartnerMessageType.text;
          break;
        case 'careAction':
          type = PartnerMessageType.careAction;
          break;
        case 'insight':
          type = PartnerMessageType.supportive;
          break;
        default:
          type = PartnerMessageType.text;
      }

      return PartnerMessage(
        id: pm.id,
        partnershipId: pm.partnershipId,
        senderId: pm.senderId,
        receiverId: pm.receiverId,
        content: pm.content,
        type: type,
        createdAt: pm.sentAt, // Service uses sentAt
        readAt: pm.isRead ? pm.sentAt : null, // Service uses isRead boolean
        metadata: pm.metadata,
      );
    }).toList();

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
    // Convert PartnerInsight from service to PartnerInsight from models
    final insights = partnerService.insights.map((pi) {
      return PartnerInsight(
        id: pi.id,
        partnershipId: pi.partnershipId,
        type: PartnerInsightType.values.firstWhere(
          (e) => e.name == pi.type.name,
          orElse: () => PartnerInsightType.supportSuggestion,
        ),
        title: pi.title,
        content: pi.content,
        actionSuggestions: pi.actionSuggestions,
        generatedAt: pi.generatedAt,
        expiresAt: pi.expiresAt,
        isRead: pi.isRead,
      );
    }).toList();

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

    // Convert PartnerCareAction to CareAction for widget
    final careActions = partnerService.careActions.map((pa) {
      // Map PartnerCareActionType to CareActionType
      CareActionType type;
      switch (pa.type) {
        case PartnerCareActionType.emotionalSupport:
          type = CareActionType.support;
          break;
        case PartnerCareActionType.physicalCare:
          type = CareActionType.symptomsHelp;
          break;
        case PartnerCareActionType.thoughtfulGesture:
          type = CareActionType.gift;
          break;
        case PartnerCareActionType.other:
          type = CareActionType.checkIn;
          break;
      }

      return CareAction(
        id: pa.id,
        partnershipId: pa.partnershipId,
        senderId: pa.performedByUserId,
        receiverId: pa.forUserId,
        type: type,
        title: pa.title,
        description: pa.description,
        createdAt: pa.performedAt,
        completedAt: null,
      );
    }).toList();

    return PartnerCareActionsWidget(
      careActions: careActions.take(5).toList(),
      onSendCareAction: (careAction) async {
        // Convert CareActionType to PartnerCareActionType
        PartnerCareActionType type;
        switch (careAction.type) {
          case CareActionType.support:
            type = PartnerCareActionType.emotionalSupport;
            break;
          case CareActionType.symptomsHelp:
            type = PartnerCareActionType.physicalCare;
            break;
          case CareActionType.gift:
            type = PartnerCareActionType.thoughtfulGesture;
            break;
          default:
            type = PartnerCareActionType.other;
        }

        await partnerService.sendCareAction(
          type: type,
          title: careAction.title,
          description: careAction.description,
        );
      },
      currentUserId: currentUserId,
      partnershipId: partnerService.currentPartnership?.id ?? '',
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildNoPartnerState(
    ThemeData theme,
    AppLocalizations localizations,
    PartnerService partnerService,
  ) {
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
                    colors: [
                      AppTheme.primaryRose.withValues(alpha: 0.1),
                      AppTheme.primaryPurple.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.favorite_border,
                  size: 60,
                  color: AppTheme.primaryRose,
                ),
              )
              .animate()
              .scale(begin: const Offset(0.5, 0.5))
              .fadeIn(duration: 800.ms),

          const SizedBox(height: 32),

          Text(
            'Connect with Your Partner',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 16),

          Text(
            'Share your cycle journey together.\nGet support, insights, and stay connected.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 40),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showPartnerInvitationDialog(context, partnerService),
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
  void _showPartnerInvitationDialog(
    BuildContext context,
    PartnerService partnerService,
  ) {
    showDialog(
      context: context,
      useRootNavigator: true,
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
