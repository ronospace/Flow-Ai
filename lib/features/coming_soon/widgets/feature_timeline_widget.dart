import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

/// Feature timeline widget showing development roadmap
class FeatureTimelineWidget extends StatelessWidget {
  const FeatureTimelineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final timelineItems = _getTimelineItems();
    
    return Column(
      children: [
        ...timelineItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == timelineItems.length - 1;
          
          return TimelineItemWidget(
            item: item,
            isLast: isLast,
            animationDelay: index * 100,
          );
        }),
      ],
    );
  }

  List<TimelineItem> _getTimelineItems() {
    final now = DateTime.now();
    
    return [
      TimelineItem(
        date: now.subtract(const Duration(days: 30)),
        title: 'Advanced AI Engine',
        description: 'Completed enhanced AI prediction algorithms with personalized insights',
        status: TimelineStatus.completed,
        progress: 1.0,
        icon: Icons.psychology,
        color: AppTheme.successGreen,
        details: [
          'Fertility window optimization',
          'Hormone pattern recognition',
          'Cycle irregularity detection',
        ],
      ),
      
      TimelineItem(
        date: now.add(const Duration(days: 15)),
        title: 'Smart Medication Reminders',
        description: 'AI-optimized birth control and supplement tracking with drug interactions',
        status: TimelineStatus.testing,
        progress: 0.85,
        icon: Icons.medication,
        color: AppTheme.warningOrange,
        details: [
          'Cycle-optimized reminder timing',
          'Drug interaction warnings',
          'Side effect correlation analysis',
          'Pharmacy integration for refills',
        ],
      ),
      
      TimelineItem(
        date: now.add(const Duration(days: 35)),
        title: 'Partner Sharing Dashboard',
        description: 'Secure sharing of cycle insights with partners and healthcare providers',
        status: TimelineStatus.inProgress,
        progress: 0.65,
        icon: Icons.people,
        color: AppTheme.secondaryBlue,
        details: [
          'Granular privacy controls',
          'Real-time cycle updates',
          'Partner notification settings',
          'Healthcare provider portal',
        ],
      ),
      
      TimelineItem(
        date: now.add(const Duration(days: 60)),
        title: 'AI-Powered Telemedicine',
        description: 'Virtual consultations with certified gynecologists and health providers',
        status: TimelineStatus.inProgress,
        progress: 0.45,
        icon: Icons.video_call,
        color: AppTheme.primaryRose,
        details: [
          '24/7 access to certified gynecologists',
          'AI-prepared consultation summaries',
          'Prescription management',
          'Insurance coverage support',
        ],
      ),
      
      TimelineItem(
        date: now.add(const Duration(days: 75)),
        title: 'Advanced Health Analytics',
        description: 'Deep insights with predictive modeling and comprehensive health analysis',
        status: TimelineStatus.planned,
        progress: 0.25,
        icon: Icons.analytics,
        color: AppTheme.primaryPurple,
        details: [
          'Predictive health modeling',
          'PCOS risk assessment',
          'Hormonal imbalance detection',
          'Personalized health recommendations',
        ],
      ),
      
      TimelineItem(
        date: now.add(const Duration(days: 90)),
        title: 'Women\'s Health Research',
        description: 'Participate in cutting-edge research to advance women\'s healthcare',
        status: TimelineStatus.planned,
        progress: 0.1,
        icon: Icons.science,
        color: AppTheme.accentMint,
        details: [
          'Anonymous data contribution',
          'Access to research findings',
          'Participation incentives',
          'IRB-approved studies only',
        ],
      ),
      
      TimelineItem(
        date: now.add(const Duration(days: 120)),
        title: 'Wearable Integration 2.0',
        description: 'Advanced biometric integration with real-time health monitoring',
        status: TimelineStatus.planned,
        progress: 0.05,
        icon: Icons.watch,
        color: AppTheme.secondaryBlue,
        details: [
          'Apple Watch & Fitbit integration',
          'Heart rate variability tracking',
          'Sleep quality correlation',
          'Continuous glucose monitoring',
        ],
      ),
    ];
  }
}

