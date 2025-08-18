import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/partner_models.dart';

class PartnerCareActionsWidget extends StatefulWidget {
  final List<CareAction> careActions;
  final Function(CareAction) onSendCareAction;
  final bool isLoading;

  const PartnerCareActionsWidget({
    super.key,
    required this.careActions,
    required this.onSendCareAction,
    this.isLoading = false,
  });

  @override
  State<PartnerCareActionsWidget> createState() => _PartnerCareActionsWidgetState();
}

class _PartnerCareActionsWidgetState extends State<PartnerCareActionsWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  bool _showQuickActions = true;

  final List<Map<String, dynamic>> _quickCareActions = [
    {
      'type': CareActionType.encouragement,
      'title': 'Send Love',
      'description': 'Share encouraging words',
      'icon': Icons.favorite,
      'color': AppTheme.primaryRose,
      'gradient': [AppTheme.primaryRose, Color(0xFFFF8A95)],
      'emoji': '💕',
    },
    {
      'type': CareActionType.reminder,
      'title': 'Gentle Reminder',
      'description': 'Help with self-care',
      'icon': Icons.schedule,
      'color': AppTheme.primaryPurple,
      'gradient': [AppTheme.primaryPurple, Color(0xFF9D7BEA)],
      'emoji': '⏰',
    },
    {
      'type': CareActionType.sympathy,
      'title': 'Comfort',
      'description': 'Offer emotional support',
      'icon': Icons.volunteer_activism,
      'color': AppTheme.secondaryBlue,
      'gradient': [AppTheme.secondaryBlue, AppTheme.accentMint],
      'emoji': '🤗',
    },
    {
      'type': CareActionType.celebration,
      'title': 'Celebrate',
      'description': 'Acknowledge achievements',
      'icon': Icons.celebration,
      'color': AppTheme.accentYellow,
      'gradient': [AppTheme.accentYellow, Color(0xFFFFE066)],
      'emoji': '🎉',
    },
  ];

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppTheme.accentYellow.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.accentYellow.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentYellow.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                if (_showQuickActions) ...[
                  _buildQuickActions(theme),
                ] else ...[
                  _buildCareHistory(theme),
                ],
                if (widget.isLoading) _buildLoadingIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.accentYellow.withValues(alpha: 0.1), AppTheme.primaryRose.withValues(alpha: 0.05)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.accentYellow, AppTheme.primaryRose],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.volunteer_activism,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Care Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  ),
                ),
                Text(
                  _showQuickActions
                    ? 'Send emotional support'
                    : '${widget.careActions.length} actions sent',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _showQuickActions = !_showQuickActions),
                icon: Icon(
                  _showQuickActions ? Icons.history : Icons.send,
                  color: AppTheme.accentYellow,
                ),
                tooltip: _showQuickActions ? 'View History' : 'Quick Actions',
              ),
              if (widget.careActions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentYellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.careActions.length}',
                    style: TextStyle(
                      color: AppTheme.accentYellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: -0.2, end: 0);
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Care Actions',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.mediumGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: _quickCareActions.length,
            itemBuilder: (context, index) {
              final action = _quickCareActions[index];
              return _buildQuickActionCard(theme, action, index);
            },
          ),
          const SizedBox(height: 20),
          _buildCustomCareAction(theme),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(ThemeData theme, Map<String, dynamic> action, int index) {
    return GestureDetector(
      onTap: () => _showCareActionDialog(action),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: action['gradient'],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: action['color'].withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    action['emoji'],
                    style: const TextStyle(fontSize: 24),
                  ),
                  const Spacer(),
                  Icon(
                    action['icon'],
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                action['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                action['description'],
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 150).ms)
      .scale(begin: const Offset(0.8, 0.8))
      .fadeIn(duration: 400.ms);
  }

  Widget _buildCustomCareAction(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.lightGrey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.lightGrey.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.add_circle_outline,
            color: AppTheme.mediumGrey,
          ),
        ),
        title: Text(
          'Custom Care Action',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGrey,
          ),
        ),
        subtitle: Text(
          'Create a personalized message',
          style: TextStyle(
            color: AppTheme.mediumGrey,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppTheme.mediumGrey,
          size: 16,
        ),
        onTap: () => _showCustomCareActionDialog(),
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildCareHistory(ThemeData theme) {
    if (widget.careActions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: AppTheme.lightGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'No care actions yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.mediumGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start sharing emotional support with your partner',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Care Actions',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.mediumGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Last 7 days',
                style: TextStyle(
                  color: AppTheme.lightGrey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.careActions.length.clamp(0, 5),
            itemBuilder: (context, index) {
              final action = widget.careActions[index];
              return _buildCareActionItem(theme, action, index);
            },
          ),
          if (widget.careActions.length > 5) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to full care history
                },
                child: Text(
                  'View all ${widget.careActions.length} actions',
                  style: TextStyle(
                    color: AppTheme.accentYellow,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCareActionItem(ThemeData theme, CareAction action, int index) {
    final actionInfo = _quickCareActions.firstWhere(
      (info) => info['type'] == action.type,
      orElse: () => _quickCareActions.first,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (actionInfo['color'] as Color).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: actionInfo['gradient'],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                actionInfo['emoji'],
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      action.isFromCurrentUser ? 'You sent' : 'Received',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGrey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      actionInfo['title'],
                      style: TextStyle(
                        color: actionInfo['color'],
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  action.message,
                  style: TextStyle(
                    color: AppTheme.mediumGrey,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(action.sentAt),
                  style: TextStyle(
                    color: AppTheme.lightGrey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 100).ms).slideX(begin: -0.2, end: 0).fadeIn();
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentYellow),
              strokeWidth: 3,
            ),
            const SizedBox(height: 12),
            Text(
              'Sending care action...',
              style: TextStyle(
                color: AppTheme.mediumGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  void _showCareActionDialog(Map<String, dynamic> actionInfo) {
    final TextEditingController messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Text(actionInfo['emoji'], style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              actionInfo['title'],
              style: TextStyle(
                color: actionInfo['color'],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              actionInfo['description'],
              style: TextStyle(
                color: AppTheme.mediumGrey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Add a personal message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: actionInfo['color'],
                    width: 2,
                  ),
                ),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.mediumGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final careAction = CareAction(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                type: actionInfo['type'],
                message: messageController.text.isNotEmpty 
                  ? messageController.text
                  : _getDefaultMessage(actionInfo['type']),
                sentAt: DateTime.now(),
                isFromCurrentUser: true,
                partnershipId: 'current_partnership', // Replace with actual ID
              );
              widget.onSendCareAction(careAction);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: actionInfo['color'],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Send', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCustomCareActionDialog() {
    final TextEditingController messageController = TextEditingController();
    CareActionType selectedType = CareActionType.encouragement;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                'Custom Care Action',
                style: TextStyle(
                  color: AppTheme.primaryRose,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create a personalized care message',
                style: TextStyle(
                  color: AppTheme.mediumGrey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<CareActionType>(
                value: selectedType,
                decoration: InputDecoration(
                  labelText: 'Care Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: CareActionType.values.map((type) {
                  final info = _quickCareActions.firstWhere(
                    (action) => action['type'] == type,
                    orElse: () => _quickCareActions.first,
                  );
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Text(info['emoji']),
                        const SizedBox(width: 8),
                        Text(info['title']),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (type) {
                  if (type != null) {
                    setState(() => selectedType = type);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: 'Write your care message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primaryRose,
                      width: 2,
                    ),
                  ),
                ),
                maxLines: 4,
                maxLength: 300,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.mediumGrey),
              ),
            ),
            ElevatedButton(
              onPressed: messageController.text.trim().isNotEmpty
                ? () {
                    final careAction = CareAction(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      type: selectedType,
                      message: messageController.text.trim(),
                      sentAt: DateTime.now(),
                      isFromCurrentUser: true,
                      partnershipId: 'current_partnership',
                    );
                    widget.onSendCareAction(careAction);
                    Navigator.pop(context);
                  }
                : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRose,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Send', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  String _getDefaultMessage(CareActionType type) {
    switch (type) {
      case CareActionType.encouragement:
        return 'You\'re doing amazing! Keep going! 💪';
      case CareActionType.reminder:
        return 'Gentle reminder to take care of yourself today 🌸';
      case CareActionType.sympathy:
        return 'I\'m here for you, sending you love and comfort ❤️';
      case CareActionType.celebration:
        return 'Celebrating you and your achievements! 🎉';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}
