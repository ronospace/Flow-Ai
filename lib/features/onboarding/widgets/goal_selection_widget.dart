import 'package:flutter/material.dart';

/// 🎯 Goal Selection Widget - Comprehensive Health Goal Setting
/// Features: Multiple goal categories, priority selection, timeline setting,
/// progress tracking setup, and personalized recommendations
class GoalSelectionWidget extends StatefulWidget {
  final Function(List<String>) onGoalsChanged;
  final List<String>? initialGoals;

  const GoalSelectionWidget({
    super.key,
    required this.onGoalsChanged,
    this.initialGoals,
  });

  @override
  State<GoalSelectionWidget> createState() => _GoalSelectionWidgetState();
}

class _GoalSelectionWidgetState extends State<GoalSelectionWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<String> _selectedGoals = [];
  String _selectedPriority = 'balanced';

  final Map<String, List<Map<String, dynamic>>> _goalCategories = {
    'Cycle Tracking': [
      {
        'id': 'accurate_predictions',
        'title': 'Accurate Period Predictions',
        'subtitle': 'Never be surprised by your period again',
        'icon': Icons.calendar_today,
        'color': Colors.pink,
        'popular': true,
      },
      {
        'id': 'fertility_tracking',
        'title': 'Fertility Awareness',
        'subtitle': 'Track ovulation and fertile windows',
        'icon': Icons.child_care,
        'color': Colors.green,
        'popular': true,
      },
      {
        'id': 'cycle_regularity',
        'title': 'Cycle Regularity Monitoring',
        'subtitle': 'Understand your menstrual patterns',
        'icon': Icons.show_chart,
        'color': Colors.blue,
        'popular': false,
      },
    ],
    'Symptom Management': [
      {
        'id': 'pms_relief',
        'title': 'PMS & Cramp Relief',
        'subtitle': 'Get personalized symptom management tips',
        'icon': Icons.healing,
        'color': Colors.orange,
        'popular': true,
      },
      {
        'id': 'mood_tracking',
        'title': 'Mood & Energy Patterns',
        'subtitle': 'Track emotional changes throughout your cycle',
        'icon': Icons.sentiment_satisfied,
        'color': Colors.purple,
        'popular': true,
      },
      {
        'id': 'sleep_optimization',
        'title': 'Sleep Quality Improvement',
        'subtitle': 'Optimize sleep based on hormonal changes',
        'icon': Icons.bedtime,
        'color': Colors.indigo,
        'popular': false,
      },
      {
        'id': 'pain_management',
        'title': 'Pain Management',
        'subtitle': 'Track and manage menstrual pain effectively',
        'icon': Icons.medical_services,
        'color': Colors.red,
        'popular': false,
      },
    ],
    'Health & Wellness': [
      {
        'id': 'nutrition_optimization',
        'title': 'Nutrition Optimization',
        'subtitle': 'Eat according to your cycle phases',
        'icon': Icons.restaurant,
        'color': Colors.green,
        'popular': false,
      },
      {
        'id': 'fitness_alignment',
        'title': 'Cycle-Synced Fitness',
        'subtitle': 'Align workouts with your hormonal phases',
        'icon': Icons.fitness_center,
        'color': Colors.amber,
        'popular': true,
      },
      {
        'id': 'stress_management',
        'title': 'Stress Management',
        'subtitle': 'Manage stress throughout your cycle',
        'icon': Icons.self_improvement,
        'color': Colors.teal,
        'popular': false,
      },
      {
        'id': 'hormonal_balance',
        'title': 'Hormonal Balance',
        'subtitle': 'Support natural hormone regulation',
        'icon': Icons.balance,
        'color': Colors.deepPurple,
        'popular': false,
      },
    ],
    'Reproductive Health': [
      {
        'id': 'conception_planning',
        'title': 'Conception Planning',
        'subtitle': 'Optimize timing for trying to conceive',
        'icon': Icons.favorite,
        'color': Colors.pink,
        'popular': false,
      },
      {
        'id': 'contraception_support',
        'title': 'Natural Contraception',
        'subtitle': 'Natural family planning support',
        'icon': Icons.security,
        'color': Colors.cyan,
        'popular': false,
      },
      {
        'id': 'reproductive_health',
        'title': 'General Reproductive Health',
        'subtitle': 'Monitor overall reproductive wellness',
        'icon': Icons.health_and_safety,
        'color': Colors.lightGreen,
        'popular': false,
      },
    ],
    'Long-term Health': [
      {
        'id': 'health_insights',
        'title': 'Health Pattern Insights',
        'subtitle': 'Understand long-term health trends',
        'icon': Icons.insights,
        'color': Colors.deepOrange,
        'popular': true,
      },
      {
        'id': 'doctor_communication',
        'title': 'Better Doctor Visits',
        'subtitle': 'Prepare comprehensive health reports',
        'icon': Icons.local_hospital,
        'color': Colors.blue,
        'popular': false,
      },
      {
        'id': 'preventive_care',
        'title': 'Preventive Healthcare',
        'subtitle': 'Early detection of health changes',
        'icon': Icons.warning,
        'color': Colors.orange,
        'popular': false,
      },
    ],
  };

  final List<Map<String, dynamic>> _priorityLevels = [
    {
      'id': 'focused',
      'title': 'Focused Approach',
      'subtitle': 'Deep dive into 1-2 main goals',
      'icon': Icons.center_focus_strong,
      'recommendedGoals': 2,
    },
    {
      'id': 'balanced',
      'title': 'Balanced Wellness',
      'subtitle': 'Track multiple aspects of health',
      'icon': Icons.balance,
      'recommendedGoals': 4,
    },
    {
      'id': 'comprehensive',
      'title': 'Comprehensive Tracking',
      'subtitle': 'Monitor all aspects of your health',
      'icon': Icons.dashboard,
      'recommendedGoals': 6,
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
    if (widget.initialGoals != null) {
      _selectedGoals = List.from(widget.initialGoals!);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _notifyGoalsChanged() {
    widget.onGoalsChanged(_selectedGoals);
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
            _buildPrioritySelection(context),
            const SizedBox(height: 32),
            _buildPopularGoalsSection(context),
            const SizedBox(height: 32),
            _buildAllGoalsSection(context),
            const SizedBox(height: 32),
            _buildSelectedGoalsSummary(context),
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
          'What are your health goals? 🎯',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Select the areas where you\'d like to see improvement and get personalized insights.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your tracking style',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        ...(_priorityLevels.map((priority) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPriorityCard(context, priority),
        ))),
      ],
    );
  }

  Widget _buildPriorityCard(BuildContext context, Map<String, dynamic> priority) {
    final theme = Theme.of(context);
    final isSelected = _selectedPriority == priority['id'];
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPriority = priority['id'];
        });
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
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                priority['icon'],
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    priority['title'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    priority['subtitle'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    'Recommended: ${priority['recommendedGoals']} goals',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
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

  Widget _buildPopularGoalsSection(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get popular goals from all categories
    final popularGoals = <Map<String, dynamic>>[];
    for (final category in _goalCategories.values) {
      for (final goal in category) {
        if (goal['popular'] == true) {
          popularGoals.add(goal);
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.trending_up,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            
            const SizedBox(width: 8),
            
            Text(
              'Most Popular Goals',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popularGoals.map((goal) => _buildGoalChip(context, goal)).toList(),
        ),
      ],
    );
  }

  Widget _buildAllGoalsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _goalCategories.entries.map((entry) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryHeader(context, entry.key),
          const SizedBox(height: 16),
          _buildGoalsGrid(context, entry.value),
          const SizedBox(height: 32),
        ],
      )).toList(),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, String categoryName) {
    final theme = Theme.of(context);
    
    return Text(
      categoryName,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildGoalsGrid(BuildContext context, List<Map<String, dynamic>> goals) {
    return Column(
      children: goals.map((goal) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildGoalCard(context, goal),
      )).toList(),
    );
  }

  Widget _buildGoalCard(BuildContext context, Map<String, dynamic> goal) {
    final theme = Theme.of(context);
    final isSelected = _selectedGoals.contains(goal['id']);
    
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedGoals.remove(goal['id']);
          } else {
            _selectedGoals.add(goal['id']);
          }
        });
        _notifyGoalsChanged();
      },
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
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (goal['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                goal['icon'],
                color: goal['color'],
                size: 20,
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
                          goal['title'],
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      
                      if (goal['popular'] == true) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Popular',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.orange,
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
                    goal['subtitle'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
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

  Widget _buildGoalChip(BuildContext context, Map<String, dynamic> goal) {
    final theme = Theme.of(context);
    final isSelected = _selectedGoals.contains(goal['id']);
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            goal['icon'],
            size: 16,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : goal['color'],
          ),
          
          const SizedBox(width: 8),
          
          Text(goal['title']),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedGoals.add(goal['id']);
          } else {
            _selectedGoals.remove(goal['id']);
          }
        });
        _notifyGoalsChanged();
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary,
      checkmarkColor: theme.colorScheme.onPrimary,
      side: BorderSide(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildSelectedGoalsSummary(BuildContext context) {
    if (_selectedGoals.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final recommendedCount = _priorityLevels
        .firstWhere((p) => p['id'] == _selectedPriority)['recommendedGoals'] as int;
    
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
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
              
              const SizedBox(width: 12),
              
              Text(
                'Your Goals (${_selectedGoals.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedGoals.map((goalId) {
              final goal = _findGoalById(goalId);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  goal?['title'] ?? goalId,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getRecommendationColor(theme).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _getRecommendationIcon(),
                  color: _getRecommendationColor(theme),
                  size: 20,
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: Text(
                    _getRecommendationText(recommendedCount),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getRecommendationColor(theme),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? _findGoalById(String goalId) {
    for (final category in _goalCategories.values) {
      for (final goal in category) {
        if (goal['id'] == goalId) {
          return goal;
        }
      }
    }
    return null;
  }

  Color _getRecommendationColor(ThemeData theme) {
    final recommendedCount = _priorityLevels
        .firstWhere((p) => p['id'] == _selectedPriority)['recommendedGoals'] as int;
    
    if (_selectedGoals.length == recommendedCount) {
      return Colors.green;
    } else if (_selectedGoals.length < recommendedCount) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  IconData _getRecommendationIcon() {
    final recommendedCount = _priorityLevels
        .firstWhere((p) => p['id'] == _selectedPriority)['recommendedGoals'] as int;
    
    if (_selectedGoals.length == recommendedCount) {
      return Icons.check_circle;
    } else if (_selectedGoals.length < recommendedCount) {
      return Icons.info;
    } else {
      return Icons.lightbulb;
    }
  }

  String _getRecommendationText(int recommendedCount) {
    if (_selectedGoals.length == recommendedCount) {
      return 'Perfect! You\'ve selected the ideal number of goals for your tracking style.';
    } else if (_selectedGoals.length < recommendedCount) {
      return 'Consider adding ${recommendedCount - _selectedGoals.length} more goal(s) to get the most out of your ${'${_priorityLevels.firstWhere((p) => p['id'] == _selectedPriority)['title']}'} approach.';
    } else {
      return 'You\'ve selected more goals than recommended. This will give you comprehensive tracking but may require more daily input.';
    }
  }
}
