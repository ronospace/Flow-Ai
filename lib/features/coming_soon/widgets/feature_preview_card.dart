import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/coming_soon_feature.dart';

/// Advanced feature preview card with detailed information and interaction
class FeaturePreviewCard extends StatefulWidget {
  final ComingSoonFeature feature;
  final bool isSelected;
  final VoidCallback onTap;

  const FeaturePreviewCard({
    super.key,
    required this.feature,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<FeaturePreviewCard> createState() => _FeaturePreviewCardState();
}

class _FeaturePreviewCardState extends State<FeaturePreviewCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutQuart,
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.02 : 1.0)
            ..translate(0.0, _isHovered ? -4.0 : 0.0),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: widget.isSelected ? 0.25 : 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isSelected 
                    ? widget.feature.color.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.3),
                width: widget.isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.feature.color.withValues(
                    alpha: widget.isSelected ? 0.2 : 0.1
                  ),
                  blurRadius: widget.isSelected ? 20 : 10,
                  offset: Offset(0, widget.isSelected ? 8 : 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildCardHeader(),
                if (widget.isSelected) ...[
                  const Divider(color: Colors.white24),
                  _buildExpandedContent(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Feature Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.feature.color,
                  widget.feature.color.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.feature.color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              widget.feature.icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Feature Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.feature.title,
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
                  widget.feature.subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                _buildEstimatedDate(),
              ],
            ),
          ),
          
          // Expand Indicator
          AnimatedRotation(
            turns: widget.isSelected ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white.withValues(alpha: 0.7),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.feature.status.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.feature.status.color.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        widget.feature.status.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEstimatedDate() {
    final now = DateTime.now();
    final daysUntil = widget.feature.estimatedRelease.difference(now).inDays;
    
    String timeText;
    IconData timeIcon;
    
    if (daysUntil <= 30) {
      timeText = 'Coming in $daysUntil days';
      timeIcon = Icons.schedule;
    } else if (daysUntil <= 90) {
      final weeks = (daysUntil / 7).round();
      timeText = 'Coming in $weeks weeks';
      timeIcon = Icons.event;
    } else {
      final months = (daysUntil / 30).round();
      timeText = 'Coming in $months months';
      timeIcon = Icons.calendar_month;
    }
    
    return Row(
      children: [
        Icon(
          timeIcon,
          size: 14,
          color: widget.feature.color.withValues(alpha: 0.8),
        ),
        const SizedBox(width: 4),
        Text(
          timeText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: widget.feature.color.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(
            widget.feature.description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Features List
          Text(
            'Key Features:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 8),
          
          ...widget.feature.features.asMap().entries.map((entry) {
            final index = entry.key;
            final feature = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.feature.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.2);
          }),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Get Notified',
                  Icons.notifications_outlined,
                  widget.feature.color,
                  () => _handleNotifyMe(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Learn More',
                  Icons.info_outline,
                  Colors.white.withValues(alpha: 0.2),
                  () => _handleLearnMore(),
                  isSecondary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2);
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isSecondary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSecondary ? Colors.transparent : color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSecondary 
                ? Colors.white.withValues(alpha: 0.3)
                : color.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotifyMe() {
    // Implement notification signup
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You\'ll be notified when ${widget.feature.title} is ready!'),
        backgroundColor: widget.feature.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleLearnMore() {
    // Implement learn more functionality
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFeatureDetailSheet(),
    );
  }

  Widget _buildFeatureDetailSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a2e),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [widget.feature.color, widget.feature.color.withValues(alpha: 0.7)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.feature.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.feature.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              widget.feature.subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Detailed Description
                  const Text(
                    'About This Feature',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.feature.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Features
                  const Text(
                    'What You\'ll Get',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.feature.features.length,
                      itemBuilder: (context, index) {
                        final feature = widget.feature.features[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: widget.feature.color,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
