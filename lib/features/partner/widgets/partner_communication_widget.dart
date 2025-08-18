import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/partner_models.dart';

class PartnerCommunicationWidget extends StatefulWidget {
  final List<PartnerMessage> messages;
  final Function(String) onSendMessage;

  const PartnerCommunicationWidget({
    super.key,
    required this.messages,
    required this.onSendMessage,
  });

  @override
  State<PartnerCommunicationWidget> createState() => _PartnerCommunicationWidgetState();
}

class _PartnerCommunicationWidgetState extends State<PartnerCommunicationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final TextEditingController _messageController = TextEditingController();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _messageController.dispose();
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
                  AppTheme.primaryRose.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.primaryRose.withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRose.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                if (widget.messages.isNotEmpty) ...[
                  _buildRecentMessages(theme),
                ],
                _buildQuickMessageBar(theme),
                if (_isExpanded) ...[
                  _buildExpandedChat(theme),
                ],
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
          colors: [AppTheme.primaryRose.withValues(alpha: 0.1), AppTheme.primaryPurple.withValues(alpha: 0.1)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.chat_bubble,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Partner Chat',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  ),
                ),
                Text(
                  widget.messages.isNotEmpty 
                    ? '${widget.messages.length} messages'
                    : 'Start a conversation',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
            icon: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppTheme.primaryRose,
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: -0.2, end: 0);
  }

  Widget _buildRecentMessages(ThemeData theme) {
    final recentMessages = widget.messages.take(3).toList();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Messages',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.mediumGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...recentMessages.asMap().entries.map((entry) {
            final index = entry.key;
            final message = entry.value;
            return _buildMessagePreview(theme, message, index);
          }),
          if (widget.messages.length > 3) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _isExpanded = true),
              child: Text(
                'View ${widget.messages.length - 3} more messages',
                style: TextStyle(
                  color: AppTheme.primaryRose,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessagePreview(ThemeData theme, PartnerMessage message, int index) {
    final isFromPartner = message.senderId != 'current_user'; // Replace with actual user ID logic
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isFromPartner 
                  ? [AppTheme.secondaryBlue, AppTheme.accentMint]
                  : [AppTheme.primaryRose, AppTheme.primaryPurple],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFromPartner ? Icons.favorite : Icons.chat,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isFromPartner ? 'Partner' : 'You',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(message.sentAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.mediumGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.mediumGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (message.type == PartnerMessageType.moodCheckIn)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.accentMint.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.psychology,
                color: AppTheme.accentMint,
                size: 12,
              ),
            ),
        ],
      ),
    ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: -0.2, end: 0);
  }

  Widget _buildQuickMessageBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Messages',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.mediumGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickMessageChip('How are you feeling? 💕', Icons.psychology),
              _buildQuickMessageChip('Thinking of you ❤️', Icons.favorite),
              _buildQuickMessageChip('Need anything? 🤗', Icons.support),
              _buildQuickMessageChip('You\'re amazing! 🌟', Icons.star),
            ],
          ),
          const SizedBox(height: 16),
          _buildMessageInput(theme),
        ],
      ),
    );
  }

  Widget _buildQuickMessageChip(String message, IconData icon) {
    return GestureDetector(
      onTap: () => widget.onSendMessage(message),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryRose.withValues(alpha: 0.1), AppTheme.primaryPurple.withValues(alpha: 0.1)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryRose.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.primaryRose, size: 16),
            const SizedBox(width: 6),
            Text(
              message,
              style: TextStyle(
                color: AppTheme.primaryRose,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(begin: const Offset(0.8, 0.8)).fadeIn();
  }

  Widget _buildMessageInput(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: 'Send a message...',
              hintStyle: TextStyle(color: AppTheme.mediumGrey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: AppTheme.lightGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: AppTheme.primaryRose, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
            ),
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: _sendMessage,
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          onPressed: () => _sendMessage(_messageController.text),
          backgroundColor: AppTheme.primaryRose,
          child: const Icon(
            Icons.send,
            color: Colors.white,
            size: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedChat(ThemeData theme) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Full Conversation',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGrey,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _isExpanded = false),
                child: Text(
                  'Collapse',
                  style: TextStyle(color: AppTheme.primaryRose),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: widget.messages.length,
              reverse: true,
              itemBuilder: (context, index) {
                final message = widget.messages[index];
                return _buildFullMessage(theme, message);
              },
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, end: 0).fadeIn();
  }

  Widget _buildFullMessage(ThemeData theme, PartnerMessage message) {
    final isFromPartner = message.senderId != 'current_user'; // Replace with actual user ID logic
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFromPartner) ...[
            _buildAvatar(isFromPartner),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: isFromPartner ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isFromPartner
                      ? LinearGradient(
                          colors: [AppTheme.lightGrey.withValues(alpha: 0.5), AppTheme.lightGrey.withValues(alpha: 0.2)],
                        )
                      : const LinearGradient(
                          colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                        ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isFromPartner ? const Radius.circular(4) : const Radius.circular(20),
                      bottomRight: isFromPartner ? const Radius.circular(20) : const Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isFromPartner ? AppTheme.darkGrey : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatMessageTime(message.sentAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          if (!isFromPartner) ...[
            const SizedBox(width: 12),
            _buildAvatar(isFromPartner),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isFromPartner) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFromPartner 
            ? [AppTheme.secondaryBlue, AppTheme.accentMint]
            : [AppTheme.primaryRose, AppTheme.primaryPurple],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(
        isFromPartner ? Icons.favorite : Icons.account_circle,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isNotEmpty) {
      widget.onSendMessage(text.trim());
      _messageController.clear();
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays < 1) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays < 7) {
      return DateFormat('EEE HH:mm').format(dateTime);
    } else {
      return DateFormat('MMM d, HH:mm').format(dateTime);
    }
  }
}
