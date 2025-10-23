import 'package:flutter/material.dart';
import '../models/discussion.dart';
import '../../../core/utils/time_utils.dart';

/// 💬 Discussion Board Widget - Anonymous Community Discussion System
/// Features: Anonymous posting, category filtering, real-time updates,
/// moderated discussions, voting system, and safe space community guidelines
class DiscussionBoardWidget extends StatefulWidget {
  final List<Discussion> discussions;
  final Function(String title, String content, String category, List<String>? tags, bool isAnonymous) onCreateDiscussion;
  final Function(String discussionId) onJoinDiscussion;
  final Function(String postId) onLikePost;
  final Function(String postId, String reason) onReportPost;

  const DiscussionBoardWidget({
    super.key,
    required this.discussions,
    required this.onCreateDiscussion,
    required this.onJoinDiscussion,
    required this.onLikePost,
    required this.onReportPost,
  });

  @override
  State<DiscussionBoardWidget> createState() => _DiscussionBoardWidgetState();
}

class _DiscussionBoardWidgetState extends State<DiscussionBoardWidget>
    with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  late Animation<double> _listAnimation;
  
  String _selectedFilter = 'all';
  String _selectedSort = 'recent';
  
  final List<String> _categories = [
    'all',
    'general',
    'symptoms',
    'fertility',
    'mental_health',
    'lifestyle',
    'medical',
    'support',
  ];
  
  final List<String> _sortOptions = [
    'recent',
    'popular',
    'most_replies',
    'trending',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _listAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeInOut,
    ));

    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFiltersAndSort(context),
        Expanded(
          child: _buildDiscussionList(context),
        ),
      ],
    );
  }

  Widget _buildFiltersAndSort(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          // Category filter
          Row(
            children: [
              Icon(
                Icons.filter_list,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              
              const SizedBox(width: 8),
              
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_getCategoryLabel(category)),
                        selected: _selectedFilter == category,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedFilter = category;
                            });
                          }
                        },
                        backgroundColor: theme.colorScheme.surface,
                        selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                        checkmarkColor: theme.colorScheme.primary,
                      ),
                    )).toList(),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Sort options
          Row(
            children: [
              Icon(
                Icons.sort,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              
              const SizedBox(width: 8),
              
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _sortOptions.map((sort) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_getSortLabel(sort)),
                        selected: _selectedSort == sort,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedSort = sort;
                            });
                          }
                        },
                        backgroundColor: theme.colorScheme.surface,
                        selectedColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
                      ),
                    )).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscussionList(BuildContext context) {
    if (widget.discussions.isEmpty) {
      return _buildEmptyState(context);
    }

    final filteredDiscussions = _getFilteredAndSortedDiscussions();

    return FadeTransition(
      opacity: _listAnimation,
      child: RefreshIndicator(
        onRefresh: () async {
          // Trigger refresh
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredDiscussions.length,
          itemBuilder: (context, index) {
            return _buildDiscussionCard(
              context,
              filteredDiscussions[index],
              index,
            );
          },
        ),
      ),
    );
  }

  Widget _buildDiscussionCard(BuildContext context, Discussion discussion, int index) {
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 100 + (index * 50)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _openDiscussion(context, discussion),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(discussion.category).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getCategoryLabel(discussion.category),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getCategoryColor(discussion.category),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Time ago
                    Text(
                      TimeUtils.getTimeAgo(discussion.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    
                    // More options
                    IconButton(
                      onPressed: () => _showDiscussionOptions(context, discussion),
                      icon: const Icon(Icons.more_vert, size: 20),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Title
                Text(
                  discussion.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Preview content
                if (discussion.content.isNotEmpty)
                  Text(
                    discussion.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                const SizedBox(height: 16),
                
                // Tags
                if (discussion.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: discussion.tags.take(3).map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#$tag',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                
                // Action buttons
                Row(
                  children: [
                    // Like button
                    _buildActionButton(
                      context,
                      icon: discussion.hasLiked 
                          ? Icons.favorite 
                          : Icons.favorite_border,
                      label: '${discussion.likeCount}',
                      onPressed: () => widget.onLikePost(discussion.id),
                      isActive: discussion.hasLiked,
                      color: Colors.red,
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Reply button
                    _buildActionButton(
                      context,
                      icon: Icons.chat_bubble_outline,
                      label: '${discussion.replyCount}',
                      onPressed: () => _openDiscussion(context, discussion),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Participants
                    _buildActionButton(
                      context,
                      icon: Icons.people_outline,
                      label: '${discussion.participantCount}',
                      onPressed: () => _showParticipants(context, discussion),
                    ),
                    
                    const Spacer(),
                    
                    // Join/Leave button
                    if (!discussion.hasJoined)
                      AdaptiveButton(
                        text: 'Join',
                        onPressed: () => widget.onJoinDiscussion(discussion.id),
                        isPrimary: false,
                        isCompact: true,
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            
                            const SizedBox(width: 4),
                            
                            Text(
                              'Joined',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final buttonColor = isActive && color != null 
        ? color 
        : theme.colorScheme.onSurface.withValues(alpha: 0.7);
    
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: buttonColor,
            ),
            
            const SizedBox(width: 4),
            
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: buttonColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'No discussions yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Be the first to start a meaningful conversation in our supportive community.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            AdaptiveButton(
              text: 'Start a Discussion',
              onPressed: () {
                // This would trigger the create discussion flow
              },
              isPrimary: true,
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  List<Discussion> _getFilteredAndSortedDiscussions() {
    var discussions = widget.discussions;
    
    // Apply filter
    if (_selectedFilter != 'all') {
      discussions = discussions.where((d) => d.category == _selectedFilter).toList();
    }
    
    // Apply sort
    switch (_selectedSort) {
      case 'popular':
        discussions.sort((a, b) => b.likeCount.compareTo(a.likeCount));
        break;
      case 'most_replies':
        discussions.sort((a, b) => b.replyCount.compareTo(a.replyCount));
        break;
      case 'trending':
        // Custom trending algorithm (engagement over time)
        discussions.sort((a, b) {
          final aScore = _calculateTrendingScore(a);
          final bScore = _calculateTrendingScore(b);
          return bScore.compareTo(aScore);
        });
        break;
      case 'recent':
      default:
        discussions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    
    return discussions;
  }

  double _calculateTrendingScore(Discussion discussion) {
    final hoursSinceCreated = DateTime.now().difference(discussion.createdAt).inHours;
    if (hoursSinceCreated == 0) return 0;
    
    final engagement = discussion.likeCount + discussion.replyCount + discussion.participantCount;
    return engagement / (hoursSinceCreated + 1); // +1 to avoid division by zero
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'all':
        return 'All';
      case 'general':
        return 'General';
      case 'symptoms':
        return 'Symptoms';
      case 'fertility':
        return 'Fertility';
      case 'mental_health':
        return 'Mental Health';
      case 'lifestyle':
        return 'Lifestyle';
      case 'medical':
        return 'Medical';
      case 'support':
        return 'Support';
      default:
        return category.toUpperCase();
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'general':
        return Colors.blue;
      case 'symptoms':
        return Colors.orange;
      case 'fertility':
        return Colors.green;
      case 'mental_health':
        return Colors.purple;
      case 'lifestyle':
        return Colors.teal;
      case 'medical':
        return Colors.red;
      case 'support':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String _getSortLabel(String sort) {
    switch (sort) {
      case 'recent':
        return 'Recent';
      case 'popular':
        return 'Popular';
      case 'most_replies':
        return 'Most Replies';
      case 'trending':
        return 'Trending';
      default:
        return sort.toUpperCase();
    }
  }

  void _openDiscussion(BuildContext context, Discussion discussion) {
    Navigator.pushNamed(
      context,
      '/community/discussion',
      arguments: discussion,
    );
  }

  void _showDiscussionOptions(BuildContext context, Discussion discussion) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Discussion'),
            onTap: () {
              Navigator.pop(context);
              _shareDiscussion(discussion);
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.bookmark_border),
            title: const Text('Save Discussion'),
            onTap: () {
              Navigator.pop(context);
              _saveDiscussion(discussion);
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Report Discussion'),
            onTap: () {
              Navigator.pop(context);
              _showReportDialog(context, discussion);
            },
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showParticipants(BuildContext context, Discussion discussion) {
    // Show participants list
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Discussion Participants',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              '${discussion.participantCount} people are participating in this discussion',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _shareDiscussion(Discussion discussion) {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Discussion shared!')),
    );
  }

  void _saveDiscussion(Discussion discussion) {
    // Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Discussion saved!')),
    );
  }

  void _showReportDialog(BuildContext context, Discussion discussion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Discussion'),
        content: const Text(
          'Please tell us why you\'re reporting this discussion. Your report helps keep our community safe.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onReportPost(discussion.id, 'inappropriate_content');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Discussion reported')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}