class TimelineItemWidget extends StatefulWidget {
  final TimelineItem item;
  final bool isLast;
  final int animationDelay;

  const TimelineItemWidget({
    super.key,
    required this.item,
    required this.isLast,
    required this.animationDelay,
  });

  @override
  State<TimelineItemWidget> createState() => _TimelineItemWidgetState();
}

class _TimelineItemWidgetState extends State<TimelineItemWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Line
          Column(
            children: [
              // Timeline Node
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.item.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.item.color,
                    width: 2,
                  ),
                ),
                child: Icon(
                  widget.item.icon,
                  color: widget.item.color,
                  size: 24,
                ),
              ).animate().scale(delay: widget.animationDelay.ms),
              
              // Connecting Line
              if (!widget.isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          widget.item.color.withValues(alpha: 0.6),
                          widget.item.color.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                bottom: widget.isLast ? 0 : 24,
              ),
              child: GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: _buildItemContent(),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: widget.animationDelay.ms).slideX(begin: 0.3);
  }

  Widget _buildItemContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.item.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        _buildStatusBadge(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.item.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDateInfo(),
                  ],
                ),
              ),
              Icon(
                _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress Bar
          _buildProgressBar(),
          
          // Expanded Content
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            _buildExpandedContent(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.item.status.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.item.status.color.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        widget.item.status.displayName,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDateInfo() {
    final now = DateTime.now();
    final isUpcoming = widget.item.date.isAfter(now);
    final difference = isUpcoming 
        ? widget.item.date.difference(now)
        : now.difference(widget.item.date);
    
    String timeText;
    IconData timeIcon;
    
    if (isUpcoming) {
      if (difference.inDays <= 30) {
        timeText = 'In ${difference.inDays} days';
        timeIcon = Icons.schedule;
      } else if (difference.inDays <= 90) {
        final weeks = (difference.inDays / 7).round();
        timeText = 'In $weeks weeks';
        timeIcon = Icons.event;
      } else {
        final months = (difference.inDays / 30).round();
        timeText = 'In $months months';
        timeIcon = Icons.calendar_month;
      }
    } else {
      timeText = '${difference.inDays} days ago';
      timeIcon = Icons.check_circle;
    }
    
    return Row(
      children: [
        Icon(
          timeIcon,
          size: 14,
          color: widget.item.color.withValues(alpha: 0.8),
        ),
        const SizedBox(width: 4),
        Text(
          timeText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: widget.item.color.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            Text(
              '${(widget.item.progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: widget.item.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: widget.item.progress,
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation<Color>(widget.item.color),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Features',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        ...widget.item.details.map((detail) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.item.color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    detail,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        
        if (widget.item.status == TimelineStatus.completed)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.successGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.successGreen,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Available Now!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
      ],
    ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.1);
  }
}

// Supporting models

class TimelineItem {
  final DateTime date;
  final String title;
  final String description;
  final TimelineStatus status;
  final double progress;
  final IconData icon;
  final Color color;
  final List<String> details;

  TimelineItem({
    required this.date,
    required this.title,
    required this.description,
    required this.status,
    required this.progress,
    required this.icon,
    required this.color,
    required this.details,
  });
}

enum TimelineStatus {
  planned,
  inProgress,
  testing,
  completed,
}

extension TimelineStatusExtension on TimelineStatus {
  String get displayName {
    switch (this) {
      case TimelineStatus.planned:
        return 'Planned';
      case TimelineStatus.inProgress:
        return 'In Progress';
      case TimelineStatus.testing:
        return 'Testing';
      case TimelineStatus.completed:
        return 'Completed';
    }
  }
  
  Color get color {
    switch (this) {
      case TimelineStatus.planned:
        return Colors.grey;
      case TimelineStatus.inProgress:
        return AppTheme.warningOrange;
      case TimelineStatus.testing:
        return AppTheme.secondaryBlue;
      case TimelineStatus.completed:
        return AppTheme.successGreen;
    }
  }
}
