import 'package:flutter/material.dart';
import '../../../core/models/community_models.dart';
import '../controllers/community_controller.dart';

class SymptomSharingWidget extends StatefulWidget {
  final List<SymptomStory> stories;
  final List<String> categories;
  final Function(SymptomStory) onStoryTapped;
  final Function(String, String) onReactToStory;
  final Function(String) onFollowStory;
  final Function(SymptomStory) onShareStory;

  const SymptomSharingWidget({
    Key? key,
    required this.stories,
    required this.categories,
    required this.onStoryTapped,
    required this.onReactToStory,
    required this.onFollowStory,
    required this.onShareStory,
  }) : super(key: key);

  @override
  State<SymptomSharingWidget> createState() => _SymptomSharingWidgetState();
}

class _SymptomSharingWidgetState extends State<SymptomSharingWidget> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredStories = _getFilteredStories();

    return Column(
      children: [
        _buildHeader(theme),
        const SizedBox(height: 16),
        _buildSearchBar(theme),
        const SizedBox(height: 16),
        _buildCategoryFilter(theme),
        const SizedBox(height: 16),
        _buildStoriesList(filteredStories, theme),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.forum,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Symptom Stories',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Share and read experiences from the community',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _showNewStoryDialog(context),
          icon: Icon(
            Icons.add,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search stories...',
        prefixIcon: Icon(
          Icons.search,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildCategoryFilter(ThemeData theme) {
    final categories = ['All', ...widget.categories];
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              checkmarkColor: theme.colorScheme.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoriesList(List<SymptomStory> stories, ThemeData theme) {
    if (stories.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Expanded(
      child: ListView.builder(
        itemCount: stories.length,
        itemBuilder: (context, index) {
          return _buildStoryCard(stories[index], theme);
        },
      ),
    );
  }

  Widget _buildStoryCard(SymptomStory story, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => widget.onStoryTapped(story),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      story.isAnonymous ? 'A' : story.userId[0].toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.isAnonymous ? 'Anonymous' : 'Community Member',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatTimeAgo(story.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStoryActions(story, theme),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                story.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                story.content,
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (story.symptoms.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildSymptomTags(story.symptoms, theme),
              ],
              const SizedBox(height: 12),
              _buildStoryStats(story, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryActions(SymptomStory story, ThemeData theme) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'follow':
            widget.onFollowStory(story.id);
            break;
          case 'share':
            widget.onShareStory(story);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'follow',
          child: Row(
            children: [
              Icon(Icons.bookmark_add),
              SizedBox(width: 8),
              Text('Follow Story'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share),
              SizedBox(width: 8),
              Text('Share'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomTags(List<String> symptoms, ThemeData theme) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: symptoms.take(3).map((symptom) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            symptom,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontSize: 11,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStoryStats(SymptomStory story, ThemeData theme) {
    return Row(
      children: [
        _buildStatItem(Icons.thumb_up, story.likes, theme),
        const SizedBox(width: 16),
        _buildStatItem(Icons.comment, story.comments, theme),
        const Spacer(),
        Text(
          story.category.toUpperCase(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, int count, ThemeData theme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'No stories found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your experience',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  List<SymptomStory> _getFilteredStories() {
    var filtered = widget.stories;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((story) => story.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((story) =>
        story.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        story.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        story.symptoms.any((s) => s.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }

    return filtered;
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showNewStoryDialog(BuildContext context) {
    // Implementation for creating a new story
    // This would show a dialog with form fields
  }
}
