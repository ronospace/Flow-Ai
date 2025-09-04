import 'package:flutter/material.dart';
import '../models/onboarding_data.dart';
import '../../../core/ui/adaptive_components.dart';

/// 🧠 Personality Quiz Widget - Intelligent Onboarding Component
/// Features: Personality-based setup questions, adaptive personalization,
/// AI-driven recommendations, and user preference analysis
class PersonalityQuizWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final OnboardingData initialData;

  const PersonalityQuizWidget({
    super.key,
    required this.onDataChanged,
    required this.initialData,
  });

  @override
  State<PersonalityQuizWidget> createState() => _PersonalityQuizWidgetState();
}

class _PersonalityQuizWidgetState extends State<PersonalityQuizWidget>
    with TickerProviderStateMixin {
  late TextEditingController _fullNameController;
  late TextEditingController _preferredNameController;
  
  DateTime? _selectedDateOfBirth;
  String? _selectedPersonalityType;
  String? _selectedTrackingStyle;
  String? _selectedMotivationLevel;
  List<String> _selectedInterests = [];
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _personalityTypes = [
    {
      'id': 'analytical',
      'title': 'The Analytical Tracker',
      'description': 'I love detailed data and precise insights',
      'icon': Icons.analytics,
      'color': Colors.blue,
    },
    {
      'id': 'intuitive',
      'title': 'The Intuitive Listener',
      'description': 'I trust my body\'s signals and patterns',
      'icon': Icons.psychology,
      'color': Colors.purple,
    },
    {
      'id': 'wellness_focused',
      'title': 'The Wellness Enthusiast',
      'description': 'I want to optimize my overall health',
      'icon': Icons.spa,
      'color': Colors.green,
    },
    {
      'id': 'minimalist',
      'title': 'The Simple Tracker',
      'description': 'I prefer quick, easy logging',
      'icon': Icons.minimize,
      'color': Colors.orange,
    },
  ];

  final List<Map<String, dynamic>> _trackingStyles = [
    {
      'id': 'detailed',
      'title': 'Detailed Tracking',
      'description': 'Log symptoms, moods, and daily observations',
      'icon': Icons.list_alt,
    },
    {
      'id': 'essential',
      'title': 'Essential Only',
      'description': 'Focus on period dates and flow intensity',
      'icon': Icons.calendar_month,
    },
    {
      'id': 'comprehensive',
      'title': 'Comprehensive Health',
      'description': 'Track everything for complete health picture',
      'icon': Icons.health_and_safety,
    },
  ];

  final List<Map<String, dynamic>> _motivationLevels = [
    {
      'id': 'daily_reminders',
      'title': 'Daily Check-ins',
      'description': 'I want gentle daily reminders',
      'icon': Icons.notifications_active,
    },
    {
      'id': 'weekly_summaries',
      'title': 'Weekly Summaries',
      'description': 'Show me weekly patterns and insights',
      'icon': Icons.bar_chart,
    },
    {
      'id': 'milestone_driven',
      'title': 'Achievement Focused',
      'description': 'Celebrate tracking milestones with me',
      'icon': Icons.emoji_events,
    },
  ];

  final List<Map<String, dynamic>> _interests = [
    {'id': 'fertility', 'title': 'Fertility Planning', 'icon': Icons.child_care},
    {'id': 'symptom_relief', 'title': 'Symptom Management', 'icon': Icons.healing},
    {'id': 'mood_tracking', 'title': 'Mood & Energy', 'icon': Icons.sentiment_satisfied},
    {'id': 'exercise', 'title': 'Exercise & Activity', 'icon': Icons.fitness_center},
    {'id': 'nutrition', 'title': 'Nutrition & Diet', 'icon': Icons.restaurant},
    {'id': 'sleep', 'title': 'Sleep Quality', 'icon': Icons.bedtime},
    {'id': 'stress', 'title': 'Stress Management', 'icon': Icons.self_improvement},
    {'id': 'relationships', 'title': 'Relationships & Intimacy', 'icon': Icons.favorite},
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _loadInitialData();
  }

  void _initializeControllers() {
    _fullNameController = TextEditingController();
    _preferredNameController = TextEditingController();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

  void _loadInitialData() {
    final data = widget.initialData;
    _fullNameController.text = data.fullName ?? '';
    _preferredNameController.text = data.preferredName ?? '';
    _selectedDateOfBirth = data.dateOfBirth;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _preferredNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _notifyDataChanged() {
    final data = {
      'fullName': _fullNameController.text.trim(),
      'preferredName': _preferredNameController.text.trim(),
      'dateOfBirth': _selectedDateOfBirth,
      'age': _selectedDateOfBirth != null 
          ? DateTime.now().year - _selectedDateOfBirth!.year 
          : null,
      'personalityType': _selectedPersonalityType,
      'trackingStyle': _selectedTrackingStyle,
      'motivationLevel': _selectedMotivationLevel,
      'interests': _selectedInterests,
    };
    
    widget.onDataChanged(data);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildBasicInfoSection(context),
            const SizedBox(height: 32),
            _buildPersonalitySection(context),
            const SizedBox(height: 32),
            _buildTrackingStyleSection(context),
            const SizedBox(height: 32),
            _buildMotivationSection(context),
            const SizedBox(height: 32),
            _buildInterestsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Let\'s get to know you! 👋',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'This helps us create a personalized experience tailored just for you.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Basic Information',
      child: Column(
        children: [
          AdaptiveTextFormField(
            controller: _fullNameController,
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            prefixIcon: Icons.person,
            onChanged: (_) => _notifyDataChanged(),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          AdaptiveTextFormField(
            controller: _preferredNameController,
            labelText: 'Preferred Name (Optional)',
            hintText: 'What would you like us to call you?',
            prefixIcon: Icons.badge,
            onChanged: (_) => _notifyDataChanged(),
          ),
          
          const SizedBox(height: 16),
          
          _buildDateOfBirthField(context),
        ],
      ),
    );
  }

  Widget _buildDateOfBirthField(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => _selectDateOfBirth(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date of Birth',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  
                  const SizedBox(height: 2),
                  
                  Text(
                    _selectedDateOfBirth != null
                        ? _formatDate(_selectedDateOfBirth!)
                        : 'Select your date of birth',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _selectedDateOfBirth != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalitySection(BuildContext context) {
    return _buildSection(
      context,
      title: 'What\'s your tracking personality?',
      subtitle: 'Choose the style that resonates with you most',
      child: Column(
        children: _personalityTypes.map((type) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPersonalityCard(context, type),
        )).toList(),
      ),
    );
  }

  Widget _buildPersonalityCard(BuildContext context, Map<String, dynamic> type) {
    final theme = Theme.of(context);
    final isSelected = _selectedPersonalityType == type['id'];
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPersonalityType = type['id'];
        });
        _notifyDataChanged();
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (type['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                type['icon'],
                color: type['color'],
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type['title'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    type['description'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingStyleSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'How detailed do you want your tracking?',
      child: Column(
        children: _trackingStyles.map((style) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOptionCard(
            context,
            item: style,
            isSelected: _selectedTrackingStyle == style['id'],
            onTap: () {
              setState(() {
                _selectedTrackingStyle = style['id'];
              });
              _notifyDataChanged();
            },
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildMotivationSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'How do you stay motivated?',
      child: Column(
        children: _motivationLevels.map((level) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOptionCard(
            context,
            item: level,
            isSelected: _selectedMotivationLevel == level['id'],
            onTap: () {
              setState(() {
                _selectedMotivationLevel = level['id'];
              });
              _notifyDataChanged();
            },
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildInterestsSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'What aspects of health interest you most?',
      subtitle: 'Select all that apply',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _interests.map((interest) => _buildInterestChip(
          context,
          interest: interest,
        )).toList(),
      ),
    );
  }

  Widget _buildInterestChip(BuildContext context, {required Map<String, dynamic> interest}) {
    final theme = Theme.of(context);
    final isSelected = _selectedInterests.contains(interest['id']);
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            interest['icon'],
            size: 16,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          
          const SizedBox(width: 8),
          
          Text(interest['title']),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedInterests.add(interest['id']);
          } else {
            _selectedInterests.remove(interest['id']);
          }
        });
        _notifyDataChanged();
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary,
      checkmarkColor: theme.colorScheme.onPrimary,
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required Map<String, dynamic> item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              item['icon'],
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    item['description'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
        
        const SizedBox(height: 16),
        
        child,
      ],
    );
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'SELECT DATE OF BIRTH',
    );
    
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
      _notifyDataChanged();
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
