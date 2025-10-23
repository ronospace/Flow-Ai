import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/community_controller.dart';
import '../widgets/discussion_board_widget.dart';
import '../widgets/expert_qa_widget.dart';
import '../widgets/cycle_buddy_widget.dart';
import '../widgets/symptom_sharing_widget.dart';
import '../widgets/community_achievements_widget.dart';
import '../widgets/community_stats_widget.dart';

/// 🌍 Community Hub Screen - Week 3 Implementation
/// Features: Anonymous discussion boards, expert Q&A system, cycle buddy matching,
/// symptom experience sharing, community achievement system, and social engagement tools
class CommunityHubScreen extends StatefulWidget {
  const CommunityHubScreen({super.key});

  @override
  State<CommunityHubScreen> createState() => _CommunityHubScreenState();
}

class _CommunityHubScreenState extends State<CommunityHubScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _communityTabs = [
    {
      'id': 'discussions',
      'title': 'Discussions',
      'icon': Icons.forum,
      'badge': 12,
    },
    {
      'id': 'expert_qa',
      'title': 'Expert Q&A',
      'icon': Icons.psychology,
      'badge': 3,
    },
    {
      'id': 'cycle_buddies',
      'title': 'Cycle Buddies',
      'icon': Icons.people,
      'badge': 0,
    },
    {
      'id': 'symptoms',
      'title': 'Symptom Stories',
      'icon': Icons.healing,
      'badge': 7,
    },
    {
      'id': 'achievements',
      'title': 'Achievements',
      'icon': Icons.emoji_events,
      'badge': 2,
    },
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadCommunityData();
  }

  void _initializeControllers() {
    _tabController = TabController(
      length: _communityTabs.length,
      vsync: this,
    );

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

    _animationController.forward();
  }

  Future<void> _loadCommunityData() async {
    final controller = context.read<CommunityController>();
    await controller.loadCommunityData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Consumer<CommunityController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  _buildSliverAppBar(context, controller),
                  _buildSliverTabBar(context),
                ];
              },
              body: _buildTabBarView(context, controller),
            ),
          ),
          floatingActionButton: _buildFloatingActionButton(context, controller),
        );
      },
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, CommunityController controller) {
    final theme = Theme.of(context);
    
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'ZyraFlow Community',
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    'Connect, Share & Learn Together 🌸',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'A supportive community for your health journey',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CommunityStatsWidget(stats: controller.communityStats),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications,
            color: theme.colorScheme.onPrimary,
          ),
          onPressed: () => _showNotifications(context),
        ),
        
        IconButton(
          icon: Icon(
            Icons.search,
            color: theme.colorScheme.onPrimary,
          ),
          onPressed: () => _showSearch(context),
        ),
      ],
    );
  }

  SliverPersistentHeader _buildSliverTabBar(BuildContext context) {
    return SliverPersistentHeader(
      delegate: _SliverTabBarDelegate(
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          tabs: _communityTabs.map((tab) => _buildTab(context, tab)).toList(),
        ),
      ),
      pinned: true,
    );
  }

  Tab _buildTab(BuildContext context, Map<String, dynamic> tab) {
    final theme = Theme.of(context);
    
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tab['icon'], size: 20),
          
          const SizedBox(width: 8),
          
          Text(tab['title']),
          
          if (tab['badge'] > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${tab['badge']}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onError,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabBarView(BuildContext context, CommunityController controller) {
    return TabBarView(
      controller: _tabController,
      children: [
        // Discussions Tab
        DiscussionBoardWidget(
          discussions: controller.discussions,
          onCreateDiscussion: controller.createDiscussion,
          onJoinDiscussion: controller.joinDiscussion,
          onLikePost: controller.likePost,
          onReportPost: controller.reportPost,
        ),
        
        // Expert Q&A Tab
        ExpertQAWidget(
          questions: controller.expertQuestions,
          experts: controller.experts,
          onAskQuestion: controller.askExpertQuestion,
          onAnswerQuestion: controller.answerQuestion,
          onUpvoteAnswer: controller.upvoteAnswer,
          onBookmarkAnswer: controller.bookmarkAnswer,
        ),
        
        // Cycle Buddies Tab
        CycleBuddyWidget(
          matches: controller.cycleBuddies,
          pendingRequests: controller.pendingBuddyRequests,
          onFindBuddies: controller.findCycleBuddies,
          onSendRequest: controller.sendBuddyRequest,
          onAcceptRequest: controller.acceptBuddyRequest,
          onDeclineRequest: controller.declineBuddyRequest,
        ),
        
        // Symptom Stories Tab
        SymptomSharingWidget(
          stories: controller.symptomStories,
          categories: controller.symptomCategories,
          onShareStory: controller.shareSymptomStory,
          onReactToStory: controller.reactToStory,
          onFollowStory: controller.followStory,
        ),
        
        // Achievements Tab
        CommunityAchievementsWidget(
          achievements: controller.communityAchievements,
          userProgress: controller.userAchievementProgress,
          leaderboard: controller.achievementLeaderboard,
          onClaimAchievement: controller.claimAchievement,
          onShareAchievement: controller.shareAchievement,
        ),
      ],
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context, CommunityController controller) {
    final currentIndex = _tabController.index;
    
    switch (currentIndex) {
      case 0: // Discussions
        return FloatingActionButton.extended(
          onPressed: () => _createNewDiscussion(context, controller),
          icon: const Icon(Icons.add),
          label: const Text('New Discussion'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        );
      
      case 1: // Expert Q&A
        return FloatingActionButton.extended(
          onPressed: () => _askExpertQuestion(context, controller),
          icon: const Icon(Icons.help),
          label: const Text('Ask Expert'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        );
      
      case 2: // Cycle Buddies
        return FloatingActionButton.extended(
          onPressed: () => _findCycleBuddies(context, controller),
          icon: const Icon(Icons.person_search),
          label: const Text('Find Buddies'),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        );
      
      case 3: // Symptom Stories
        return FloatingActionButton.extended(
          onPressed: () => _shareSymptomStory(context, controller),
          icon: const Icon(Icons.share),
          label: const Text('Share Story'),
          backgroundColor: Colors.purple,
        );
      
      default:
        return null;
    }
  }

  void _createNewDiscussion(BuildContext context, CommunityController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: _buildCreateDiscussionForm(context, controller, scrollController),
        ),
      ),
    );
  }

  Widget _buildCreateDiscussionForm(
    BuildContext context,
    CommunityController controller,
    ScrollController scrollController,
  ) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Start a New Discussion',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 24),
            
            AdaptiveTextFormField(
              labelText: 'Discussion Title',
              hintText: 'What would you like to discuss?',
              maxLines: 2,
            ),
            
            const SizedBox(height: 16),
            
            AdaptiveTextFormField(
              labelText: 'Description',
              hintText: 'Share more details about your topic...',
              maxLines: 6,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'General Discussion',
                'Symptom Support',
                'Fertility & Pregnancy',
                'Mental Health',
                'Lifestyle & Nutrition',
                'Medical Questions',
              ].map((category) => FilterChip(
                label: Text(category),
                selected: false,
                onSelected: (selected) {
                  // Handle category selection
                },
              )).toList(),
            ),
            
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(
                  child: AdaptiveButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                    isPrimary: false,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  flex: 2,
                  child: AdaptiveButton(
                    text: 'Post Discussion',
                    onPressed: () {
                      // Handle discussion creation
                      Navigator.pop(context);
                    },
                    isPrimary: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _askExpertQuestion(BuildContext context, CommunityController controller) {
    // Implementation for expert question form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ask Expert Question feature coming soon!')),
    );
  }

  void _findCycleBuddies(BuildContext context, CommunityController controller) {
    // Implementation for cycle buddy matching
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cycle Buddy Matching feature coming soon!')),
    );
  }

  void _shareSymptomStory(BuildContext context, CommunityController controller) {
    // Implementation for symptom story sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Symptom Story Sharing feature coming soon!')),
    );
  }

  void _showNotifications(BuildContext context) {
    Navigator.pushNamed(context, '/community/notifications');
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: CommunitySearchDelegate(),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: overlapsContent ? 4 : 0,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

class CommunitySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implementation for search results
    return const Center(
      child: Text('Search results will appear here'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implementation for search suggestions
    return const Center(
      child: Text('Search suggestions will appear here'),
    );
  }
}
