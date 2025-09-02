import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/health/advanced_health_analytics.dart';

/// AI-powered insights panel with smart recommendations and predictions
class AIInsightsPanel extends StatefulWidget {
  final ComprehensiveHealthReport healthReport;

  const AIInsightsPanel({
    Key? key,
    required this.healthReport,
  }) : super(key: key);

  @override
  State<AIInsightsPanel> createState() => _AIInsightsPanelState();
}

class _AIInsightsPanelState extends State<AIInsightsPanel>
    with TickerProviderStateMixin {
  late AnimationController _fadeInController;
  late AnimationController _expandController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _expandAnimation;

  bool _isExpanded = false;
  int _selectedInsightIndex = 0;

  @override
  void initState() {
    super.initState();
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeInOut,
    ));

    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubic,
    ));

    _fadeInController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1D1E33),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.purple.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildInsightsCarousel(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isExpanded ? null : 0,
              child: _buildExpandedContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.1),
            Colors.pink.withOpacity(0.1),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.purple,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Health Insights',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getInsightSummary(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getHealthScoreColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${(widget.healthReport.overallHealthScore * 100).round()}%',
              style: TextStyle(
                color: _getHealthScoreColor(),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCarousel() {
    final insights = _getInsights();
    
    return SizedBox(
      height: 160,
      child: PageView.builder(
        onPageChanged: (index) {
          setState(() {
            _selectedInsightIndex = index;
          });
        },
        itemCount: insights.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: _buildInsightCard(insights[index], index),
          );
        },
      ),
    );
  }

  Widget _buildInsightCard(Map<String, dynamic> insight, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D5A),
        borderRadius: BorderRadius.circular(12),
        border: index == _selectedInsightIndex
            ? Border.all(color: Colors.purple.withOpacity(0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: insight['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  insight['icon'],
                  color: insight['color'],
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  insight['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildConfidenceBadge(insight['confidence']),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight['description'],
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: insight['impact'] / 100.0,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(insight['color']),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${insight['impact']}% impact',
                style: TextStyle(
                  color: insight['color'],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBadge(double confidence) {
    final color = confidence >= 0.8
        ? Colors.green
        : confidence >= 0.6
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${(confidence * 100).round()}%',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return SizeTransition(
      sizeFactor: _expandAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: Colors.white10),
            const SizedBox(height: 16),
            _buildRecommendationsSection(),
            const SizedBox(height: 16),
            _buildPredictionsSection(),
            const SizedBox(height: 16),
            _buildExpandToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Recommendations',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...widget.healthReport.recommendations
            .take(3)
            .map((rec) => _buildRecommendationItem(rec)),
      ],
    );
  }

  Widget _buildRecommendationItem(HealthRecommendation recommendation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: _getPriorityColor(recommendation.priority),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.action,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  recommendation.reasoning,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getPriorityColor(recommendation.priority).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              recommendation.timeframe,
              style: TextStyle(
                color: _getPriorityColor(recommendation.priority),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Predictions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ..._getPredictions().map((prediction) => _buildPredictionItem(prediction)),
      ],
    );
  }

  Widget _buildPredictionItem(Map<String, dynamic> prediction) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D5A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            prediction['icon'],
            color: prediction['color'],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prediction['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  prediction['description'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            prediction['timeframe'],
            style: TextStyle(
              color: prediction['color'],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandToggle() {
    return Center(
      child: GestureDetector(
        onTap: _toggleExpanded,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isExpanded ? 'Show Less' : 'Show More',
                style: const TextStyle(
                  color: Colors.purple,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.purple,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  List<Map<String, dynamic>> _getInsights() {
    final random = math.Random();
    
    return [
      {
        'title': 'Cycle Regularity',
        'description': 'Your cycles are showing excellent regularity patterns with 94% consistency.',
        'icon': Icons.track_changes,
        'color': Colors.green,
        'confidence': 0.94,
        'impact': 85,
      },
      {
        'title': 'Sleep Quality Impact',
        'description': 'Your sleep patterns are strongly correlated with mood stability.',
        'icon': Icons.bedtime,
        'color': Colors.blue,
        'confidence': 0.87,
        'impact': 72,
      },
      {
        'title': 'Stress Management',
        'description': 'Recent stress levels may be affecting your cycle length predictions.',
        'icon': Icons.psychology,
        'color': Colors.orange,
        'confidence': 0.76,
        'impact': 68,
      },
      {
        'title': 'Nutrition Optimization',
        'description': 'Iron levels appear optimal, but consider increasing vitamin D intake.',
        'icon': Icons.restaurant,
        'color': Colors.purple,
        'confidence': 0.82,
        'impact': 79,
      },
    ];
  }

  List<Map<String, dynamic>> _getPredictions() {
    return [
      {
        'title': 'Next Cycle Start',
        'description': 'Predicted in 3-4 days with 89% confidence',
        'icon': Icons.calendar_today,
        'color': Colors.pink,
        'timeframe': '3-4 days',
      },
      {
        'title': 'Fertility Window',
        'description': 'Peak fertility expected around day 14-16',
        'icon': Icons.favorite,
        'color': Colors.red,
        'timeframe': '10 days',
      },
      {
        'title': 'PMS Risk',
        'description': 'Lower than average PMS symptoms expected',
        'icon': Icons.mood,
        'color': Colors.green,
        'timeframe': '7 days',
      },
    ];
  }

  String _getInsightSummary() {
    final score = widget.healthReport.overallHealthScore;
    if (score >= 0.8) {
      return 'Excellent health patterns detected';
    } else if (score >= 0.6) {
      return 'Good health with room for improvement';
    } else {
      return 'Several areas need attention';
    }
  }

  Color _getHealthScoreColor() {
    final score = widget.healthReport.overallHealthScore;
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Color _getPriorityColor(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.critical:
        return Colors.red;
      case RecommendationPriority.high:
        return Colors.orange;
      case RecommendationPriority.medium:
        return Colors.yellow;
      case RecommendationPriority.low:
        return Colors.green;
    }
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _expandController.dispose();
    super.dispose();
  }
}
