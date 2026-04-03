import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:provider/provider.dart';
import '../../../core/services/enhanced_ai_chat_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/app_localizations.dart';
import '../../settings/providers/settings_provider.dart';
import 'package:uuid/uuid.dart';

/// Floating AI Chat Widget for insights screen
class FloatingAIChat extends StatefulWidget {
  final GlobalKey tabsKey;
  final GlobalKey periodSelectorKey;
  const FloatingAIChat({super.key, required this.tabsKey, required this.periodSelectorKey});

  @override
  State<FloatingAIChat> createState() => _FloatingAIChatState();
}

class _FloatingAIChatState extends State<FloatingAIChat>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isFullScreen = false;
  double _chatHeight = 0.5; // Percentage of screen height
  late AnimationController _fabController;
  late AnimationController _chatController;
  late AnimationController _expandController;
  late Animation<double> _fabAnimation;
  late Animation<double> _chatAnimation;
  late StreamSubscription _messagesSub;
  

  final EnhancedAIChatService _chatService = EnhancedAIChatService();
  List<types.Message> _messages = [];
  bool _isTyping = false;
  bool _quickRepliesCollapsed = false;
  // removed unused _showQuickReplies
  // ignore: unused_field
  bool _isSuggestionsExpanded = true;
  // ignore: unused_field
  final List<String> _suggestedQuestions = [
    "When will my next period start?",
    "Is my cycle regular?",
    "Can I get pregnant today?",
    "What are my fertile days?",
    "Why is my period late?",
    "What do my symptoms mean?",
    "How long is a normal cycle?",
    "When am I ovulating?",
    "Is spotting normal?",
    "How can I reduce cramps?",
  ];

  late TextEditingController _textController;
  late FocusNode _inputFocusNode;

  // For resize gesture
  // ignore: unused_field
  double _initialHeight = 0;
  bool _isResizing = false;

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _chatController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    );

    _chatAnimation = CurvedAnimation(
      parent: _chatController,
      curve: Curves.easeOutCubic,
    );

    

    // Initialize text controller
    _textController = TextEditingController();
    _inputFocusNode = FocusNode()..addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize chat service after first build to get localizations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localizations = AppLocalizations.of(context);
      final settingsProvider = context.read<SettingsProvider>();
      final userPreferences = settingsProvider.preferences;

      final userName =
          userPreferences.displayName;

      _chatService.initialize(
        userId: userPreferences.userId,
        userName: userName,
        localizations: localizations,
      );
    });

    // Listen to messages
    _messagesSub = _chatService.messagesStream.listen((messages) {
      if (mounted) {
        setState(() {
          _messages = messages;
          _isTyping = false;
        });
      }
    });

    _messages = _chatService.messages;

    // Start pulsing animation
    _startPulsingAnimation();
  }

  @override
  void dispose() {
    // Ensure animations are stopped and controllers disposed properly
    _fabController.stop();
    _chatController.stop();
    _expandController.stop();
    _fabController.dispose();
    _chatController.dispose();
    _expandController.dispose();
    _textController.dispose();
    _messagesSub.cancel();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _startPulsingAnimation() {
    if (!_isExpanded) {
      _fabController.repeat(reverse: true);
    }
  }

  void _stopPulsingAnimation() {
    _fabController.stop();
    _fabController.reset();
  }

  void _toggleChat() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (!_isExpanded) {
        _isFullScreen = false;
        _chatHeight = 0.5;
      }
    });

    if (_isExpanded) {
      _stopPulsingAnimation();
      _chatController.forward();
    } else {
      _chatController.reverse();
      _expandController.reverse();
      _startPulsingAnimation();
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      _chatHeight = _isFullScreen ? 0.9 : 0.6;
    });

    if (_isFullScreen) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  void _adjustChatHeight(double delta) {
    setState(() {
      _chatHeight = (_chatHeight - delta / MediaQuery.of(context).size.height)
          .clamp(0.3, 0.9);
    });
  }

  /// Determine if Quick Questions should be shown
  /// Show when there's only the welcome message (no user messages yet)
  bool _shouldShowQuickQuestions() {
    // If no messages at all, show quick questions
    if (_messages.isEmpty) return true;

    // If only one message and it's from AI (welcome message), show quick questions
    if (_messages.length == 1) {
      final firstMessage = _messages.first;
      return firstMessage.author.id == 'ai_flowai_enhanced';
    }

    // Otherwise, don't show quick questions
    return false;
  }

  void _handleSendPressed(types.PartialText message) {
    final currentUser = _chatService.currentUser;
    if (currentUser == null) return;

    final textMessage = types.TextMessage(
      author: currentUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    setState(() {
      _isTyping = true;
    });

    _chatService.sendMessage(textMessage);
  }

  void _handleMessageTap(BuildContext _, types.Message message) {
    // Handle message tap if needed
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    // Handle preview data if needed
  }

  double _getTabsBottom() {
    final ctx = widget.tabsKey.currentContext;
    if (ctx == null) return 200;
    final box = ctx.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero);
    return pos.dy + box.size.height + 8;
  }

  double _getPeriodSelectorTop() {
    final ctx = widget.periodSelectorKey.currentContext;
    if (ctx == null) return MediaQuery.of(context).padding.top + 80;
    final box = ctx.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero);
    return pos.dy;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardOpen = _inputFocusNode.hasFocus;
    

    return Stack(
      children: [
        // Enhanced Chat Interface - NO OVERLAY
        if (_isExpanded)
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            right: _isFullScreen ? 16 : 20,
            left: _isFullScreen ? 16 : 20,
            top: _isFullScreen
                ? _getPeriodSelectorTop()
                : _getTabsBottom(),
            bottom: _isFullScreen
                ? MediaQuery.of(context).padding.bottom + 8
                : 8,
            child: AnimatedBuilder(
              animation: _chatAnimation,
              builder: (context, child) {
                return Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(
                        _isFullScreen ? 16 : 24,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.2),
                          blurRadius: 12,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: AppTheme.primaryRose.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Enhanced Draggable Header with Controls
                        _buildEnhancedHeader(theme, compact: keyboardOpen),

                        // Main content area - improved spacing
                        Expanded(
                          child: _buildChatArea(theme),
                        ),

                        // Enhanced Input Area
                        _buildEnhancedInput(theme),

                        const SizedBox(height: 0),

                        if (!keyboardOpen &&
                            _shouldShowQuickQuestions() &&
                            !_quickRepliesCollapsed)
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: _buildEnhancedQuickReplies(theme),
                            ),
                          ),
                      ],
                    ),
                );
              },
            ),
          ),

        // Enhanced Floating Action Button
        if (!_isExpanded)
          Positioned(
          right: 16,
          bottom: 16,
          child: AnimatedBuilder(
            animation: _fabAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isExpanded ? 1.0 : (1.0 + _fabAnimation.value * 0.1),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryRose.withValues(alpha: 0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    heroTag: "ai_chat_main_fab",
                    onPressed: _toggleChat,
                    backgroundColor: AppTheme.primaryRose,
                    elevation: 0,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return RotationTransition(
                          turns: animation,
                          child: child,
                        );
                      },
                      child: _isExpanded
                          ? TweenAnimationBuilder(
  tween: Tween(begin: 0.6, end: 1.0),
  duration: const Duration(seconds: 2),
  curve: Curves.easeInOut,
  builder: (context, double value, child) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.4 * value),
            blurRadius: 12 * value,
            spreadRadius: 1 * value,
          ),
        ],
      ),
      child: child,
    );
  },
  child: Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              key: const ValueKey('close'),
                              size: 28,
                            )
                          : Stack(
                              key: const ValueKey('chat'),
                              children: [
                                Icon(
                                  Icons.psychology_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                if (!_isExpanded)
                                  Positioned(
                                    top: -2,
                                    right: -2,
                                    child:
                                        Container(
                                              width: 16,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    AppTheme.successGreen,
                                                    AppTheme.accentMint,
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppTheme.successGreen
                                                        .withValues(alpha: 0.5),
                                                    blurRadius: 8,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                Icons.auto_awesome,
                                                color: Colors.white,
                                                size: 10,
                                              ),
                                            )
                                            .animate(
                                              onPlay: null,
                                            )
                                            .shimmer(
                                              duration: 2000.ms,
                                              color: Colors.white.withValues(
                                                alpha: 0.5,
                                              ),
                                            )
                                            .then(delay: 1000.ms)
                                            .fadeOut(duration: 500.ms)
                                            .then(delay: 1000.ms)
                                            .fadeIn(duration: 500.ms),
                                  ),
                              ],
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Enhanced Header with Controls
  Widget _buildEnhancedHeader(ThemeData theme, {bool compact = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryPurple, AppTheme.primaryRose],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_isFullScreen ? 16 : 24),
          topRight: Radius.circular(_isFullScreen ? 16 : 24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryRose.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Resize Handle - Only draggable area
          if (!_isFullScreen && !compact)
            Center(
              child: GestureDetector(
                onPanStart: (details) {
                  _initialHeight = _chatHeight;
                  _isResizing = true;
                },
                onPanUpdate: (details) {
                  if (!_isFullScreen && _isResizing) {
                    _adjustChatHeight(details.delta.dy);
                  }
                },
                onPanEnd: (details) {
                  _isResizing = false;
                },
                child: Container(
                  width: 16, // Larger hit area for better UX
                  height: 30, // Larger hit area
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          if (!_isFullScreen && !compact) const SizedBox(height: 16),

          // Header Content
          Row(
            children: [
              // AI Avatar with Animation
              Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.psychology_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  )
                  .animate(onPlay: null)
                  .shimmer(
                    duration: 3000.ms,
                    color: Colors.white.withValues(alpha: 0.3),
                  )
                  .then(delay: 2000.ms),

              const SizedBox(width: 16),

              // Title and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zyra AI Assistant',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppTheme.successGreen,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            )
                            .animate(
                              onPlay: null,
                            )
                            .fadeIn(duration: 1000.ms)
                            .then(delay: 500.ms)
                            .fadeOut(duration: 1000.ms),
                        const SizedBox(width: 8),
                        Text(
                          _isTyping ? 'Thinking...' : 'Ready to help',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Header Actions - With improved tap handling
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Fullscreen Toggle
                  GestureDetector(
                    onTap: _toggleFullScreen,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        _isFullScreen
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Close Button - Enhanced with better tap handling
                  GestureDetector(
                    onTap: _toggleChat,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (!compact) ...[
            // Medical Disclaimer (Guideline 1.4.1)
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'AI-generated insights for awareness only. Not medical advice.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Enhanced Chat Area - Better spacing and padding
  Widget _buildChatArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Theme(
        data: theme.copyWith(primaryColor: AppTheme.primaryRose),
        child: Chat(
          messages: _messages,
          onSendPressed: _handleSendPressed,
          onMessageTap: _handleMessageTap,
          onPreviewDataFetched: _handlePreviewDataFetched,
          user: _chatService.currentUser ?? types.User(id: 'fallback_user'),
          theme: DefaultChatTheme(
            primaryColor: AppTheme.primaryRose,
            secondaryColor: AppTheme.secondaryBlue.withValues(alpha: 0.1),
            backgroundColor: theme.scaffoldBackgroundColor,
            inputBackgroundColor: theme.cardColor,
            inputTextColor: theme.textTheme.bodyMedium?.color ?? Colors.black,
            messageBorderRadius: 18,
            messageInsetsHorizontal: 20,
            messageInsetsVertical: 14,
            receivedMessageBodyTextStyle:
                theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 16,
                  height: 1.5,
                ) ??
                const TextStyle(fontSize: 16, height: 1.5),
            sentMessageBodyTextStyle:
                theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                ) ??
                const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
          ),
          showUserAvatars: true,
          showUserNames: false,
          customBottomWidget: const SizedBox.shrink(), // We'll use our enhanced input
        ),
      ),
    );
  }

  // Enhanced Quick Replies - More visible and professional
  Widget _buildEnhancedQuickReplies(ThemeData theme) {
    final suggestions = _chatService.getSuggestedReplies().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header - More prominent
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Suggested Questions',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryRose,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Suggestions - Horizontal scrollable for better visibility
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _buildSuggestionChip(suggestions[index], theme, index);
            },
          ),
        ),
      ],
    );
  }

  // Suggestion Chip - More prominent and professional
  Widget _buildSuggestionChip(String suggestion, ThemeData theme, int index) {
    return InkWell(
          onTap: () {
            final currentUser = _chatService.currentUser;
            if (currentUser == null) return;

            final message = types.TextMessage(
              author: currentUser,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              id: const Uuid().v4(),
              text: suggestion,
            );

            setState(() {
              _isTyping = true;
              _isSuggestionsExpanded = false;
              _quickRepliesCollapsed = true;
            });

            _chatService.sendMessage(message);
          },
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryRose.withValues(alpha: 0.15),
                  AppTheme.primaryPurple.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppTheme.primaryRose.withValues(alpha: 0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRose.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              suggestion,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryRose,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 100).ms)
        .slideX(begin: 0.3, end: 0);
  }

  // Enhanced Input Area - Better spacing and visibility
  Widget _buildEnhancedInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(_isFullScreen ? 16 : 24),
          bottomRight: Radius.circular(_isFullScreen ? 16 : 24),
        ),
        border: null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppTheme.primaryRose.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _inputFocusNode,
                decoration: InputDecoration(
                  hintText:
                      'Ask about health, science, technology, lifestyle...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor.withValues(alpha: 0.7),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  height: 1.4,
                ),
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty) {
                    _handleSendPressed(types.PartialText(text: text.trim()));
                    _textController.clear();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Send Button - More prominent
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRose.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final text = _textController.text.trim();
                  if (text.isNotEmpty) {
                    _handleSendPressed(types.PartialText(text: text));
                    _textController.clear();
                  }
                },
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
