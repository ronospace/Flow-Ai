import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/gamification_controller.dart';
import '../widgets/daily_streak_widget.dart';
import '../widgets/achievement_badges_widget.dart';
import '../widgets/wellness_challenges_widget.dart';
import '../widgets/leaderboard_widget.dart';
import '../widgets/educational_content_widget.dart';
import '../widgets/progress_overview_widget.dart';
import '../widgets/reward_center_widget.dart';
import '../../../core/ui/adaptive_components.dart';
import '../../../core/theme/app_theme.dart';

/// 🏆 Gamification Dashboard Screen - Week 4 Implementation
/// Features: Daily check-in streaks, health achievement badges, monthly wellness challenges,
/// community leaderboards, educational elements, and viral growth mechanics
class GamificationDashboardScreen extends StatefulWidget {
  const GamificationDashboardScreen({super.key});

  @override
  State<GamificationDashboardScreen> createState() => _GamificationDashboardScreenState();
}

class _GamificationDashboardScreenState extends State<GamificationDashboardScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _heroAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _heroAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadGamificationData();
  }

  void _initializeAnimations() {
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heroAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroAnimationController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _heroAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _contentAnimationController.forward();
    });
  }

  Future<void> _loadGamificationData() async {
    final controller = context.read<GamificationController>();
    await controller.loadGamificationData();
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Consumer<GamificationController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: RefreshIndicator(
            onRefresh: () => controller.refresh(),
            child: CustomScrollView(
              slivers: [
                _buildHeroSection(context, controller),
                _buildContentSections(context, controller),
              ],
            ),
          ),
        );
      },
    );
  }

  SliverAppBar _buildHeroSection(BuildContext context, GamificationController controller) {
    final theme = Theme.of(context);
    
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: AnimatedBuilder(
          animation: _heroAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _heroAnimation.value,
              child: Text(
                'Your Wellness Journey 🌟',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
                theme.colorScheme.tertiary,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  
                  // Progress Overview
                  AnimatedBuilder(
                    animation: _heroAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _heroAnimation.value,
                        child: ProgressOverviewWidget(
                          userLevel: controller.userLevel,
                          currentXP: controller.currentXP,
                          nextLevelXP: controller.nextLevelXP,
                          totalPoints: controller.totalPoints,
                          weeklyProgress: controller.weeklyProgress,
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Quick stats row
                  AnimatedBuilder(
                    animation: _heroAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _heroAnimation.value,
                        child: _buildQuickStats(context, controller),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.emoji_events,
            color: theme.colorScheme.onPrimary,
          ),
          onPressed: () => _showRewardCenter(context, controller),
        ),
        
        IconButton(
          icon: Icon(
            Icons.leaderboard,
            color: theme.colorScheme.onPrimary,
          ),
          onPressed: () => _showGlobalLeaderboard(context, controller),
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context, GamificationController controller) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.local_fire_department,
            title: '${controller.currentStreak}',
            subtitle: 'Day Streak',
            color: Colors.orange,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.emoji_events,
            title: '${controller.unlockedAchievements}',
            subtitle: 'Achievements',
            color: Colors.yellow,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.trending_up,
            title: '#${controller.leaderboardRank}',
            subtitle: 'Ranking',
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          
          const SizedBox(height: 4),
          
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  SliverList _buildContentSections(BuildContext context, GamificationController controller) {
    return SliverList(
      delegate: SliverChildListDelegate([
        SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Daily Streak Section
                _buildSectionHeader(
                  context,
                  title: 'Daily Streak',
                  subtitle: 'Keep your wellness momentum going!',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
                
                const SizedBox(height: 16),
                
                DailyStreakWidget(
                  currentStreak: controller.currentStreak,
                  longestStreak: controller.longestStreak,
                  streakHistory: controller.streakHistory,
                  onCheckIn: controller.performDailyCheckIn,
                  canCheckInToday: controller.canCheckInToday,
                ),
                
                const SizedBox(height: 32),
                
                // Achievement Badges Section
                _buildSectionHeader(
                  context,
                  title: 'Achievement Badges',
                  subtitle: 'Unlock badges as you progress',
                  icon: Icons.military_tech,
                  color: Colors.purple,
                ),
                
                const SizedBox(height: 16),
                
                AchievementBadgesWidget(
                  achievements: controller.achievements,
                  onClaimAchievement: controller.claimAchievement,
                  onShareAchievement: controller.shareAchievement,
                ),
                
                const SizedBox(height: 32),
                
                // Wellness Challenges Section
                _buildSectionHeader(
                  context,
                  title: 'Wellness Challenges',
                  subtitle: 'Take on monthly health challenges',
                  icon: Icons.fitness_center,
                  color: Colors.green,
                ),
                
                const SizedBox(height: 16),
                
                WellnessChallengesWidget(
                  challenges: controller.activeChallenges,
                  completedChallenges: controller.completedChallenges,
                  onJoinChallenge: controller.joinChallenge,
                  onCompleteChallenge: controller.completeChallenge,
                ),
                
                const SizedBox(height: 32),
                
                // Community Leaderboard Section
                _buildSectionHeader(
                  context,
                  title: 'Community Leaderboard',
                  subtitle: 'See how you rank among friends',
                  icon: Icons.leaderboard,
                  color: Colors.blue,
                ),
                
                const SizedBox(height: 16),
                
                LeaderboardWidget(
                  leaderboard: controller.friendsLeaderboard,
                  userRank: controller.leaderboardRank,
                  onViewGlobalLeaderboard: () => _showGlobalLeaderboard(context, controller),
                  onInviteFriends: () => _inviteFriends(context, controller),
                ),
                
                const SizedBox(height: 32),
                
                // Educational Content Section
                _buildSectionHeader(
                  context,
                  title: 'Learn & Grow',
                  subtitle: 'Educational content to boost your health knowledge',
                  icon: Icons.school,
                  color: Colors.teal,
                ),
                
                const SizedBox(height: 16),
                
                EducationalContentWidget(
                  dailyTip: controller.dailyHealthTip,
                  articles: controller.educationalArticles,
                  quizzes: controller.healthQuizzes,
                  onCompleteQuiz: controller.completeQuiz,
                  onReadArticle: controller.markArticleAsRead,
                ),
                
                const SizedBox(height: 32),
                
                // Reward Center Preview
                _buildRewardCenterPreview(context, controller),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRewardCenterPreview(BuildContext context, GamificationController controller) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.tertiary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.card_giftcard,
                color: theme.colorScheme.tertiary,
                size: 32,
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reward Center',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    Text(
                      'You have ${controller.totalPoints} points to spend!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              AdaptiveButton(
                text: 'View Rewards',
                onPressed: () => _showRewardCenter(context, controller),
                isPrimary: true,
                isCompact: true,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Featured rewards preview
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.featuredRewards.take(3).map((reward) => Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      reward.icon,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      reward.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      '${reward.cost} pts',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showRewardCenter(BuildContext context, GamificationController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: RewardCenterWidget(
            scrollController: scrollController,
            rewards: controller.availableRewards,
            userPoints: controller.totalPoints,
            onPurchaseReward: controller.purchaseReward,
          ),
        ),
      ),
    );
  }

  void _showGlobalLeaderboard(BuildContext context, GamificationController controller) {
    Navigator.pushNamed(
      context,
      '/gamification/global-leaderboard',
      arguments: controller.globalLeaderboard,
    );
  }

  void _inviteFriends(BuildContext context, GamificationController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Friends'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Invite your friends to join ZyraFlow and compete together!'),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '🎁 Both you and your friend get 100 bonus points when they join!',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          AdaptiveButton(
            text: 'Share Invite',
            onPressed: () {
              Navigator.pop(context);
              controller.shareInviteLink();
            },
            isPrimary: true,
            isCompact: true,
          ),
        ],
      ),
    );
  }
}
